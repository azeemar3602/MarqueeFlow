import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await widget.api.fetchPaymentsSummary();
      final payments = await widget.api.fetchPayments();
      setState(() {
        _summary = summary;
        _payments = payments;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _recordPayment() async {
    final bookingIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: bookingIdCtrl, decoration: const InputDecoration(labelText: 'Booking ID')),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (PKR)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.api.recordPayment(
                  bookingId: bookingIdCtrl.text.trim(),
                  amount: num.parse(amountCtrl.text),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              } on ApiException catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.message)));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF434753), fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _recordPayment),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
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
                  const Text('Payment history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_payments.isEmpty)
                    const Card(child: ListTile(title: Text('No payments recorded')))
                  else
                    ..._payments.map((p) {
                      final payment = p as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text('PKR ${payment['amount']}'),
                          subtitle: Text('Booking ${payment['bookingId']} · ${payment['paymentDate'] ?? ''}'),
                          trailing: StatusBadge(label: payment['paymentStatus'] as String? ?? payment['paymentType'] as String? ?? 'partial'),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
