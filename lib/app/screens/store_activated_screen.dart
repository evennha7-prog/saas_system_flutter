import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';
import 'pos_terminals_screen.dart';

class StoreActivatedScreen extends StatefulWidget {
  final int storeId;
  final String storeName;
  final String branchName;
  final String timestamp;

  const StoreActivatedScreen({
    super.key,
    this.storeId = 2,
    this.storeName = 'AudiCafe BKK1 Branch',
    this.branchName = 'BKK1 Flagship (BKK02)',
    this.timestamp = 'Just now',
  });

  @override
  State<StoreActivatedScreen> createState() => _StoreActivatedScreenState();
}

class _StoreActivatedScreenState extends State<StoreActivatedScreen> {
  static const Color activeGreen = Color(0xFF2E7D32);
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  final licenseKey = 'KITLUY-LIC-BKK02-2026-ACTIVE';

  void _suspendBranch() {
    Get.defaultDialog(
      title: 'deactivate_store'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: Text(
        'suspend_store_confirm'.tr,
        style: const TextStyle(fontSize: 13),
      ),
      textConfirm: 'deactivate_store'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFD32F2F),
      onConfirm: () {
        Get.back();
        if (Get.isRegistered<AdministratorController>()) {
          Get.find<AdministratorController>().toggleStoreStatus(widget.storeId);
        }
        HapticFeedback.mediumImpact();
        Get.back(); // Go back to dashboard
        Get.snackbar(
          'store_suspended_title'.tr,
          '${widget.storeName}: ${'store_suspended_msg_sub'.tr}',
          backgroundColor: const Color(0xFFE65100),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
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
        backgroundColor: isDark ? AppThemes.darkCard : activeGreen,
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
          'store_activated'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'share'.tr,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Store: ${widget.storeName}\nLicense: $licenseKey\nStatus: ACTIVE'));
              Get.snackbar(
                'copied_to_clipboard'.tr,
                '${'store_name'.tr}: ${widget.storeName}',
                backgroundColor: activeGreen,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Activation Card
            _buildActivationHeroBanner(context),
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
                _buildInfoRow('store_address'.tr, 'St 51 Corner St 288, BKK1, Phnom Penh'),
                _buildInfoRow('store_plan'.tr, 'Pro Plan (\$35/month)'),
                _buildInfoRow('date'.tr, widget.timestamp),
                _buildInfoRow('role_administrator'.tr, 'Super Admin Terminal (Master)'),
              ],
            ),
            const SizedBox(height: 16),

            // Live License Key Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: activeGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: activeGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.vpn_key_rounded, color: activeGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Active Cloud License Key',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: activeGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        licenseKey,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: licenseKey));
                          Get.snackbar(
                            'copied_title'.tr,
                            'license_copied'.tr,
                            backgroundColor: activeGreen,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 12,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: activeGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Copy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operational Live Status Card
            _buildSectionCard(
              context: context,
              icon: Icons.speed_rounded,
              title: 'live_system_state'.tr,
              children: [
                _buildInfoRow('pos_online_label'.tr, '2 Terminals Connected'),
                _buildInfoRow('daily_total_revenue'.tr, '\$4,890.00 (32.8%)'),
                _buildInfoRow('total_orders_placed'.tr, '495 Orders Processed'),
                _buildInfoRow('staff_online_count'.tr, '3 Cashiers & Baristas'),
                _buildInfoRow('data_sync_status'.tr, 'Cloud WebSocket Connected (0ms delay)'),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _suspendBranch,
                    icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                    label: Text(
                      'pause_btn'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () => Get.to(() => const PosTerminalsScreen()),
                    icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                    label: Text(
                      'view_pos_terminals_btn'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivationHeroBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeGreen.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: activeGreen.withValues(alpha: 0.1),
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
              color: activeGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: activeGreen,
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
                      'status_active'.tr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: activeGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: activeGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.timestamp,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: activeGreen,
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
                  'store_active_banner'.tr,
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
              Icon(icon, color: activeGreen, size: 18),
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
