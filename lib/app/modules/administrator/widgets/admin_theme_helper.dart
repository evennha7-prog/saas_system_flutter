import 'package:flutter/material.dart';
import '../../../themes/themes.dart';

class AdminTheme {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color primaryGold = Color(0xFFFFB300);

  static Color getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'enterprise':
        return const Color(0xFF8E24AA);
      case 'pro':
        return const Color(0xFF0288D1);
      default:
        return primaryBlue;
    }
  }

  static Color getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return const Color(0xFF8E24AA);
      case 'store_admin':
        return primaryBlue;
      case 'cashier':
        return const Color(0xFF0288D1);
      case 'barista':
        return const Color(0xFF2E7D32);
      case 'stock_admin':
        return const Color(0xFFF57C00);
      default:
        return Colors.grey;
    }
  }

  static String getRoleLabel(String role) {
    switch (role) {
      case 'super_admin':
        return 'SUPER ADMIN';
      case 'store_admin':
        return 'STORE MANAGER';
      case 'cashier':
        return 'CASHIER';
      case 'barista':
        return 'BARISTA';
      case 'stock_admin':
        return 'STOCK ADMIN';
      default:
        return role.toUpperCase();
    }
  }

  static Widget buildSectionHeader(BuildContext context, String title, IconData icon, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }

  static Widget buildBadge({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryBlue
                : (isDark ? AppThemes.darkSurface : const Color(0xFFEEF2F6)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primaryBlue : (isDark ? AppThemes.darkBorder : Colors.transparent),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppThemes.darkTextSecondary : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }
}
