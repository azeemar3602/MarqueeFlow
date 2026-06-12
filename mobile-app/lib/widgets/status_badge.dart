import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  Color _resolveColor() {
    if (color != null) return color!;
    final lower = label.toLowerCase();
    if (lower.contains('paid') || lower.contains('confirm') || lower.contains('active')) {
      return const Color(0xFF059669);
    }
    if (lower.contains('pending') || lower.contains('partial')) {
      return const Color(0xFFD97706);
    }
    if (lower.contains('cancel') || lower.contains('expired')) {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFF317EE5);
  }

  @override
  Widget build(BuildContext context) {
    final c = _resolveColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
