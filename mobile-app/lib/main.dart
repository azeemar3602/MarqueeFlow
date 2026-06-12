import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MarqueeFlowApp());
}

class MarqueeFlowApp extends StatelessWidget {
  const MarqueeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarqueeFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF317EE5)),
        useMaterial3: true,
      ),
      home: const BookingHomePage(),
    );
  }
}

class BookingHomePage extends StatefulWidget {
  const BookingHomePage({super.key});

  @override
  State<BookingHomePage> createState() => _BookingHomePageState();
}

class _BookingHomePageState extends State<BookingHomePage> {
  final _api = MarqueeFlowApi();
  String _status = 'Loading API...';
  List<dynamic> _plans = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final health = await _api.fetchHealth();
      final plans = await _api.fetchPlans();
      setState(() {
        _status = 'API: ${health['service']}';
        _plans = plans;
      });
    } catch (error) {
      setState(() {
        _status = 'API error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MarqueeFlow Booking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_status),
          const SizedBox(height: 16),
          const Text('Subscription plans (PKR)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._plans.map((plan) {
            final name = plan['name'] as String? ?? 'Plan';
            final price = plan['pricePkr'];
            final custom = plan['requestCustom'] == true;
            return ListTile(
              title: Text(name),
              subtitle: Text(custom ? 'Request custom plan' : 'PKR $price / month'),
            );
          }),
        ],
      ),
    );
  }
}
