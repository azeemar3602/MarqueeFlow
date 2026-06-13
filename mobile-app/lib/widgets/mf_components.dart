import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MfLogo extends StatelessWidget {
  const MfLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 2),
        color: AppColors.maroon,
      ),
      alignment: Alignment.center,
      child: Text(
        'MF',
        style: AppText.brandName(size: size * 0.34).copyWith(color: AppColors.gold),
      ),
    );
  }
}

class MfAppHeader extends StatelessWidget {
  const MfAppHeader({
    super.key,
    this.notificationCount = 0,
    this.onMenu,
    this.onNotifications,
  });

  final int notificationCount;
  final VoidCallback? onMenu;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const MfLogo(size: 36),
          const SizedBox(width: 10),
          Text('MarqueeFlow', style: AppText.brandName(size: 18)),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onNotifications,
                icon: const Icon(Icons.notifications_none, color: AppColors.maroon),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.maroon, shape: BoxShape.circle),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: onMenu ?? () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.maroon),
          ),
        ],
      ),
    );
  }
}

class MfScreenShell extends StatelessWidget {
  const MfScreenShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showHeader = true,
    this.showFooter = true,
    this.notificationCount = 0,
    this.actions,
    this.endDrawer,
    this.onBack,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showHeader;
  final bool showFooter;
  final int notificationCount;
  final List<Widget>? actions;
  final Widget? endDrawer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      endDrawer: endDrawer,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) MfAppHeader(notificationCount: notificationCount),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (onBack != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: AppColors.maroon),
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (title != null) ...[
                      Text(title!, style: AppText.display(title!)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(subtitle!, style: AppText.body()),
                      ],
                      const SizedBox(height: 20),
                    ],
                    if (actions != null) ...[
                      Row(children: actions!),
                      const SizedBox(height: 12),
                    ],
                    child,
                  ],
                ),
              ),
            ),
            if (showFooter) const MfScreenFooter(),
          ],
        ),
      ),
    );
  }
}

class MfAuthShell extends StatelessWidget {
  const MfAuthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const MfLogo(size: 72),
            const SizedBox(height: 12),
            Text('MarqueeFlow', style: AppText.brandName(size: 28)),
            const SizedBox(height: 6),
            Text('Manage. Book. Celebrate.', style: AppText.body()),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.maroon.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
            const MfScreenFooter(),
          ],
        ),
      ),
    );
  }
}

class MfFieldIcon extends StatelessWidget {
  const MfFieldIcon(this.letter, {super.key});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.only(left: 12, right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.5),
        color: AppColors.cream,
      ),
      alignment: Alignment.center,
      child: Text(letter, style: AppText.label().copyWith(color: AppColors.maroon)),
    );
  }
}

class MfTextField extends StatelessWidget {
  const MfTextField({
    super.key,
    required this.label,
    required this.iconLetter,
    this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.enabled = true,
    this.onSubmitted,
  });

  final String label;
  final String iconLetter;
  final TextEditingController? controller;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label()),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: MfFieldIcon(iconLetter),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class MfPrimaryButton extends StatelessWidget {
  const MfPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class MfErrorBanner extends StatelessWidget {
  const MfErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, height: 1.4))),
        ],
      ),
    );
  }
}

class MfBadge extends StatelessWidget {
  const MfBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.badgeTan,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.label().copyWith(color: AppColors.maroonDark, fontSize: 12),
      ),
    );
  }
}

class MfCard extends StatelessWidget {
  const MfCard({super.key, required this.child, this.highlighted = false, this.badge});

  final Widget child;
  final bool highlighted;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: badge != null ? 10 : 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlighted ? AppColors.gold : AppColors.border, width: highlighted ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
        if (badge != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: AppText.eyebrow('').copyWith(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MfScreenFooter extends StatelessWidget {
  const MfScreenFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(height: 1, width: 120, color: AppColors.gold.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          Icon(Icons.favorite, size: 14, color: AppColors.gold.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}

class MfCaption extends StatelessWidget {
  const MfCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(text, textAlign: TextAlign.center, style: AppText.body().copyWith(fontSize: 13)),
    );
  }
}

class MfLoadingBox extends StatelessWidget {
  const MfLoadingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
    );
  }
}

class MfSearchBar extends StatelessWidget {
  const MfSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSearch,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const MfFieldIcon('S'),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: AppColors.maroon),
          onPressed: onSearch,
        ),
      ),
    );
  }
}

class MfDetailRow extends StatelessWidget {
  const MfDetailRow(this.label, this.value, {super.key});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppText.body().copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value ?? '—', style: AppText.label())),
        ],
      ),
    );
  }
}

class MfDayChip extends StatelessWidget {
  const MfDayChip({
    super.key,
    required this.day,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final String state;
  final VoidCallback onTap;

  Color _bg() {
    if (selected) return AppColors.maroon;
    switch (state) {
      case 'full':
        return AppColors.soloAccent;
      case 'partial':
        return AppColors.goldLight;
      default:
        return AppColors.teamAccent;
    }
  }

  Color _fg() => selected ? Colors.white : AppColors.text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _bg(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.maroon : AppColors.border),
        ),
        child: Text('$day', style: AppText.label().copyWith(color: _fg())),
      ),
    );
  }
}

class MfOutlinedAction extends StatelessWidget {
  const MfOutlinedAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
