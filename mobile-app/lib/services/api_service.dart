import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/api_errors.dart';
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

  Future<Map<String, dynamic>> _request(Future<http.Response> Function() call) async {
    try {
      final res = await call().timeout(const Duration(seconds: 20));
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw mapRequestError(error);
    }
  }

  Future<List<dynamic>> _requestList(Future<http.Response> Function() call, String key) async {
    final body = await _request(call);
    return body[key] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> fetchHealth() async {
    return _request(() => _client.get(Uri.parse('${ApiConfig.baseUrl}/health')));
  }

  Future<List<dynamic>> fetchPlans() async {
    return _requestList(
      () => _client.get(Uri.parse('${ApiConfig.baseUrl}/api/subscription/plans?currency=PKR')),
      'plans',
    );
  }

  Future<List<dynamic>> fetchRoles() async {
    return _requestList(
      () => _client.get(Uri.parse('${ApiConfig.baseUrl}/api/roles')),
      'roles',
    );
  }

  Future<void> requestPasswordReset(String phone) async {
    await _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
          headers: _headers(),
          body: jsonEncode({'phone': phone}),
        ));
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    String? role,
    bool remember = true,
  }) async {
    final body = await _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
          headers: _headers(),
          body: jsonEncode({'phone': phone, 'password': password, if (role != null) 'role': role}),
        ));
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
    final body = await _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/register-owner'),
          headers: _headers(),
          body: jsonEncode({
            'name': name,
            'phone': phone,
            'password': password,
            'businessName': businessName,
            'address': address,
          }),
        ));
    await setToken(body['token'] as String);
    return body;
  }

  Future<Map<String, dynamic>> fetchMe() async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> fetchSubscriptionStatus() async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/subscription/status'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> startTrial(String planId) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/subscription/start-trial'),
          headers: _headers(auth: true),
          body: jsonEncode({'planId': planId}),
        ));
  }

  Future<Map<String, dynamic>> checkoutPlan(String planId) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/subscription/checkout'),
          headers: _headers(auth: true),
          body: jsonEncode({'planId': planId}),
        ));
  }

  Future<Map<String, dynamic>> requestCustomPlan({
    required int requestedTeamSize,
    required String contactName,
    required String phone,
    String? note,
  }) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/subscription/custom-plan-request'),
          headers: _headers(auth: true),
          body: jsonEncode({
            'requestedTeamSize': requestedTeamSize,
            'contactName': contactName,
            'phone': phone,
            'note': note,
          }),
        ));
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/dashboard/summary'),
          headers: _headers(auth: true),
        ));
  }

  Future<List<dynamic>> fetchBookings({
    String? search,
    String? bookingStatus,
    String? paymentStatus,
    String? eventType,
    String? sort,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (bookingStatus != null && bookingStatus.isNotEmpty) params['bookingStatus'] = bookingStatus;
    if (paymentStatus != null && paymentStatus.isNotEmpty) params['paymentStatus'] = paymentStatus;
    if (eventType != null && eventType.isNotEmpty) params['eventType'] = eventType;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/bookings').replace(queryParameters: params.isEmpty ? null : params);
    return _requestList(() => _client.get(uri, headers: _headers(auth: true)), 'bookings');
  }

  Future<Map<String, dynamic>> fetchBooking(String id) async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/bookings'),
          headers: _headers(auth: true),
          body: jsonEncode(payload),
        ));
  }

  Future<Map<String, dynamic>> updateBooking(String id, Map<String, dynamic> payload) async {
    return _request(() => _client.patch(
          Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id'),
          headers: _headers(auth: true),
          body: jsonEncode(payload),
        ));
  }

  Future<Map<String, dynamic>> shareBooking(String id) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id/share'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> fetchCalendarMonth(String month) async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/calendar/month?month=$month'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> fetchCalendarDayBookings(String date) async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/calendar/day-bookings?date=$date'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> fetchCalendarDay(String date) async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/calendar/day?date=$date'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> fetchPaymentsSummary() async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/payments/summary'),
          headers: _headers(auth: true),
        ));
  }

  Future<List<dynamic>> fetchPayments({String? date}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/payments').replace(
      queryParameters: date != null && date.isNotEmpty ? {'date': date} : null,
    );
    return _requestList(() => _client.get(uri, headers: _headers(auth: true)), 'payments');
  }

  Future<Map<String, dynamic>> recordPayment({
    required String bookingId,
    required num amount,
    String paymentType = 'partial',
    String? note,
  }) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/payments/booking-payments'),
          headers: _headers(auth: true),
          body: jsonEncode({
            'bookingId': bookingId,
            'amount': amount,
            'paymentType': paymentType,
            'note': note,
          }),
        ));
  }

  Future<List<dynamic>> fetchPackages({bool includeInactive = false}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/packages').replace(
      queryParameters: includeInactive ? {'includeInactive': 'true'} : null,
    );
    return _requestList(() => _client.get(uri, headers: _headers(auth: true)), 'packages');
  }

  Future<Map<String, dynamic>> createPackage(Map<String, dynamic> payload) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/packages'),
          headers: _headers(auth: true),
          body: jsonEncode(payload),
        ));
  }

  Future<Map<String, dynamic>> updatePackage(String id, Map<String, dynamic> payload) async {
    return _request(() => _client.patch(
          Uri.parse('${ApiConfig.baseUrl}/api/packages/$id'),
          headers: _headers(auth: true),
          body: jsonEncode(payload),
        ));
  }

  Future<Map<String, dynamic>> deactivatePackage(String id) async {
    return _request(() => _client.delete(
          Uri.parse('${ApiConfig.baseUrl}/api/packages/$id'),
          headers: _headers(auth: true),
        ));
  }

  Future<Map<String, dynamic>> fetchMePermissions() async {
    final me = await fetchMe();
    return me['permissions'] as Map<String, dynamic>? ?? {};
  }

  Future<List<dynamic>> fetchEventTypes() async {
    return _requestList(
      () => _client.get(Uri.parse('${ApiConfig.baseUrl}/api/bookings/event-types'), headers: _headers(auth: true)),
      'eventTypes',
    );
  }

  Future<Map<String, dynamic>> fetchTeamUsage() async {
    return _request(() => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/team/usage'),
          headers: _headers(auth: true),
        ));
  }

  Future<List<dynamic>> fetchTeamMembers() async {
    return _requestList(
      () => _client.get(Uri.parse('${ApiConfig.baseUrl}/api/team/members'), headers: _headers(auth: true)),
      'members',
    );
  }

  Future<Map<String, dynamic>> inviteTeamMember({
    required String name,
    required String phone,
    required String role,
    Map<String, dynamic>? permissions,
  }) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/team/invite'),
          headers: _headers(auth: true),
          body: jsonEncode({
            'name': name,
            'phone': phone,
            'role': role,
            'permissions': permissions,
          }),
        ));
  }

  Future<Map<String, dynamic>> updateTeamMember(String id, Map<String, dynamic> patch) async {
    return _request(() => _client.patch(
          Uri.parse('${ApiConfig.baseUrl}/api/team/members/$id'),
          headers: _headers(auth: true),
          body: jsonEncode(patch),
        ));
  }

  Future<Map<String, dynamic>> fetchInviteByToken(String token) async {
    return _request(() => _client.get(Uri.parse('${ApiConfig.baseUrl}/api/team/invites/$token')));
  }

  Future<Map<String, dynamic>> acceptInvite({required String token, required String password}) async {
    return _request(() => _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/team/invites/$token/accept'),
          headers: _headers(),
          body: jsonEncode({'password': password}),
        ));
  }

  Future<List<dynamic>> fetchNotifications() async {
    return _requestList(
      () => _client.get(Uri.parse('${ApiConfig.baseUrl}/api/notifications'), headers: _headers(auth: true)),
      'notifications',
    );
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
