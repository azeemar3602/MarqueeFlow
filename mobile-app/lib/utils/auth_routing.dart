import '../services/api_service.dart';

Future<String> resolveAuthenticatedRoute(MarqueeFlowApi api) async {
  final me = await api.fetchMe();
  final business = me['business'] as Map<String, dynamic>?;
  final approval = business?['approvalStatus'] as String?;
  final status = business?['status'] as String?;

  if (approval == 'pending') return '/pending-approval';
  if (approval == 'rejected' || approval == 'suspended' || status == 'suspended') {
    return '/pending-approval';
  }

  final sub = await api.fetchSubscriptionStatus();
  final subStatus = sub['status'] as String? ?? 'none';
  final active = subStatus == 'trial' || subStatus == 'active';
  return active ? '/home' : '/subscription';
}
