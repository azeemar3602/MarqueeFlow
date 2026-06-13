import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';
import '../widgets/status_badge.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  Map<String, dynamic>? _summary;
  List<dynamic> _payments = [];
  List<dynamic> _unpaidBookings = [];
  bool _loading = true;
  String? _dateFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await widget.api.fetchPaymentsSummary();
      final payments = await widget.api.fetchPayments(date: _dateFilter);
      final bookings = await widget.api.fetchBookings(paymentStatus: 'unpaid');
      final partial = await widget.api.fetchBookings(paymentStatus: 'partially_paid');
      final advance = await widget.api.fetchBookings(paymentStatus: 'advance_paid');
      setState(() {
        _summary = summary;
        _payments = payments;
        _unpaidBookings = [...bookings, ...partial, ...advance];
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFilter != null ? DateTime.parse(_dateFilter!) : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dateFilter = DateFormat('yyyy-MM-dd').format(picked));
      _load();
    }
  }

  Future<void> _recordPayment() async {
    String? bookingId;
    final amountCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: AppColors.cream,
          title: Text('Record Payment', style: AppText.display('Record Payment', size: 22)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select booking', style: AppText.label()),
              DropdownButtonFormField<String>(
                initialValue: bookingId,
                decoration: const InputDecoration(isDense: true),
                items: _unpaidBookings.map((raw) {
                  final b = raw as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: b['id'] as String,
                    child: Text('${b['bookingCode']} · ${b['customerName']} (PKR ${b['remainingAmount']})'),
                  );
                }).toList(),
                onChanged: (v) => setDialog(() => bookingId = v),
              ),
              const SizedBox(height: 12),
              MfTextField(label: 'Amount (PKR)', iconLetter: 'A', controller: amountCtrl, keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (bookingId == null) return;
                try {
                  await widget.api.recordPayment(
                    bookingId: bookingId!,
                    amount: num.parse(amountCtrl.text),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value) {
    return Expanded(
      child: MfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.body().copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: AppText.display(value, size: 22)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MfScreenShell(
      title: 'Payments',
      subtitle: 'Track received, pending, and booking payment history.',
      endDrawer: buildMfDrawer(widget.api, '/payments'),
      onBack: () => mfGoBack(context, fallback: '/home'),
      child: _loading
          ? const MfLoadingBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(_dateFilter ?? 'Filter by date'),
                      ),
                    ),
                    if (_dateFilter != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _dateFilter = null);
                          _load();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _summaryCard('Received', 'PKR ${_summary?['totalReceived'] ?? 0}'),
                    const SizedBox(width: 12),
                    _summaryCard('Pending', 'PKR ${_summary?['pendingAmount'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _summaryCard('Partial', '${_summary?['partialCount'] ?? 0}'),
                    const SizedBox(width: 12),
                    _summaryCard('Fully paid', '${_summary?['fullyPaidCount'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Payment history', style: AppText.display('Payment history', size: 22)),
                const SizedBox(height: 12),
                if (_payments.isEmpty)
                  MfCard(child: Text('No payments recorded', style: AppText.body()))
                else
                  ..._payments.map((raw) {
                    final payment = raw as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MfCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PKR ${payment['amount']}', style: AppText.label()),
                                  Text(
                                    '${payment['bookingCode'] ?? payment['bookingId']} · ${payment['customerName'] ?? ''} · ${payment['paymentDate'] ?? ''}',
                                    style: AppText.body(),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(
                              label: payment['paymentType'] as String? ?? payment['paymentStatus'] as String? ?? 'partial',
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                MfPrimaryButton(label: 'Record Payment', icon: Icons.add, onPressed: _recordPayment),
              ],
            ),
    );
  }
}
