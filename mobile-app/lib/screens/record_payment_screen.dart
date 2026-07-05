import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key, required this.api, required this.bookingId});

  final MarqueeFlowApi api;
  final String bookingId;

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  Map<String, dynamic>? _booking;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _method = 'cash';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  static const _methods = ['cash', 'bank_transfer', 'jazzcash', 'easypaisa'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.api.fetchBooking(widget.bookingId);
      setState(() => _booking = res['booking'] as Map<String, dynamic>?);
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    }
    if (mounted) setState(() => _loading = false);
  }

  num get _total => (_booking?['totalAmount'] as num?) ??
      ((_booking?['advancePaid'] as num? ?? 0) + (_booking?['remainingAmount'] as num? ?? 0));

  num get _paid => _booking?['advancePaid'] as num? ?? 0;

  num get _remaining => _booking?['remainingAmount'] as num? ?? 0;

  Future<void> _submit() async {
    final amount = num.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a payment amount greater than zero.');
      return;
    }
    if (amount > _remaining) {
      setState(() => _error = 'Amount cannot exceed remaining PKR $_remaining.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.recordPayment(
        bookingId: widget.bookingId,
        amount: amount,
        paymentType: _method,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded')));
      context.go('/bookings/${widget.bookingId}');
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return mfLoadingScreen();

    final b = _booking;
    return MfScreenShell(
      title: 'Record Payment',
      subtitle: b != null ? '${b['customerName']} · ${b['bookingCode']}' : null,
      endDrawer: buildMfDrawer(widget.api, '/payments'),
      onBack: () => mfGoBack(context, fallback: '/bookings/${widget.bookingId}'),
      child: b == null
          ? MfEmptyState(
              title: 'Booking not found',
              message: _error ?? 'Unable to load booking for payment.',
              actionLabel: 'Go back',
              onAction: () => context.go('/payments'),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['customerName'] as String? ?? '', style: AppText.label()),
                      Text('${b['eventDate']} · ${b['slotName'] ?? ''}', style: AppText.body()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MfAmountSummary(
                  total: _total,
                  paid: _paid,
                  remaining: _remaining,
                  paymentStatus: b['paymentStatus'] as String?,
                ),
                const SizedBox(height: 16),
                MfTextField(
                  label: 'New payment amount (PKR)',
                  iconLetter: 'A',
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                Text('Payment method', style: AppText.label()),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _method,
                  decoration: const InputDecoration(
                    prefixIcon: MfFieldIcon('M'),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  items: _methods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.replaceAll('_', ' '))))
                      .toList(),
                  onChanged: _saving ? null : (v) => setState(() => _method = v ?? 'cash'),
                ),
                const SizedBox(height: 16),
                MfTextField(
                  label: 'Payment note (optional)',
                  iconLetter: 'N',
                  controller: _noteCtrl,
                  enabled: !_saving,
                ),
                if (_error != null) ...[const SizedBox(height: 16), MfErrorBanner(_error!)],
                const SizedBox(height: 20),
                MfPrimaryButton(label: 'Save Payment', loading: _saving, onPressed: _submit),
              ],
            ),
    );
  }
}
