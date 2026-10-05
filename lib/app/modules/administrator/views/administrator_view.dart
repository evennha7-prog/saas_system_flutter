import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../screens/add_platform_user_screen.dart';
import '../../../screens/add_store_screen.dart';
import '../../../screens/system_audit_logs_screen.dart';
import '../../../themes/themes.dart';
import '../controllers/administrator_controller.dart';
import '../widgets/admin_theme_helper.dart';
import '../widgets/approvals_management_tab.dart';
import '../widgets/dashboard_overview_tab.dart';
import '../widgets/stores_management_tab.dart';
import '../widgets/system_engine_health_tab.dart';
import '../widgets/users_and_roles_tab.dart';

class AdministratorView extends GetView<AdministratorController> {
  const AdministratorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    void onBackPress() {
      HapticFeedback.lightImpact();
      // 1. Step-by-step back through internal Administrator tabs & search
      final handledInternally = controller.handleStepBack();
      if (handledInternally) {
        return;
      }

      // 2. If at root of Administrator (Tab 0 with no history), exit back to previous screen
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Get.offAllNamed(Routes.NAVBAR);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onBackPress();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: isDark ? AppThemes.darkCard : AdminTheme.primaryBlue,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
            child: Material(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onBackPress,
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        title: Column(
          children: [
            Text(
              'administrator'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'KITLUY SaaS Engine v2.4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isRefreshing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'refresh_data'.tr,
              onPressed: controller.refreshDashboardData,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            tooltip: 'export_audit_log'.tr,
            onPressed: () => Get.to(() => const SystemAuditLogsScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Tab Navigation Bar
          _buildTopTabBar(context),

          // Tab Content (Modularized)
          Expanded(
            child: Obx(() {
              switch (controller.selectedTabIndex.value) {
                case 0:
                  return DashboardOverviewTab(controller: controller);
                case 1:
                  return ApprovalsManagementTab(controller: controller);
                case 2:
                  return StoresManagementTab(controller: controller);
                case 3:
                  return UsersAndRolesTab(controller: controller);
                case 4:
                  return SystemEngineHealthTab(controller: controller);
                default:
                  return DashboardOverviewTab(controller: controller);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedTabIndex.value == 2) {
          return FloatingActionButton.extended(
            backgroundColor: AdminTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 3,
            onPressed: () => Get.to(() => const AddStoreScreen()),
            icon: const Icon(Icons.add_business_rounded),
            label: Text(
              'add_new_store'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else if (controller.selectedTabIndex.value == 3) {
          return FloatingActionButton.extended(
            backgroundColor: AdminTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 3,
            onPressed: () => Get.to(() => const AddPlatformUserScreen()),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(
              'add_new_user'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    ),
  );
  }

  // ==========================================
  // TOP TAB BAR NAVIGATION
  // ==========================================
  Widget _buildTopTabBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Obx(
          () {
            final pendingCount = controller.pendingApprovalsCount;
            final tabs = [
              {'index': 0, 'icon': Icons.dashboard_rounded, 'label': 'platform_overview'.tr, 'badge': 0},
              {'index': 1, 'icon': Icons.how_to_reg_rounded, 'label': 'account_approvals'.tr, 'badge': pendingCount},
              {'index': 2, 'icon': Icons.store_rounded, 'label': 'stores_management'.tr, 'badge': 0},
              {'index': 3, 'icon': Icons.people_alt_rounded, 'label': 'all_users_roles'.tr, 'badge': 0},
              {'index': 4, 'icon': Icons.dns_rounded, 'label': 'system_engine_health'.tr, 'badge': 0},
            ];

            return Row(
              children: tabs.map((tab) {
                final index = tab['index'] as int;
                final isSelected = controller.selectedTabIndex.value == index;
                final badge = tab['badge'] as int? ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.changeTab(index),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AdminTheme.primaryBlue
                              : (isDark
                                  ? AppThemes.darkSurface
                                  : const Color(0xFFF1F4F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AdminTheme.primaryBlue
                                : (isDark
                                    ? AppThemes.darkBorder
                                    : Colors.transparent),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              tab['icon'] as IconData,
                              size: 17,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppThemes.darkTextSecondary
                                      : const Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tab['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppThemes.darkTextPrimary
                                        : const Color(0xFF334155)),
                              ),
                            ),
                            if (badge > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$badge',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AdminTheme.primaryBlue : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

