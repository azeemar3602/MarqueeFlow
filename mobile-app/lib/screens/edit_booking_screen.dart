import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class EditBookingScreen extends StatefulWidget {
  const EditBookingScreen({super.key, required this.api, required this.bookingId});

  final MarqueeFlowApi api;
  final String bookingId;

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _eventType;
  String? _status;
  List<dynamic> _eventTypes = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Map<String, dynamic>? _booking;

  static const _statuses = ['pending', 'confirmed', 'cancelled', 'completed'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final types = await widget.api.fetchEventTypes();
      final res = await widget.api.fetchBooking(widget.bookingId);
      final b = res['booking'] as Map<String, dynamic>;
      setState(() {
        _eventTypes = types;
        _booking = b;
        _nameCtrl.text = b['customerName'] as String? ?? '';
        _phoneCtrl.text = b['customerPhone'] as String? ?? '';
        _guestCtrl.text = '${b['guestCount'] ?? 0}';
        _notesCtrl.text = b['notes'] as String? ?? '';
        _eventType = b['eventType'] as String?;
        _status = b['status'] as String? ?? 'pending';
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _guestCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.updateBooking(widget.bookingId, {
        'customerName': _nameCtrl.text.trim(),
        'customerPhone': _phoneCtrl.text.trim(),
        'guestCount': int.parse(_guestCtrl.text),
        'eventType': _eventType,
        'status': _status,
        'notes': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      context.pop();
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
      title: 'Edit Booking',
      subtitle: b?['bookingCode'] as String? ?? widget.bookingId,
      endDrawer: buildMfDrawer(widget.api, '/bookings'),
      onBack: () => mfGoBack(context, fallback: '/bookings/${widget.bookingId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MfCard(child: MfDetailRow('Event date', b?['eventDate']?.toString())),
          const SizedBox(height: 16),
          MfTextField(label: 'Customer name', iconLetter: 'N', controller: _nameCtrl, enabled: !_saving),
          const SizedBox(height: 16),
          MfTextField(label: 'Phone number', iconLetter: 'P', controller: _phoneCtrl, keyboardType: TextInputType.phone, enabled: !_saving),
          const SizedBox(height: 16),
          Text('Event type', style: AppText.label()),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _eventType,
            items: _eventTypes.map((t) => DropdownMenuItem(value: t as String, child: Text(t))).toList(),
            onChanged: _saving ? null : (v) => setState(() => _eventType = v),
          ),
          const SizedBox(height: 16),
          MfTextField(label: 'Guest count', iconLetter: 'G', controller: _guestCtrl, keyboardType: TextInputType.number, enabled: !_saving),
          const SizedBox(height: 16),
          Text('Booking status', style: AppText.label()),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _status,
            items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
            onChanged: _saving ? null : (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 16),
          MfTextField(label: 'Notes', iconLetter: 'T', controller: _notesCtrl, enabled: !_saving),
          if (_error != null) ...[const SizedBox(height: 16), MfErrorBanner(_error!)],
          const SizedBox(height: 20),
          MfPrimaryButton(label: 'Save Changes', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
