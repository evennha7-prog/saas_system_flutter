import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class NewStoreRegisteredScreen extends StatefulWidget {
  final int storeId;
  const NewStoreRegisteredScreen({super.key, this.storeId = 4});

  @override
  State<NewStoreRegisteredScreen> createState() => _NewStoreRegisteredScreenState();
}

class _NewStoreRegisteredScreenState extends State<NewStoreRegisteredScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  bool isStoreActive = true;
  String selectedPlan = 'Standard Plan (\$15/mo)';
  final licenseKey = 'KITLUY-LIC-SHV04-2026-98X71';

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
          'add_store'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'share_store_info'.tr,
            onPressed: () {
              Get.snackbar(
                'share'.tr,
                'copied_to_clipboard'.tr,
                backgroundColor: const Color(0xFF2E7D32),
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
            // Hero Store Registration Card
            _buildStoreHeroCard(context),
            const SizedBox(height: 16),

            // Store Profile & Owner Card
            _buildSectionCard(
              context: context,
              icon: Icons.storefront_rounded,
              title: 'store_details'.tr,
              children: [
                _buildInfoRow('store_name'.tr, 'AudiCafe Express Sihanoukville'),
                _buildInfoRow('branch_name'.tr, 'Ochheuteal Beach Outlet (SHV04)'),
                _buildInfoRow('business_type_label'.tr, 'Cafe & Beverage Bar'),
                _buildInfoRow('date'.tr, '24-Aug-2026 21:20 (10 min ago)'),
                _buildInfoRow('store_currency'.tr, 'USD (\$) / ${'currency_khr'.tr} (4,100 ៛)'),
                _buildInfoRow('store_address'.tr, '2 Thnou St, Sangkat 4, Preah Sihanouk'),
              ],
            ),
            const SizedBox(height: 16),

            // Owner & Credentials Card
            _buildSectionCard(
              context: context,
              icon: Icons.person_pin_rounded,
              title: 'store_manager_account'.tr,
              children: [
                _buildInfoRow('store_owner'.tr, 'Vicheka Keo'),
                _buildInfoRow('phone'.tr, '097 888 123'),
                _buildInfoRow('email_optional'.tr, 'vicheka.keo@audicafe.com'),
                _buildInfoRow('quick_pin'.tr, '8888', isMonospace: true),
                _buildInfoRow('account_status'.tr, 'active'.tr),
              ],
            ),
            const SizedBox(height: 16),

            // POS Terminal License Key & Hardware
            _buildSectionCard(
              context: context,
              icon: Icons.point_of_sale_rounded,
              title: 'terminal_license_title'.tr,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'activation_key_label'.tr,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(
                            licenseKey,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: primaryOrange,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18, color: primaryOrange),
                            onPressed: () {
                              Get.snackbar(
                                'copied_title'.tr,
                                'license_copied'.tr,
                                backgroundColor: const Color(0xFF2E7D32),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(12),
                                borderRadius: 12,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoRow('allowed_terminals_count'.tr, '2 Devices (1 Active, 1 Available)'),
                _buildInfoRow('saas_plan_package'.tr, selectedPlan),
                _buildInfoRow('receipt_printer_spec'.tr, '80mm Thermal Receipt (Enabled)'),
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isStoreActive ? Colors.orange.shade800 : const Color(0xFF2E7D32),
                      side: BorderSide(
                        color: isStoreActive ? Colors.orange.shade800 : const Color(0xFF2E7D32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() => isStoreActive = !isStoreActive);
                      if (Get.isRegistered<AdministratorController>()) {
                        Get.find<AdministratorController>().toggleStoreStatus(widget.storeId);
                      }
                    },
                    icon: Icon(isStoreActive ? Icons.pause_circle_outline : Icons.play_circle_outline),
                    label: Text(
                      isStoreActive ? 'pause_btn'.tr : 'activate_branch_btn'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Get.snackbar(
                        'notice_sent'.tr,
                        'Login instructions delivered to 097 888 123.',
                        backgroundColor: const Color(0xFF2E7D32),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(12),
                        borderRadius: 12,
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      'send_info_to_owner'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeroCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2C3E50), const Color(0xFF1A252F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'REGISTERED & INITIALIZED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '10 min ago',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'AudiCafe Express Sihanoukville',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ochheuteal Beach Outlet • Tenant ID #004',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat('SaaS Plan', 'Standard (\$15/mo)'),
              _buildHeroStat('Allocated POS', '2 Terminals'),
              _buildHeroStat('Database Node', 'PostgreSQL OK'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMonospace = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: isMonospace ? 'monospace' : null,
                color: isMonospace ? primaryOrange : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
