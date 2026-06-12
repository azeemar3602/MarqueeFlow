import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await widget.api.fetchBookings(search: _searchCtrl.text.trim());
      setState(() => _bookings = list);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/calendar')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search bookings',
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _load),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _bookings.isEmpty
                        ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No bookings found')))])
                        : ListView.builder(
                            itemCount: _bookings.length,
                            itemBuilder: (_, i) {
                              final b = _bookings[i] as Map<String, dynamic>;
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: ListTile(
                                  title: Text(b['customerName'] as String? ?? 'Customer'),
                                  subtitle: Text('${b['eventDate']} · ${b['bookingCode'] ?? b['id']}'),
                                  trailing: StatusBadge(label: b['paymentStatus'] as String? ?? b['status'] as String? ?? 'pending'),
                                  onTap: () => context.push('/bookings/${b['id']}'),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
