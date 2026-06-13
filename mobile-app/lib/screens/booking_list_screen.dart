import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/phone_launcher.dart';
import '../widgets/mf_components.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_navigation.dart';
import '../widgets/status_badge.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final _searchCtrl = TextEditingController();
  List<dynamic> _bookings = [];
  List<dynamic> _eventTypes = [];
  bool _loading = true;
  String? _bookingStatus;
  String? _paymentStatus;
  String? _eventType;
  String _sort = 'latest';

  String? _error;

  static const _bookingStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
  static const _paymentStatuses = ['unpaid', 'advance_paid', 'partially_paid', 'fully_paid'];
  static const _sortOptions = {
    'latest': 'Latest first',
    'oldest': 'Oldest first',
    'date': 'Event date',
  };

  @override
  void initState() {
    super.initState();
    _load();
    widget.api.fetchEventTypes().then((t) => setState(() => _eventTypes = t)).catchError((_) {});
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.api.fetchBookings(
        search: _searchCtrl.text.trim(),
        bookingStatus: _bookingStatus,
        paymentStatus: _paymentStatus,
        eventType: _eventType,
        sort: _sort,
      );
      setState(() => _bookings = list);
    } catch (e) {
      if (mounted) setState(() => _error = mapRequestError(e).message);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _clearFilters() {
    setState(() {
      _bookingStatus = null;
      _paymentStatus = null;
      _eventType = null;
      _sort = 'latest';
      _searchCtrl.clear();
    });
    _load();
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filters & sort', style: AppText.display('Filters', size: 22)),
            const SizedBox(height: 12),
            _filterDropdown('Booking status', _bookingStatus, _bookingStatuses, (v) => _bookingStatus = v),
            _filterDropdown('Payment status', _paymentStatus, _paymentStatuses, (v) => _paymentStatus = v),
            _filterDropdown('Event type', _eventType, _eventTypes.cast<String>(), (v) => _eventType = v),
            _filterDropdown('Sort', _sort, _sortOptions.keys.toList(), (v) => _sort = v ?? 'latest', labels: _sortOptions),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(ctx); _clearFilters(); }, child: const Text('Clear All'))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); _load(); }, child: const Text('Apply'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged, {Map<String, String>? labels}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label()),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(isDense: true),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any')),
              ...options.map((o) => DropdownMenuItem(value: o, child: Text(labels?[o] ?? o))),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MfScreenShell(
      title: 'Booking List',
      subtitle: 'Search and manage all bookings.',
      endDrawer: buildMfDrawer(widget.api, '/bookings'),
      onBack: () => mfGoBack(context, fallback: '/bookings'),
      child: RefreshIndicator(
        color: AppColors.maroon,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or booking ID',
                    prefixIcon: const Icon(Icons.search, color: AppColors.maroon),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.tune, color: AppColors.maroon), onPressed: _openFilters),
              IconButton(icon: const Icon(Icons.search), onPressed: _load),
            ],
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            MfErrorBanner(_error!),
            const SizedBox(height: 12),
          ],
          if (_loading)
            const MfLoadingBox()
          else if (_bookings.isEmpty)
            MfCard(child: Text('No bookings found', style: AppText.body()))
          else
            ..._bookings.map((raw) {
              final b = raw as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MfCard(
                  child: InkWell(
                    onTap: () => context.push('/bookings/${b['id']}'),
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.goldLight,
                          child: Text(
                            (b['customerName'] as String? ?? 'C').substring(0, 1).toUpperCase(),
                            style: AppText.label().copyWith(color: AppColors.maroon),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b['customerName'] as String? ?? 'Customer', style: AppText.label()),
                              Text('${b['eventDate']} · ${b['bookingCode'] ?? b['id']}', style: AppText.body()),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.maroon),
                          onPressed: () => launchPhoneCall(b['customerPhone'] as String? ?? ''),
                        ),
                        StatusBadge(label: b['paymentStatus'] as String? ?? b['status'] as String? ?? 'pending'),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),
          MfPrimaryButton(label: 'New Booking', icon: Icons.add, onPressed: () => context.push('/calendar')),
          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }
}
