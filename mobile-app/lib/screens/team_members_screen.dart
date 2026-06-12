import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final canInvite = _usage?['canInvite'] == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: canInvite ? () => context.push('/team/invite') : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Plan: ${_usage?['planName'] ?? _usage?['planId'] ?? '—'}'),
                      subtitle: Text('Members: ${_usage?['used'] ?? 0} / ${_usage?['limit'] ?? 0}'),
                      trailing: canInvite
                          ? null
                          : TextButton(onPressed: () => context.push('/subscription'), child: const Text('Upgrade')),
                    ),
                  ),
                  if (!canInvite)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Member limit reached. Upgrade your plan to invite more team members.',
                        style: TextStyle(color: Color(0xFF434753)),
                      ),
                    ),
                  const Text('Team', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_members.isEmpty)
                    const Card(child: ListTile(title: Text('No team members yet')))
                  else
                    ..._members.map((m) {
                      final member = m as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(member['name'] as String? ?? 'Member'),
                          subtitle: Text('${member['phone'] ?? ''} · ${member['role']}'),
                          trailing: Chip(label: Text(member['role'] as String? ?? 'staff')),
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: canInvite ? () => context.push('/team/invite') : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Invite Team Member'),
                  ),
                ],
              ),
            ),
    );
  }
}
