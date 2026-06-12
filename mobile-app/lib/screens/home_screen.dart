import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await widget.api.fetchDashboard();
      setState(() => _summary = summary);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF317EE5)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Color(0xFF434753), fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = (_summary?['upcoming'] as List<dynamic>?) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.api.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/calendar'),
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
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
                      _statCard('Today', '${_summary?['todayCount'] ?? 0}', Icons.today),
                      const SizedBox(width: 12),
                      _statCard('Pending', '${_summary?['pendingPayments'] ?? 0}', Icons.payments),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statCard('Upcoming', '${_summary?['upcomingCount'] ?? upcoming.length}', Icons.event),
                      const SizedBox(width: 12),
                      _statCard('Available slots', '${_summary?['availableSlotsToday'] ?? 0}', Icons.schedule),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Quick links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(label: const Text('Bookings'), onPressed: () => context.push('/bookings')),
                      ActionChip(label: const Text('Calendar'), onPressed: () => context.push('/calendar')),
                      ActionChip(label: const Text('Payments'), onPressed: () => context.push('/payments')),
                      ActionChip(label: const Text('Team'), onPressed: () => context.push('/team')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Upcoming events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (upcoming.isEmpty)
                    const Card(child: ListTile(title: Text('No upcoming events')))
                  else
                    ...upcoming.take(5).map((b) {
                      final booking = b as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(booking['customerName'] as String? ?? 'Booking'),
                          subtitle: Text('${booking['eventDate']} · ${booking['eventType'] ?? ''}'),
                          trailing: StatusBadge(label: booking['status'] as String? ?? 'pending'),
                          onTap: () => context.push('/bookings/${booking['id']}'),
                        ),
                      );
                    }),
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 1:
              context.push('/bookings');
            case 2:
              context.push('/calendar');
            case 3:
              context.push('/payments');
            case 4:
              context.push('/team');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.payments), label: 'Payments'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Team'),
        ],
      ),
    );
  }
}
