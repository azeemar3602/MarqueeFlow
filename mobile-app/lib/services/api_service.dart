import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

class MarqueeFlowApi {
  MarqueeFlowApi({http.Client? client, AuthStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? AuthStorage();

  final http.Client _client;
  final AuthStorage _storage;
  String? _token;

  Future<void> loadToken() async {
    _token = await _storage.getToken();
  }

  Future<void> setToken(String? token, {bool remember = true}) async {
    _token = token;
    if (token == null) {
      await _storage.clear();
    } else {
      await _storage.saveToken(token, remember: remember);
    }
  }

  Map<String, String> _headers({bool auth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && _token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }
    if (response.statusCode >= 400) {
      final err = body?['error'] as Map<String, dynamic>?;
      throw ApiException(
        err?['message'] as String? ?? 'Request failed (${response.statusCode})',
        code: err?['code'] as String?,
      );
    }
    return body ?? {};
  }

  Future<Map<String, dynamic>> fetchHealth() async {
    final res = await _client.get(Uri.parse('${ApiConfig.baseUrl}/api/health'));
    return _decode(res);
  }

  Future<List<dynamic>> fetchPlans() async {
    final res = await _client.get(Uri.parse('${ApiConfig.baseUrl}/api/subscription/plans?currency=PKR'));
    final body = await _decode(res);
    return body['plans'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> fetchRoles() async {
    final res = await _client.get(Uri.parse('${ApiConfig.baseUrl}/api/roles'));
    final body = await _decode(res);
    return body['roles'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    String? role,
    bool remember = true,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: _headers(),
      body: jsonEncode({'phone': phone, 'password': password, if (role != null) 'role': role}),
    );
    final body = await _decode(res);
    await setToken(body['token'] as String, remember: remember);
    return body;
  }

  Future<Map<String, dynamic>> registerOwner({
    required String name,
    required String phone,
    required String password,
    required String businessName,
    String? address,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register-owner'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'password': password,
        'businessName': businessName,
        'address': address,
      }),
    );
    final body = await _decode(res);
    await setToken(body['token'] as String);
    return body;
  }

  Future<Map<String, dynamic>> fetchMe() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> fetchSubscriptionStatus() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/subscription/status'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> startTrial(String planId) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/subscription/start-trial'),
      headers: _headers(auth: true),
      body: jsonEncode({'planId': planId}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> checkoutPlan(String planId) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/subscription/checkout'),
      headers: _headers(auth: true),
      body: jsonEncode({'planId': planId}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> requestCustomPlan({
    required int requestedTeamSize,
    required String contactName,
    required String phone,
    String? note,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/subscription/custom-plan-request'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'requestedTeamSize': requestedTeamSize,
        'contactName': contactName,
        'phone': phone,
        'note': note,
      }),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/dashboard/summary'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<List<dynamic>> fetchBookings({String? search}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/bookings').replace(
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final res = await _client.get(uri, headers: _headers(auth: true));
    final body = await _decode(res);
    return body['bookings'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> fetchBooking(String id) async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/bookings'),
      headers: _headers(auth: true),
      body: jsonEncode(payload),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> updateBooking(String id, Map<String, dynamic> payload) async {
    final res = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id'),
      headers: _headers(auth: true),
      body: jsonEncode(payload),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> shareBooking(String id) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id/share'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> fetchCalendarMonth(String month) async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/calendar/month?month=$month'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> fetchCalendarDay(String date) async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/calendar/day?date=$date'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> fetchPaymentsSummary() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/payments/summary'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<List<dynamic>> fetchPayments() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/payments'),
      headers: _headers(auth: true),
    );
    final body = await _decode(res);
    return body['payments'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> recordPayment({
    required String bookingId,
    required num amount,
    String paymentType = 'partial',
    String? note,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/payments/booking-payments'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'bookingId': bookingId,
        'amount': amount,
        'paymentType': paymentType,
        'note': note,
      }),
    );
    return _decode(res);
  }

  Future<List<dynamic>> fetchPackages() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/packages'),
      headers: _headers(auth: true),
    );
    final body = await _decode(res);
    return body['packages'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> fetchEventTypes() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/bookings/event-types'),
      headers: _headers(auth: true),
    );
    final body = await _decode(res);
    return body['eventTypes'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> fetchTeamUsage() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/team/usage'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<List<dynamic>> fetchTeamMembers() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/team/members'),
      headers: _headers(auth: true),
    );
    final body = await _decode(res);
    return body['members'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> inviteTeamMember({
    required String name,
    required String phone,
    required String role,
    Map<String, dynamic>? permissions,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/team/invite'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'role': role,
        'permissions': permissions,
      }),
    );
    return _decode(res);
  }

  Future<List<dynamic>> fetchNotifications() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/notifications'),
      headers: _headers(auth: true),
    );
    final body = await _decode(res);
    return body['notifications'] as List<dynamic>? ?? [];
  }

  Future<void> logout() async {
    try {
      await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
        headers: _headers(auth: true),
      );
    } catch (_) {}
    await setToken(null);
  }
}
