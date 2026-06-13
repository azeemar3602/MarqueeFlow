import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<dynamic> _customers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final bookings = await widget.api.fetchBookings();
      final map = <String, Map<String, dynamic>>{};
      for (final raw in bookings) {
        final b = raw as Map<String, dynamic>;
        final key = b['customerPhone'] as String? ?? b['customerName'] as String? ?? '';
        map.putIfAbsent(key, () => {'name': b['customerName'], 'phone': b['customerPhone'], 'bookings': 0});
        map[key]!['bookings'] = (map[key]!['bookings'] as int) + 1;
      }
      setState(() => _customers = map.values.toList());
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MfScreenShell(
      title: 'Customers',
      subtitle: 'Contacts from your booking history.',
      endDrawer: buildMfDrawer(widget.api, '/customers'),
      onBack: () => mfGoBack(context, fallback: '/home'),
      child: _loading
          ? const MfLoadingBox()
          : _customers.isEmpty
              ? MfCard(child: Text('No customers yet', style: AppText.body()))
              : Column(
                  children: _customers.map((c) {
                    final row = c as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MfCard(
                        child: Row(
                          children: [
                            Expanded(child: Text(row['name'] as String? ?? '', style: AppText.label())),
                            Text('${row['bookings']} bookings', style: AppText.body()),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
