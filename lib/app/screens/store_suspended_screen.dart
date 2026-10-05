import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class StoreSuspendedScreen extends StatefulWidget {
  final int storeId;
  final String storeName;
  final String branchName;
  final String timestamp;
  final String reason;

  const StoreSuspendedScreen({
    super.key,
    this.storeId = 2,
    this.storeName = 'AudiCafe BKK1 Branch',
    this.branchName = 'BKK1 Flagship (BKK02)',
    this.timestamp = 'Just now',
    this.reason = 'Monthly subscription payment overdue for more than 14 days. POS checkout disabled.',
  });

  @override
  State<StoreSuspendedScreen> createState() => _StoreSuspendedScreenState();
}

class _StoreSuspendedScreenState extends State<StoreSuspendedScreen> {
  static const Color suspendColor = Color(0xFFE65100);
  static const Color dangerRed = Color(0xFFD32F2F);
  static const Color activeGreen = Color(0xFF2E7D32);

  void _reactivateStore() {
    Get.defaultDialog(
      title: 'activate_store'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: Text(
        '${'reactivate_store_confirm'.tr}\n("${widget.storeName}")',
        style: const TextStyle(fontSize: 13),
      ),
      textConfirm: 'activate_store'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: activeGreen,
      onConfirm: () {
        Get.back();
        if (Get.isRegistered<AdministratorController>()) {
          Get.find<AdministratorController>().toggleStoreStatus(widget.storeId);
        }
        HapticFeedback.heavyImpact();
        Get.back(); // Go back to dashboard
        Get.snackbar(
          'store_activated_title'.tr,
          '${widget.storeName} ${'store_activated_msg'.tr}',
          backgroundColor: activeGreen,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : suspendColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'store_suspended_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Suspension Warning Card
            _buildSuspensionHeroBanner(context),
            const SizedBox(height: 16),

            // Suspension Reason Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dangerRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dangerRed.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.report_problem_rounded, color: dangerRed, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'rejection_reason_label'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: dangerRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.reason,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppThemes.darkTextPrimary : Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operational Restrictions Card
            _buildSectionCard(
              context: context,
              icon: Icons.lock_clock_rounded,
              title: 'actions'.tr,
              children: [
                _buildImpactRow(Icons.cancel_rounded, dangerRed, 'pos_terminals_online'.tr, 'locked'),
                _buildImpactRow(Icons.cancel_rounded, dangerRed, 'total_orders'.tr, 'disabled'),
                _buildImpactRow(Icons.warning_amber_rounded, suspendColor, 'products'.tr, 'read-only'),
                _buildImpactRow(Icons.warning_amber_rounded, suspendColor, 'role_cashier'.tr, 'inactive'.tr),
              ],
            ),
            const SizedBox(height: 16),

            // Store Profile Details
            _buildSectionCard(
              context: context,
              icon: Icons.storefront_rounded,
              title: 'store_details'.tr,
              children: [
                _buildInfoRow('store_name'.tr, widget.storeName),
                _buildInfoRow('branch_name'.tr, widget.branchName),
                _buildInfoRow('store_owner'.tr, 'Rithy Dara (078 111 222)'),
                _buildInfoRow('store_plan'.tr, 'Pro Plan (\$35/mo)'),
                _buildInfoRow('total_revenue_amount'.tr, '\$4,890.00'),
                _buildInfoRow('store_address'.tr, 'St 51 Corner St 288, BKK1, Phnom Penh'),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _reactivateStore,
                icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
                label: Text(
                  'activate_store'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: suspendColor,
                  side: const BorderSide(color: suspendColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                    Get.snackbar(
                      'notice_sent'.tr,
                      'Payment and reactivation reminder dispatched to Store Manager (078 111 222).',
                    backgroundColor: suspendColor,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 12,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: Text(
                  'send_reminder_to_owner'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspensionHeroBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: suspendColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: suspendColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: suspendColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pause_circle_filled_rounded,
              color: suspendColor,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'status_suspended_label'.tr,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: suspendColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: suspendColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.timestamp,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: suspendColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  widget.storeName,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'checkout_locked_banner'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: suspendColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImpactRow(IconData icon, Color color, String title, String status) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurface),
            ),
          ),
          Text(
            status,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
