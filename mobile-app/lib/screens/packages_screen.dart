import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<dynamic> _packages = [];
  bool _loading = true;
  bool _canManage = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await widget.api.fetchMe();
      final perms = me['permissions'] as Map<String, dynamic>? ?? {};
      final packages = await widget.api.fetchPackages(includeInactive: true);
      setState(() {
        _packages = packages;
        _canManage = me['user']?['role'] == 'owner' || perms['fullAccess'] == true || perms['managePackages'] == true;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final nameCtrl = TextEditingController(text: existing?['name'] as String? ?? '');
    final priceCtrl = TextEditingController(text: '${existing?['price'] ?? ''}');
    final guestCtrl = TextEditingController(text: '${existing?['guestLimit'] ?? ''}');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    final servicesCtrl = TextEditingController(
      text: ((existing?['includedServices'] ?? existing?['inclusionsJson']) as List<dynamic>? ?? []).join(', '),
    );
    var status = existing?['status'] as String? ?? 'active';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: AppColors.cream,
          title: Text(existing == null ? 'New Package' : 'Edit Package', style: AppText.display('', size: 22)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MfTextField(label: 'Package name', iconLetter: 'N', controller: nameCtrl),
                const SizedBox(height: 12),
                MfTextField(label: 'Price (PKR)', iconLetter: 'P', controller: priceCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                MfTextField(label: 'Guest limit', iconLetter: 'G', controller: guestCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                MfTextField(label: 'Description', iconLetter: 'D', controller: descCtrl),
                const SizedBox(height: 12),
                MfTextField(label: 'Included services (comma separated)', iconLetter: 'S', controller: servicesCtrl),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (v) => setDialog(() => status = v ?? 'active'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'name': nameCtrl.text.trim(),
                  'price': num.parse(priceCtrl.text),
                  'guestLimit': int.tryParse(guestCtrl.text) ?? 0,
                  'description': descCtrl.text.trim(),
                  'includedServices': servicesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  'status': status,
                };
                try {
                  if (existing == null) {
                    await widget.api.createPackage(payload);
                  } else {
                    await widget.api.updatePackage(existing['id'] as String, payload);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
                  }
                }
              },
              child: Text(existing == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deactivate(Map<String, dynamic> pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text('Deactivate package?', style: AppText.display('', size: 20)),
        content: Text('${pkg['name']} will be hidden from new bookings.', style: AppText.body()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.api.deactivatePackage(pkg['id'] as String);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MfScreenShell(
      title: 'Packages',
      subtitle: 'Manage marquee hall packages for bookings.',
      onBack: () => mfGoBack(context, fallback: '/home'),
      endDrawer: buildMfDrawer(widget.api, '/packages'),
      child: _loading
          ? const MfLoadingBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_canManage)
                  MfCard(child: Text('View-only access. Ask the owner to grant package management permission.', style: AppText.body())),
                if (_canManage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MfPrimaryButton(label: 'New Package', icon: Icons.add, onPressed: () => _openForm()),
                  ),
                if (_packages.isEmpty)
                  MfCard(child: Text('No packages configured', style: AppText.body()))
                else
                  ..._packages.map((raw) {
                    final p = raw as Map<String, dynamic>;
                    final services = (p['includedServices'] ?? p['inclusionsJson']) as List<dynamic>? ?? [];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MfCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(p['name'] as String? ?? 'Package', style: AppText.label())),
                                MfBadge('${p['status']}'),
                              ],
                            ),
                            Text('PKR ${p['price']}', style: AppText.body()),
                            if ((p['guestLimit'] as num? ?? 0) > 0) Text('Guest limit: ${p['guestLimit']}', style: AppText.body()),
                            if ((p['description'] as String?)?.isNotEmpty == false) Text(p['description'] as String, style: AppText.body()),
                            if (services.isNotEmpty) Text('Includes: ${services.join(', ')}', style: AppText.body()),
                            if (_canManage) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: MfOutlinedAction(label: 'Edit', icon: Icons.edit, onPressed: () => _openForm(existing: p))),
                                  const SizedBox(width: 8),
                                  if (p['status'] == 'active')
                                    Expanded(child: MfOutlinedAction(label: 'Deactivate', icon: Icons.block, onPressed: () => _deactivate(p))),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
