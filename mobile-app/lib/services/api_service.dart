import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';

class MarqueeFlowApi {
  MarqueeFlowApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> fetchHealth() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/health');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Health check failed (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchPlans() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/plans');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Plans request failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['plans'] as List<dynamic>;
  }
}
