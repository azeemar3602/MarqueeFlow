import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../utils/phone_launcher.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';
import '../widgets/status_badge.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key, required this.api, required this.bookingId});

  final MarqueeFlowApi api;
  final String bookingId;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  Map<String, dynamic>? _booking;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
      if (mounted) setState(() => _error = mapRequestError(e).message);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _share() async {
    try {
      final res = await widget.api.shareBooking(widget.bookingId);
      final text = res['text'] as String? ?? '';
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking details copied')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
      }
    }
  }

  Future<void> _whatsapp() async {
    final b = _booking;
    if (b == null) return;
    final message = 'MarqueeFlow booking ${b['bookingCode']} for ${b['eventDate']}.';
    await launchWhatsApp(b['customerPhone'] as String? ?? '', message: message);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return mfLoadingScreen();
    if (_error != null) {
      return MfScreenShell(
        title: 'Booking Details',
        endDrawer: buildMfDrawer(widget.api, '/bookings'),
        onBack: () => mfGoBack(context, fallback: '/bookings'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MfErrorBanner(_error!),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final b = _booking;
    if (b == null) {
      return MfScreenShell(
        title: 'Booking Details',
        endDrawer: buildMfDrawer(widget.api, '/bookings'),
        onBack: () => mfGoBack(context, fallback: '/bookings'),
        child: MfCard(child: Text('Booking not found', style: AppText.body())),
      );
    }

    final slotName = b['slot']?['slotName'] ?? b['slotName'];

    return MfScreenShell(
      title: 'Booking Details',
      subtitle: b['bookingCode'] as String? ?? widget.bookingId,
      endDrawer: buildMfDrawer(widget.api, '/bookings'),
      onBack: () => mfGoBack(context, fallback: '/bookings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b['customerName'] as String? ?? '', style: AppText.display(b['customerName'] as String? ?? '', size: 24)),
                const SizedBox(height: 4),
                Text(b['customerPhone'] as String? ?? '', style: AppText.body()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: MfOutlinedAction(label: 'Call', icon: Icons.phone, onPressed: () => launchPhoneCall(b['customerPhone'] as String? ?? ''))),
                    const SizedBox(width: 8),
                    Expanded(child: MfOutlinedAction(label: 'WhatsApp', icon: Icons.chat, onPressed: _whatsapp)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: MfOutlinedAction(label: 'Share', icon: Icons.share_outlined, onPressed: _share)),
                    const SizedBox(width: 8),
                    Expanded(child: MfOutlinedAction(label: 'Edit', icon: Icons.edit_outlined, onPressed: () => context.push('/bookings/${widget.bookingId}/edit'))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MfCard(
            child: Column(
              children: [
                MfDetailRow('Event date', b['eventDate']?.toString()),
                MfDetailRow('Slot', slotName?.toString()),
                MfDetailRow('Event type', b['eventType']?.toString()),
                MfDetailRow('Guests', b['guestCount']?.toString()),
                MfDetailRow('Package', b['package']?['name']?.toString() ?? b['packageName']?.toString()),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(label: b['status'] as String? ?? 'pending'),
                    const SizedBox(width: 8),
                    StatusBadge(label: b['paymentStatus'] as String? ?? 'unpaid'),
                  ],
                ),
                const SizedBox(height: 8),
                MfDetailRow('Advance paid', 'PKR ${b['advancePaid'] ?? b['advancePayment'] ?? 0}'),
                MfDetailRow('Remaining', 'PKR ${b['remainingAmount'] ?? 0}'),
                if ((b['notes'] as String?)?.isNotEmpty == true) MfDetailRow('Notes', b['notes'] as String?),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MfPrimaryButton(label: 'Record Payment', icon: Icons.payments_outlined, onPressed: () => context.push('/payments')),
        ],
      ),
    );
  }
}
