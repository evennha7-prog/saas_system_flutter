import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class StoreStatusDetailScreen extends StatefulWidget {
  final int storeId;
  final String storeName;
  final String branchName;
  final bool isInitiallyActive;
  final String statusReason;
  final String timestamp;

  const StoreStatusDetailScreen({
    super.key,
    this.storeId = 2,
    this.storeName = 'AudiCafe BKK1 Branch',
    this.branchName = 'BKK1 Flagship (BKK02)',
    this.isInitiallyActive = true,
    this.statusReason = 'Store activated and authorized for live cloud POS billing',
    this.timestamp = 'Just now',
  });

  @override
  State<StoreStatusDetailScreen> createState() => _StoreStatusDetailScreenState();
}

class _StoreStatusDetailScreenState extends State<StoreStatusDetailScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    isActive = widget.isInitiallyActive;
    if (Get.isRegistered<AdministratorController>()) {
      final ctrl = Get.find<AdministratorController>();
      final store = ctrl.stores.firstWhereOrNull((s) => s.id == widget.storeId);
      if (store != null) {
        isActive = store.isActive;
      }
    }
  }

  void _toggleStatus() {
    setState(() {
      isActive = !isActive;
    });

    if (Get.isRegistered<AdministratorController>()) {
      Get.find<AdministratorController>().toggleStoreStatus(widget.storeId);
    }

    HapticFeedback.mediumImpact();
    Get.snackbar(
      isActive ? 'store_activated_title'.tr : 'store_suspended_title'.tr,
      isActive
          ? '${widget.storeName}: ${'store_activated_msg_active'.tr}'
          : '${widget.storeName}: ${'store_suspended_msg_sub'.tr}',
      backgroundColor: isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(
        isActive ? Icons.check_circle_rounded : Icons.pause_circle_filled_rounded,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : primaryOrange,
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
          isActive ? 'store_status_title'.tr : 'store_status_title'.tr,
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
            // Hero Status Banner Card
            _buildHeroStatusBanner(context),
            const SizedBox(height: 16),

            // Store Profile Card
            _buildSectionCard(
              context: context,
              icon: Icons.storefront_rounded,
              title: 'store_profile_title'.tr,
              children: [
                _buildInfoRow('store_name_label'.tr, widget.storeName),
                _buildInfoRow('store_branch_label'.tr, widget.branchName),
                _buildInfoRow('store_owner'.tr, 'Rithy Dara (078 111 222)'),
                _buildInfoRow('store_address_label'.tr, 'St 51 Corner St 288, BKK1, Phnom Penh'),
                _buildInfoRow('saas_plan'.tr, 'Pro Plan (\$35/mo)'),
                _buildInfoRow('date'.tr, widget.timestamp),
              ],
            ),
            const SizedBox(height: 16),

            // Operational Metrics Card
            _buildSectionCard(
              context: context,
              icon: Icons.analytics_outlined,
              title: 'summary_operations'.tr,
              children: [
                _buildInfoRow('total_revenue_amount'.tr, '\$4,890.00 (32.8%)'),
                _buildInfoRow('total_orders'.tr, '495 ${'transactions'.tr}'),
                _buildInfoRow('staff_count'.tr, '3 ${'persons'.tr}'),
                _buildInfoRow('pos_terminals_online'.tr, '2 POS Terminals Connected'),
              ],
            ),
            const SizedBox(height: 16),

            // Event Reason Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100))
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isActive ? Icons.info_outline_rounded : Icons.warning_amber_rounded,
                    color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isActive ? 'status_notes_title'.tr : 'suspension_notes_title'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isActive
                              ? 'store_active_desc'.tr
                              : 'store_suspended_desc'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Action Toggle Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _toggleStatus,
                icon: Icon(
                  isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                  size: 20,
                ),
                label: Text(
                  isActive ? 'suspend_branch_btn'.tr : 'activate_branch_btn'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStatusBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
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
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.check_circle_rounded : Icons.pause_circle_filled_rounded,
              color: primaryColor,
              size: 32,
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
                      isActive ? 'status_active'.tr : 'status_suspended_label'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.timestamp,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  widget.storeName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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
              Icon(icon, color: primaryOrange, size: 18),
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
