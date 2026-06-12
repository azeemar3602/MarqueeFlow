import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.fetchBooking(widget.bookingId);
      setState(() => _booking = res['booking'] as Map<String, dynamic>?);
    } catch (_) {}
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(appBar: AppBar(title: const Text('Booking Details')), body: const Center(child: CircularProgressIndicator()));
    }
    final b = _booking;
    if (b == null) {
      return Scaffold(appBar: AppBar(title: const Text('Booking Details')), body: const Center(child: Text('Booking not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(b['bookingCode'] as String? ?? 'Booking Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['customerName'] as String? ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(b['customerPhone'] as String? ?? ''),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _share,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _row('Event date', b['eventDate']?.toString()),
          _row('Event type', b['eventType']?.toString()),
          _row('Guests', b['guestCount']?.toString()),
          _row('Package', b['packageName']?.toString() ?? b['packageId']?.toString()),
          const SizedBox(height: 8),
          Row(
            children: [
              StatusBadge(label: b['status'] as String? ?? 'pending'),
              const SizedBox(width: 8),
              StatusBadge(label: b['paymentStatus'] as String? ?? 'unpaid'),
            ],
          ),
          const SizedBox(height: 12),
          _row('Advance paid', 'PKR ${b['advancePaid'] ?? b['advancePayment'] ?? 0}'),
          _row('Remaining', 'PKR ${b['remainingAmount'] ?? 0}'),
          if ((b['notes'] as String?)?.isNotEmpty == true) _row('Notes', b['notes'] as String?),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/payments'),
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Color(0xFF434753)))),
          Expanded(child: Text(value ?? '—')),
        ],
      ),
    );
  }
}
