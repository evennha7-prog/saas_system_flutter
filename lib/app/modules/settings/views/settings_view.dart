import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screens/receipt_printer_screen.dart';
import '../../../screens/staff_management_screen.dart';
import '../../../screens/store_info_screen.dart';
import '../../../screens/telegram_bot_screen.dart';
import '../../../themes/themes.dart';
import '../../../translations/translations.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color primaryGold = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : primaryOrange,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'settings'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Store & Business Configuration
            _buildSectionHeader(
              context,
              'store_and_hardware'.tr,
              Icons.store_rounded,
            ),
            _buildCardContainer(
              context: context,
              children: [
                _buildTile(
                  context: context,
                  icon: Icons.storefront_rounded,
                  iconBg: primaryOrange,
                  title: 'store_info'.tr,
                  subtitle: 'store_info_subtitle'.tr,
                  onTap: () => Get.to(() => const StoreInfoScreen()),
                ),
                _buildDivider(context),
                _buildTile(
                  context: context,
                  icon: Icons.badge_rounded,
                  iconBg: const Color(0xFF0288D1),
                  title: 'staff_management'.tr,
                  subtitle: 'staff_management_subtitle'.tr,
                  onTap: () => Get.to(() => const StaffManagementScreen()),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Section 2: Hardware & Integration
            _buildSectionHeader(
              context,
              'hardware_integrations'.tr,
              Icons.devices_rounded,
            ),
            _buildCardContainer(
              context: context,
              children: [
                _buildTile(
                  context: context,
                  icon: Icons.print_rounded,
                  iconBg: const Color(0xFF43A047),
                  title: 'receipt_printer'.tr,
                  subtitle: 'printer_connected'.tr,
                  onTap: () => Get.to(() => const ReceiptPrinterScreen()),
                ),
                _buildDivider(context),
                _buildTile(
                  context: context,
                  icon: Icons.telegram_rounded,
                  iconBg: const Color(0xFF24A1DE),
                  title: 'telegram_bot'.tr,
                  subtitle: 'telegram_bot_subtitle'.tr,
                  onTap: () => Get.to(() => const TelegramBotScreen()),
                ),
                _buildDivider(context),
                Obx(
                  () => _buildSwitchTile(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    iconBg: const Color(0xFF7E57C2),
                    title: 'auto_print_receipt'.tr,
                    subtitle: 'auto_print_on_checkout'.tr,
                    value: controller.isAutoPrintEnabled.value,
                    onChanged: controller.toggleAutoPrint,
                  ),
                ),
                _buildDivider(context),
                Obx(
                  () => _buildSwitchTile(
                    context: context,
                    icon: Icons.volume_up_rounded,
                    iconBg: const Color(0xFFFB8C00),
                    title: 'sound_alert'.tr,
                    subtitle: 'sound_on_scan_checkout'.tr,
                    value: controller.isSoundEnabled.value,
                    onChanged: controller.toggleSound,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Section 3: App Preferences & Language
            _buildSectionHeader(
              context,
              'app_preferences'.tr,
              Icons.tune_rounded,
            ),
            _buildCardContainer(
              context: context,
              children: [
                _buildTile(
                  context: context,
                  icon: Icons.language_rounded,
                  iconBg: const Color(0xFF00ACC1),
                  title: 'language'.tr,
                  subtitle: AppTranslations.currentLanguage.name,
                  trailingBadge: AppTranslations.currentLanguage.flag,
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildDivider(context),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.dark_mode_rounded,
                  iconBg: const Color(0xFF3949AB),
                  title: 'dark_mode'.tr,
                  subtitle: 'toggle_dark_theme'.tr,
                  value: isDark,
                  onChanged: (val) => AppThemes.toggleTheme(),
                ),
                _buildDivider(context),
                Obx(
                  () => _buildSwitchTile(
                    context: context,
                    icon: Icons.cloud_sync_rounded,
                    iconBg: const Color(0xFF00897B),
                    title: 'cloud_auto_sync'.tr,
                    subtitle: 'auto_sync_to_server'.tr,
                    value: controller.isCloudSyncEnabled.value,
                    onChanged: controller.toggleCloudSync,

                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Section 4: Maintenance & App Info
            _buildSectionHeader(
              context,
              'system_maintenance_title'.tr,
              Icons.info_outline_rounded,
            ),
            _buildCardContainer(
              context: context,
              children: [
                Obx(
                  () => _buildTile(
                    context: context,
                    icon: Icons.cleaning_services_rounded,
                    iconBg: const Color(0xFF6D4C41),
                    title: 'clear_cache_title'.tr,
                    subtitle: controller.isCacheClearing.value
                        ? 'clearing_cache'.tr
                        : 'clear_cache_desc'.tr,
                    trailing: controller.isCacheClearing.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryOrange,
                            ),
                          )
                        : null,
                    onTap: controller.isCacheClearing.value
                        ? null
                        : controller.clearAppCache,
                  ),
                ),
                _buildDivider(context),
                _buildTile(
                  context: context,
                  icon: Icons.verified_rounded,
                  iconBg: const Color(0xFF546E7A),
                  title: 'app_version_label'.tr,
                  subtitle:
                      'AudiCafe Retail POS ${controller.appVersion.value}',
                  onTap: () {
                    Get.snackbar(
                      'app_version_snackbar_title'.tr,
                      '${'app_version_snackbar_msg'.tr} ${controller.appVersion.value}',
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primaryOrange),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: isDark
          ? AppThemes.darkBorder.withValues(alpha: 0.5)
          : const Color(0xFFF0F2F5),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    String? trailingBadge,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconBg, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemes.darkSurface
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingBadge,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : Colors.grey.shade400,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: primaryOrange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'choose_language_title'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...AppTranslations.languages.map((lang) {
              final isSelected =
                  AppTranslations.currentLanguage.languageCode ==
                  lang.languageCode;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryOrange.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? primaryOrange
                        : (isDark
                              ? AppThemes.darkBorder
                              : AppThemes.lightBorder),
                  ),
                ),
                child: ListTile(
                  leading: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    lang.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? primaryOrange
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    lang.subName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: primaryOrange,
                        )
                      : null,
                  onTap: () {
                    AppTranslations.changeLocale(lang.locale);
                    Get.back();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
