import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key, required this.api, this.prefill});

  final MarqueeFlowApi api;
  final Map<String, dynamic>? prefill;

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestCtrl = TextEditingController(text: '100');
  final _advanceCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  String? _eventType;
  String? _packageId;
  List<dynamic> _eventTypes = [];
  List<dynamic> _packages = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final types = await widget.api.fetchEventTypes();
      final packages = await widget.api.fetchPackages();
      setState(() {
        _eventTypes = types;
        _packages = packages;
        _eventType = types.isNotEmpty ? types.first as String : 'Other';
        if (packages.isNotEmpty) _packageId = packages.first['id'] as String?;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _guestCtrl.dispose();
    _advanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final prefill = widget.prefill ?? {};
    final eventDate = prefill['eventDate'] as String?;
    final slotId = prefill['slotId'] as String?;
    if (eventDate == null || slotId == null) {
      setState(() => _error = 'Select date and slot from Calendar first');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.api.createBooking({
        'customerName': _nameCtrl.text.trim(),
        'customerPhone': _phoneCtrl.text.trim(),
        'eventDate': eventDate,
        'slotId': slotId,
        'eventType': _eventType,
        'guestCount': int.parse(_guestCtrl.text),
        'packageId': _packageId,
        'advancePayment': num.tryParse(_advanceCtrl.text) ?? 0,
        'notes': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      final id = (result['booking'] as Map<String, dynamic>)['id'];
      context.go('/bookings/$id');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefill = widget.prefill ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Booking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              title: const Text('Selected date & slot'),
              subtitle: Text(
                '${prefill['eventDate'] ?? 'Not selected'} · ${prefill['slotName'] ?? prefill['slotId'] ?? 'No slot'}',
              ),
              trailing: TextButton(onPressed: () => context.go('/calendar'), child: const Text('Change')),
            ),
          ),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Customer name')),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone number'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _eventType,
            decoration: const InputDecoration(labelText: 'Event type'),
            items: _eventTypes
                .map((t) => DropdownMenuItem(value: t as String, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _eventType = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _packageId,
            decoration: const InputDecoration(labelText: 'Package'),
            items: _packages
                .map((p) => DropdownMenuItem(
                      value: p['id'] as String,
                      child: Text('${p['name']} — PKR ${p['price']}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _packageId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _guestCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Guest count'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _advanceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Advance payment (PKR)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'Saving...' : 'Save Booking'),
          ),
        ],
      ),
    );
  }
}
