import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../utils/phone_validation.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

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
  String _status = 'pending';
  List<dynamic> _eventTypes = [];
  List<dynamic> _packages = [];
  bool _loadingOptions = true;
  bool _loading = false;
  String? _error;
  String? _optionsError;

  static const _statuses = ['pending', 'confirmed', 'cancelled', 'completed'];

  @override
  void initState() {
    super.initState();
    _loadOptions();
    _advanceCtrl.addListener(() => setState(() {}));
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _optionsError = null;
    });
    try {
      final types = await widget.api.fetchEventTypes();
      final packages = await widget.api.fetchPackages();
      if (!mounted) return;
      setState(() {
        _eventTypes = types;
        _packages = packages.where((p) => (p as Map)['status'] != 'inactive').toList();
        _eventType = types.isNotEmpty ? types.first as String : 'Other';
        _packageId = _packages.isNotEmpty ? _packages.first['id'] as String? : null;
      });
    } catch (e) {
      if (mounted) setState(() => _optionsError = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  Map<String, dynamic>? get _selectedPackage {
    if (_packageId == null) return null;
    for (final raw in _packages) {
      final pkg = raw as Map<String, dynamic>;
      if (pkg['id'] == _packageId) return pkg;
    }
    return null;
  }

  num get _packagePrice => (_selectedPackage?['price'] as num?) ?? 0;

  num get _advance => num.tryParse(_advanceCtrl.text.trim()) ?? 0;

  num get _remaining => (_packagePrice - _advance).clamp(0, _packagePrice);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _guestCtrl.dispose();
    _advanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final prefill = widget.prefill ?? {};
    final eventDate = prefill['eventDate'] as String?;
    final slotId = prefill['slotId'] as String?;
    if (eventDate == null || slotId == null) {
      return 'Select a date and slot from Calendar & Slots first.';
    }
    if (_nameCtrl.text.trim().isEmpty) return 'Customer name is required.';
    if (!isValidPkPhone(_phoneCtrl.text.trim())) {
      return 'Enter a valid Pakistani mobile number (e.g. 03XXXXXXXXX).';
    }
    if (_packages.isEmpty) {
      return 'Create at least one active package before saving a booking.';
    }
    if (_packageId == null) return 'Select a package for this booking.';
    final guests = int.tryParse(_guestCtrl.text.trim());
    if (guests == null || guests < 1) return 'Guest count must be at least 1.';
    final limit = _selectedPackage?['guestLimit'] as num?;
    if (limit != null && limit > 0 && guests > limit) {
      return 'Guest count exceeds package limit of ${limit.toInt()}.';
    }
    if (_advance < 0) return 'Advance payment cannot be negative.';
    if (_advance > _packagePrice) return 'Advance payment cannot exceed package total.';
    return null;
  }

  Future<void> _submit() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    final prefill = widget.prefill ?? {};
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.api.createBooking({
        'customerName': _nameCtrl.text.trim(),
        'customerPhone': normalizePkPhone(_phoneCtrl.text.trim()),
        'eventDate': prefill['eventDate'],
        'slotId': prefill['slotId'],
        'eventType': _eventType,
        'guestCount': int.parse(_guestCtrl.text.trim()),
        'packageId': _packageId,
        'advancePayment': _advance,
        'status': _status,
        'notes': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      final id = (result['booking'] as Map<String, dynamic>)['id'] as String;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking saved successfully')),
      );
      context.go('/bookings/$id');
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefill = widget.prefill ?? {};
    return MfScreenShell(
      title: 'Add New Booking',
      subtitle: 'Complete booking details after selecting a slot.',
      endDrawer: buildMfDrawer(widget.api, '/calendar'),
      onBack: () => mfGoBack(context, fallback: '/calendar'),
      child: _loadingOptions
          ? const MfLoadingBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MfCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Selected date & slot', style: AppText.label()),
                            const SizedBox(height: 4),
                            Text(
                              '${prefill['eventDate'] ?? 'Not selected'} · ${prefill['slotName'] ?? prefill['slotId'] ?? 'No slot'}',
                              style: AppText.body(),
                            ),
                          ],
                        ),
                      ),
                      TextButton(onPressed: () => context.go('/calendar'), child: const Text('Change')),
                    ],
                  ),
                ),
                if (_optionsError != null) ...[
                  const SizedBox(height: 12),
                  MfErrorBanner(_optionsError!),
                  TextButton(onPressed: _loadOptions, child: const Text('Retry loading packages')),
                ],
                const SizedBox(height: 16),
                MfTextField(label: 'Customer name', iconLetter: 'N', controller: _nameCtrl, enabled: !_loading),
                const SizedBox(height: 16),
                MfTextField(
                  label: 'Phone number',
                  iconLetter: 'P',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                Text('Event type', style: AppText.label()),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _eventType,
                  decoration: const InputDecoration(
                    prefixIcon: MfFieldIcon('E'),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  items: _eventTypes
                      .map((t) => DropdownMenuItem(value: t as String, child: Text(t)))
                      .toList(),
                  onChanged: _loading ? null : (v) => setState(() => _eventType = v),
                ),
                const SizedBox(height: 16),
                Text('Package', style: AppText.label()),
                const SizedBox(height: 8),
                if (_packages.isEmpty)
                  MfCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No active packages found.', style: AppText.body()),
                        const SizedBox(height: 8),
                        TextButton(onPressed: () => context.push('/packages'), child: const Text('Manage packages')),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _packageId,
                    decoration: const InputDecoration(
                      prefixIcon: MfFieldIcon('K'),
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    items: _packages
                        .map((p) => DropdownMenuItem(
                              value: p['id'] as String,
                              child: Text('${p['name']} — PKR ${p['price']} (${p['guestLimit'] ?? '—'} guests)'),
                            ))
                        .toList(),
                    onChanged: _loading ? null : (v) => setState(() => _packageId = v),
                  ),
                const SizedBox(height: 16),
                MfTextField(
                  label: 'Guest count',
                  iconLetter: 'G',
                  controller: _guestCtrl,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                MfTextField(
                  label: 'Advance payment (PKR)',
                  iconLetter: 'A',
                  controller: _advanceCtrl,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                ),
                const SizedBox(height: 12),
                MfCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Package total', style: AppText.body()),
                          Text('PKR $_packagePrice', style: AppText.label()),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Remaining payment', style: AppText.label()),
                          Text('PKR $_remaining', style: AppText.display('PKR $_remaining', size: 20)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Booking status', style: AppText.label()),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    prefixIcon: MfFieldIcon('S'),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1))))
                      .toList(),
                  onChanged: _loading ? null : (v) => setState(() => _status = v ?? 'pending'),
                ),
                const SizedBox(height: 16),
                MfTextField(label: 'Notes', iconLetter: 'T', controller: _notesCtrl, enabled: !_loading),
                if (_error != null) ...[const SizedBox(height: 16), MfErrorBanner(_error!)],
                const SizedBox(height: 20),
                MfPrimaryButton(label: 'Save Booking', loading: _loading, onPressed: _submit),
              ],
            ),
    );
  }
}
