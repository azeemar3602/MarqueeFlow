import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  Map<String, dynamic>? _usage;
  List<dynamic> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final usage = await widget.api.fetchTeamUsage();
      final members = await widget.api.fetchTeamMembers();
      setState(() {
        _usage = usage;
        _members = members;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'manager':
        return 'Manager';
      case 'head_waiter':
        return 'Waiter Head';
      default:
        return role ?? 'Staff';
    }
  }

  Future<void> _editMember(Map<String, dynamic> member) async {
    if (member['role'] == 'owner') return;
    var role = member['role'] as String? ?? 'manager';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text('Edit member', style: AppText.display('Edit member', size: 22)),
        content: DropdownButtonFormField<String>(
          initialValue: role,
          items: const [
            DropdownMenuItem(value: 'manager', child: Text('Manager')),
            DropdownMenuItem(value: 'head_waiter', child: Text('Waiter Head')),
          ],
          onChanged: (v) => role = v ?? role,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.api.updateTeamMember(member['id'] as String, {'role': role});
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateMember(Map<String, dynamic> member) async {
    if (member['role'] == 'owner') return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text('Deactivate access?', style: AppText.display('Deactivate', size: 22)),
        content: Text('${member['name']} will lose access to this business.', style: AppText.body()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.api.updateTeamMember(member['id'] as String, {'status': 'inactive'});
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canInvite = _usage?['canInvite'] == true;
    final used = _usage?['membersUsed'] ?? _usage?['used'] ?? 0;
    final limit = _usage?['memberLimit'] ?? _usage?['limit'] ?? 0;

    if (_loading) return mfLoadingScreen();

    return MfScreenShell(
      title: 'Team Members',
      subtitle: 'Plan usage and member management.',
      endDrawer: buildMfDrawer(widget.api, '/team'),
      onBack: () => mfGoBack(context, fallback: '/home'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Plan: ${_usage?['plan']?['name'] ?? _usage?['planName'] ?? '—'}', style: AppText.label()),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: limit == 0 ? 0 : (used as num) / (limit as num),
                    minHeight: 8,
                    backgroundColor: AppColors.creamDark,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$used / $limit members used', style: AppText.body()),
                if (!canInvite) ...[
                  const SizedBox(height: 12),
                  MfPrimaryButton(label: 'Upgrade Plan', onPressed: () => context.push('/subscription')),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._members.where((m) => (m as Map)['status'] != 'inactive').map((raw) {
            final member = raw as Map<String, dynamic>;
            final name = member['name'] as String? ?? 'Member';
            final isOwner = member['role'] == 'owner';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MfCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.goldLight,
                          child: Text(_initials(name), style: AppText.label().copyWith(color: AppColors.maroon)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppText.label()),
                              Text(member['phone'] as String? ?? '', style: AppText.body()),
                            ],
                          ),
                        ),
                        MfBadge(_roleLabel(member['role'] as String?)),
                      ],
                    ),
                    if (!isOwner) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: MfOutlinedAction(label: 'Edit role', icon: Icons.edit, onPressed: () => _editMember(member))),
                          const SizedBox(width: 8),
                          Expanded(child: MfOutlinedAction(label: 'Deactivate', icon: Icons.person_off, onPressed: () => _deactivateMember(member))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          MfPrimaryButton(
            label: 'Invite Team Member',
            icon: Icons.add,
            onPressed: canInvite ? () => context.push('/team/invite') : () => context.push('/subscription'),
          ),
          MfCaption(canInvite ? 'Owner can add Manager and Waiter Head users' : 'Member limit reached — upgrade your plan'),
        ],
      ),
    );
  }
}
