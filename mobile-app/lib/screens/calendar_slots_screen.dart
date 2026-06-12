import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

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
  String? _selectedDate;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    final month = DateFormat('yyyy-MM').format(_focused);
    try {
      final data = await widget.api.fetchCalendarMonth(month);
      setState(() => _monthData = data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _selectDay(DateTime day) async {
    final date = DateFormat('yyyy-MM-dd').format(day);
    setState(() {
      _selectedDate = date;
      _dayData = null;
    });
    try {
      final data = await widget.api.fetchCalendarDay(date);
      setState(() => _dayData = data);
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

  @override
  Widget build(BuildContext context) {
    final days = (_monthData?['days'] as List<dynamic>?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar & Slots')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        _focused = DateTime(_focused.year, _focused.month - 1);
                        _loadMonth();
                      },
                    ),
                    Text(DateFormat('MMMM yyyy').format(_focused), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        _focused = DateTime(_focused.year, _focused.month + 1);
                        _loadMonth();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: days.map((d) {
                    final day = d as Map<String, dynamic>;
                    final dateStr = day['date'] as String;
                    final parts = dateStr.split('-');
                    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                    final selected = _selectedDate == dateStr;
                    return ChoiceChip(
                      label: Text('${dt.day}'),
                      selected: selected,
                      onSelected: (_) => _selectDay(dt),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (_selectedDate != null) Text('Slots for $_selectedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_dayData == null && _selectedDate != null)
                  const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
                else if (_dayData != null) ...[
                  ...((_dayData!['slots'] as List<dynamic>?) ?? []).map((s) {
                    final slot = s as Map<String, dynamic>;
                    final full = slot['bookedCount'] >= slot['capacity'];
                    return Card(
                      child: ListTile(
                        title: Text(slot['slotName'] as String? ?? 'Slot'),
                        subtitle: Text('${slot['startTime']} - ${slot['endTime']} · ${slot['bookedCount']}/${slot['capacity']} booked'),
                        trailing: full
                            ? const Chip(label: Text('Full'))
                            : ElevatedButton(onPressed: () => _openBooking(slot), child: const Text('Select')),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
