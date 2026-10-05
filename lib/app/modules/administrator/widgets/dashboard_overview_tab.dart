import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../screens/account_approvals_screen.dart';
import '../../../screens/add_platform_user_screen.dart';
import '../../../screens/broadcast_notice_screen.dart';
import '../../../screens/cloud_backup_screen.dart';
import '../../../screens/edit_profile_screen.dart';
import '../../../screens/new_store_registered_screen.dart';
import '../../../screens/pos_terminals_screen.dart';
import '../../../screens/revenue_outlet.dart';
import '../../../screens/security_notice_screen.dart';
import '../../../screens/store_activated_screen.dart';
import '../../../screens/store_suspended_screen.dart';
import '../../../screens/system_audit_logs_screen.dart';
import '../../../themes/themes.dart';
import '../controllers/administrator_controller.dart';
import 'admin_theme_helper.dart';
import 'stacked_revenue_chart.dart';

class DashboardOverviewTab extends StatelessWidget {
  final AdministratorController controller;
  const DashboardOverviewTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshDashboardData,
      color: AdminTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Super Admin Identity Header
            _buildSuperAdminHeader(context),
            const SizedBox(height: 18),

            // Pending Approvals Banner (If any)
            _buildPendingApplicationsBanner(context),

            // 4 KPI Metric Cards (2x2 Grid)
            _buildMetricCardsGrid(context),
            const SizedBox(height: 18),

            // 4 Platform Quick Actions (As shown in screenshot!)
            AdminTheme.buildSectionHeader(
              context,
              'platform_quick_actions'.tr,
              Icons.bolt_rounded,
            ),
            const SizedBox(height: 8),
            _buildQuickActionShortcuts(context),
            const SizedBox(height: 18),

            // Multi-Phase Stacked Revenue Chart (Pre-IP, IP1, IP2)
            AdminTheme.buildSectionHeader(
              context,
              'multi_phase_stacked_revenue'.tr,
              Icons.stacked_bar_chart_rounded,
            ),
            const SizedBox(height: 8),
            const StackedRevenueChart(),
            const SizedBox(height: 18),

            // Store Performance Breakdown (Revenue by Outlet)
            AdminTheme.buildSectionHeader(
              context,
              'revenue_by_outlet'.tr,
              Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 8),
            _buildStoreRevenueBreakdown(context),
            const SizedBox(height: 18),

            // Recent Activity Log Stream (With Click to View Details)
            AdminTheme.buildSectionHeader(
              context,
              'recent_platform_activity'.tr,
              Icons.history_rounded,
            ),
            const SizedBox(height: 4),
            _buildRecentActivityList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. Super Admin Profile Header Card
  // ==========================================
  Widget _buildSuperAdminHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Orange circular avatar matching design
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AdminTheme.primaryBlue,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User details: Name, Role, Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AudiCafe Admin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'store_manager_account'.tr,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '071 93 93 991',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // Edit icon on the right matching Screenshot 2
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Get.to(() => const EditProfileScreen()),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.edit_outlined,
                  color: isDark ? Colors.white60 : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final rev = controller.totalPlatformRevenue;
      final khr = (rev * 4100).toStringAsFixed(0);

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  title: 'platform_revenue'.tr,
                  value: '\$${rev.toStringAsFixed(2)}',
                  subtitle: '$khr ៛ (${'currency_khr'.tr})',
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFF2E7D32),
                  bgColor: isDark
                      ? const Color(0xFF132A1C)
                      : const Color(0xFFE8F5E9),
                  trend: '+18.4% this mo.',
                  trendPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => Get.to(() => const NewStoreRegisteredScreen()),
                  borderRadius: BorderRadius.circular(16),
                  child: _buildMetricCard(
                    context: context,
                    title: 'total_stores'.tr,
                    value: '${controller.totalStoresCount} Outlets',
                    subtitle:
                        '${controller.activeStoresCount} Active • ${controller.inactiveStoresCount} Off',
                    icon: Icons.storefront_rounded,
                    iconColor: AdminTheme.primaryBlue,
                    bgColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEFF6FF),
                    trend: 'All 4 branches',
                    trendPositive: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Get.to(() => const AddPlatformUserScreen()),
                  borderRadius: BorderRadius.circular(16),
                  child: _buildMetricCard(
                    context: context,
                    title: 'total_users'.tr,
                    value: '${controller.totalUsersCount} ${'accounts_label'.tr}',
                    subtitle: '${'role_super_admin'.tr}, ${'role_store_admin'.tr}, ${'role_cashier'.tr}',
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFF0288D1),
                    bgColor: isDark
                        ? const Color(0xFF102636)
                        : const Color(0xFFE1F5FE),
                    trend: '100% active role',
                    trendPositive: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => Get.to(() => const PosTerminalsScreen()),
                  borderRadius: BorderRadius.circular(16),
                  child: _buildMetricCard(
                    context: context,
                    title: 'pos_terminals_online'.tr,
                    value: '${controller.activePosCount} ${'terminals_label'.tr}',
                    subtitle: '${'latency_label'.tr}: ${controller.serverLatency.value}',

                    icon: Icons.point_of_sale_rounded,
                    iconColor: const Color(0xFF7B1FA2),
                    bgColor: isDark
                        ? const Color(0xFF26122E)
                        : const Color(0xFFF3E5F5),
                    trend: 'Sync WebSocket',
                    trendPositive: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String trend,
    required bool trendPositive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      (trendPositive ? const Color(0xFF4CAF50) : Colors.orange)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: trendPositive
                        ? const Color(0xFF2E7D32)
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppThemes.darkTextSecondary
                  : AppThemes.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppThemes.darkTextSecondary.withValues(alpha: 0.8)
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApplicationsBanner(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final pendingCount = controller.pendingApprovalsCount;
      if (pendingCount == 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF3B1E08), const Color(0xFF281404)]
                  : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFA000).withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA000).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA000),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'pending_approvals_banner_title'.tr} ($pendingCount)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFD54F)
                            : const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pendingCount ${'pending_approvals_banner_sub'.tr}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? const Color(0xFFFFE082)
                            : const Color(0xFF78350F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.changeTab(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'view_info'.tr,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickActionShortcuts(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final actions = [
        {
          'title': 'quick_action_approvals'.tr,
          'icon': Icons.how_to_reg_rounded,
          'color': AdminTheme.primaryBlue,
          'badge': controller.pendingApprovalsCount,
          'onTap': () => controller.changeTab(1),
        },
        {
          'title': 'quick_action_add_user'.tr,
          'icon': Icons.person_add_alt_1_rounded,
          'color': const Color(0xFF0288D1),
          'badge': 0,
          'onTap': () => Get.to(() => const AddPlatformUserScreen()),
        },
        {
          'title': 'quick_action_broadcast'.tr,
          'icon': Icons.campaign_rounded,
          'color': const Color(0xFF8E24AA),
          'badge': 0,
          'onTap': () => Get.to(() => const BroadcastNoticeScreen()),
        },
        {
          'title': 'quick_action_audit_logs'.tr,
          'icon': Icons.file_download_outlined,
          'color': const Color(0xFF2E7D32),
          'badge': 0,
          'onTap': () => Get.to(() => const SystemAuditLogsScreen()),
        },
      ];

      return Row(
        children: actions.map((item) {
          final color = item['color'] as Color;
          final badge = item['badge'] as int? ?? 0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                elevation: isDark ? 0 : 1,
                shadowColor: Colors.black.withValues(alpha: 0.04),
                child: InkWell(
                  onTap: item['onTap'] as VoidCallback,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppThemes.darkBorder
                            : AppThemes.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: color,
                                size: 20,
                              ),
                            ),
                            if (badge > 0)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$badge',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildStoreRevenueBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final total = controller.totalPlatformRevenue > 0
          ? controller.totalPlatformRevenue
          : 1.0;
      final totalStores = controller.stores.length;
      final storesList = controller.stores;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Get.to(() => const RevenueOutletScreen());
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? AppThemes.darkBorder
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AdminTheme.primaryBlue.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Premium Glowing Squircle Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E293B),
                                  const Color(0xFF0F172A),
                                ]
                              : [
                                  const Color(0xFFEFF6FF),
                                  const Color(0xFFDBEAFE),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AdminTheme.primaryBlue.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          color: AdminTheme.primaryBlue,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // 2. Middle Title & Amount & Live Pill
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'revenue_by_outlet'.tr,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$totalStores ${Get.locale?.languageCode == 'km' ? 'outlets'.tr : 'Outlets'}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),

                          // Total Revenue in Bold Gradient/Orange
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AdminTheme.primaryBlue,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'total'.tr,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? AppThemes.darkTextSecondary
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Trailing Chevron Action Icon
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AdminTheme.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: AdminTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Multi-Segment Mini Revenue Bar Preview
                if (storesList.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 5.5,
                      child: Row(
                        children: storesList.map((s) {
                          final weight = (s.totalRevenue / total).clamp(0.01, 1.0);
                          final colors = [
                            AdminTheme.primaryBlue,
                            const Color(0xFF38BDF8),
                            const Color(0xFF0288D1),
                            const Color(0xFF10B981),
                            const Color(0xFF8E24AA),
                          ];
                          final color = colors[s.id % colors.length];

                          return Expanded(
                            flex: (weight * 100).toInt().clamp(1, 100),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: s.isActive
                                    ? color
                                    : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // 5. Clean Subtitle Prompt
                Text(
                  'view_revenue_prompt'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRecentActivityList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          ),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.logs.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          ),
          itemBuilder: (context, index) {
            final log = controller.logs[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final t = log.title.toLowerCase();
                  if (t.contains('backup')) {
                    Get.to(() => const CloudBackupScreen());
                  } else if (t.contains('store activated') ||
                      (t.contains('store') && t.contains('activated'))) {
                    Get.to(
                      () => const StoreActivatedScreen(
                        storeId: 2,
                        storeName: 'AudiCafe BKK1 Branch',
                        branchName: 'BKK1 Flagship (BKK02)',
                        timestamp: 'Just now',
                      ),
                    );
                  } else if (t.contains('store suspended') ||
                      (t.contains('store') && t.contains('suspended'))) {
                    Get.to(
                      () => const StoreSuspendedScreen(
                        storeId: 2,
                        storeName: 'AudiCafe BKK1 Branch',
                        branchName: 'BKK1 Flagship (BKK02)',
                        timestamp: 'Just now',
                      ),
                    );
                  } else if (t.contains('new store') ||
                      t.contains('registered')) {
                    Get.to(() => const AccountApprovalsScreen());
                  } else if (t.contains('pos') || t.contains('terminal')) {
                    Get.to(() => const PosTerminalsScreen());
                  } else if (t.contains('security')) {
                    Get.to(() => const SecurityNoticeScreen());
                  } else {
                    Get.to(() => const SystemAuditLogsScreen());
                  }
                },
                borderRadius: index == 0
                    ? const BorderRadius.vertical(top: Radius.circular(18))
                    : (index == controller.logs.length - 1
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(18),
                            )
                          : BorderRadius.zero),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: log.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(log.icon, color: log.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    log.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  log.timeAgo,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : AppThemes.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              log.description,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppThemes.darkTextSecondary
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
