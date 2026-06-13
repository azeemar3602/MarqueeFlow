import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';
import '../widgets/status_badge.dart';
import '../utils/api_errors.dart';

class CalendarSlotsScreen extends StatefulWidget {
  const CalendarSlotsScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<CalendarSlotsScreen> createState() => _CalendarSlotsScreenState();
}

class _CalendarSlotsScreenState extends State<CalendarSlotsScreen> {
  DateTime _focused = DateTime.now();
  Map<String, dynamic>? _monthData;
  Map<String, dynamic>? _dayData;
  List<dynamic> _dayBookings = [];
  String? _selectedDate;
  bool _loading = true;
  bool _showDayBookings = false;
  String? _error;
  String? _dayError;

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final month = DateFormat('yyyy-MM').format(_focused);
    try {
      final data = await widget.api.fetchCalendarMonth(month);
      setState(() => _monthData = data);
    } catch (e) {
      if (mounted) setState(() => _error = mapRequestError(e).message);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _selectDay(DateTime day) async {
    final date = DateFormat('yyyy-MM-dd').format(day);
    setState(() {
      _selectedDate = date;
      _dayData = null;
      _dayBookings = [];
      _showDayBookings = false;
      _dayError = null;
    });
    try {
      final data = await widget.api.fetchCalendarDay(date);
      setState(() => _dayData = data);
    } catch (e) {
      if (mounted) setState(() => _dayError = mapRequestError(e).message);
    }
  }

  Future<void> _loadDayBookings() async {
    if (_selectedDate == null) return;
    setState(() => _showDayBookings = true);
    try {
      final data = await widget.api.fetchCalendarDayBookings(_selectedDate!);
      setState(() => _dayBookings = data['bookings'] as List<dynamic>? ?? []);
    } catch (_) {}
  }

  void _openBooking(Map<String, dynamic> slot) {
    if (_selectedDate == null) return;
    context.push('/bookings/new', extra: {
      'eventDate': _selectedDate,
      'slotId': slot['id'],
      'slotName': slot['slotName'],
    });
  }

  String _dayState(Map<String, dynamic> day) {
    final state = (day['state'] as String?)?.toLowerCase() ?? '';
    if (state.contains('fully') || state.contains('full')) return 'full';
    if (state.contains('partial')) return 'partial';
    return 'available';
  }

  @override
  Widget build(BuildContext context) {
    final days = (_monthData?['days'] as List<dynamic>?) ?? [];

    return MfScreenShell(
      title: 'Calendar & Slots',
      subtitle: 'Select a date, then choose an available slot.',
      endDrawer: buildMfDrawer(widget.api, '/calendar'),
      onBack: () => mfGoBack(context, fallback: '/home'),
      child: _loading
          ? const MfLoadingBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  MfErrorBanner(_error!),
                  TextButton(onPressed: _loadMonth, child: const Text('Retry')),
                  const SizedBox(height: 12),
                ],
                MfCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppColors.maroon),
                        onPressed: () {
                          _focused = DateTime(_focused.year, _focused.month - 1);
                          _loadMonth();
                        },
                      ),
                      Text(DateFormat('MMMM yyyy').format(_focused), style: AppText.display('', size: 20)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppColors.maroon),
                        onPressed: () {
                          _focused = DateTime(_focused.year, _focused.month + 1);
                          _loadMonth();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _legend('Available', AppColors.teamAccent),
                    _legend('Partial', AppColors.goldLight),
                    _legend('Full', AppColors.soloAccent),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: days.map((raw) {
                    final day = raw as Map<String, dynamic>;
                    final dateStr = day['date'] as String;
                    final parts = dateStr.split('-');
                    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                    return MfDayChip(
                      day: dt.day,
                      selected: _selectedDate == dateStr,
                      state: _dayState(day),
                      onTap: () => _selectDay(dt),
                    );
                  }).toList(),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Text('Slots for $_selectedDate', style: AppText.display('Available slots', size: 22))),
                      MfOutlinedAction(label: 'View Day Bookings', icon: Icons.list_alt, onPressed: _loadDayBookings),
                    ],
                  ),
                  if (_showDayBookings) ...[
                    const SizedBox(height: 12),
                    if (_dayBookings.isEmpty)
                      MfCard(child: Text('No bookings on this date', style: AppText.body()))
                    else
                      ..._dayBookings.map((raw) {
                        final b = raw as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MfCard(
                            child: InkWell(
                              onTap: () => context.push('/bookings/${b['id']}'),
                              child: Row(
                                children: [
                                  Expanded(child: Text('${b['customerName']} · ${b['eventType']}', style: AppText.label())),
                                  StatusBadge(label: b['status'] as String? ?? 'pending'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                  const SizedBox(height: 12),
                  if (_dayError != null) MfErrorBanner(_dayError!),
                  if (_dayData == null && _dayError == null)
                    const MfLoadingBox()
                  else
                    ...((_dayData!['slots'] as List<dynamic>?) ?? []).map((raw) {
                      final slot = raw as Map<String, dynamic>;
                      final status = (slot['status'] as String?)?.toLowerCase() ?? '';
                      final blocked = status == 'blocked';
                      final full = blocked || status == 'full' ||
                          (slot['bookedCount'] as num? ?? 0) >= (slot['capacity'] as num? ?? 0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MfCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(slot['slotName'] as String? ?? 'Slot', style: AppText.label()),
                                    Text(
                                      '${slot['startTime']} - ${slot['endTime']} · ${slot['bookedCount']}/${slot['capacity']} booked',
                                      style: AppText.body(),
                                    ),
                                  ],
                                ),
                              ),
                              if (full)
                                MfBadge(blocked ? 'Blocked' : 'Full')
                              else
                                SizedBox(
                                  width: 96,
                                  child: ElevatedButton(
                                    onPressed: () => _openBooking(slot),
                                    child: const Text('Select'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ],
            ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: AppText.body().copyWith(fontSize: 12)),
      ],
    );
  }
}
