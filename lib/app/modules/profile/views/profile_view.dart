import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../screens/change_password_screen.dart';
import '../../../screens/edit_profile_screen.dart';
import '../../../screens/invoice_template_screen.dart';
import '../../../screens/receipt_printer_screen.dart';
import '../../../screens/staff_management_screen.dart';
import '../../../screens/store_info_screen.dart';
import '../../../screens/telegram_bot_screen.dart';
import '../../../widgets/logout_dialog.dart';
import '../../../themes/themes.dart';
import '../../../translations/translations.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

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
        title: Text(
          'profile_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Obx(() {
            if (!controller.isSuperAdmin) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
              ),
              tooltip: 'admin'.tr,
              onPressed: () => Get.toNamed(Routes.ADMINISTRATOR),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── 1. Hero User Profile Card (Name, Email, Phone, Role, Shift) ─
            _buildUserProfileCard(context, theme, isDark),
            const SizedBox(height: 14),

            // ── 2. Store Tenancy Info Card (Store Name, Branch, ID, Address) ──
            _buildStoreTenancyCard(context, theme, isDark),
            const SizedBox(height: 16),

            // ── 3. Settings Group 1: Store & Hardware ────────────────────────
            _buildSectionCard(
              context: context,
              title: 'store_and_hardware'.tr,
              items: [
                _buildTile(
                  context: context,
                  icon: Icons.receipt_long_rounded,
                  title: 'invoice_template'.tr,
                  subtitle: 'invoice_template_subtitle'.tr,
                  onTap: () => Get.to(() => const InvoiceTemplateScreen()),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.print_rounded,
                  title: 'receipt_printer'.tr,
                  subtitle: 'printer_connected'.tr,
                  onTap: () => Get.to(() => const ReceiptPrinterScreen()),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.telegram_rounded,
                  title: 'telegram_bot'.tr,
                  subtitle: 'telegram_bot_subtitle'.tr,
                  onTap: () => Get.to(() => const TelegramBotScreen()),
                ),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.receipt_rounded,
                  title: 'auto_print_receipt'.tr,
                  valueRx: controller.autoPrintReceipt,
                  onChanged: controller.toggleAutoPrint,
                ),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.volume_up_rounded,
                  title: 'sound_alert'.tr,
                  valueRx: controller.soundAlert,
                  onChanged: controller.toggleSound,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── 5. Settings Group 2: System & Security ───────────────────────
            _buildSectionCard(
              context: context,
              title: 'system_and_security'.tr,
              items: [
                _buildTile(
                  context: context,
                  icon: Icons.badge_outlined,
                  title: 'staff_management'.tr,
                  subtitle: 'staff_management_subtitle'.tr,
                  onTap: () => Get.to(() => const StaffManagementScreen()),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.language_rounded,
                  title: 'language'.tr,
                  subtitle: controller.currentLanguageTitle,
                  trailingBadge: AppTranslations.currentLanguage.flag,
                  onTap: () => _showLanguageSheet(context),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.lock_outline_rounded,
                  title: 'change_password'.tr,
                  subtitle: 'change_password_subtitle'.tr,
                  onTap: () => Get.to(() => const ChangePasswordScreen()),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.tune_rounded,
                  title: 'settings'.tr,
                  subtitle:
                      'system_maintenance_title'.tr,
                  onTap: () => Get.toNamed(Routes.SETTINGS),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── 6. Logout Button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  showAppLogoutDialog(
                    context,
                    title: 'are_you_sure'.tr,
                    message: 'logout_confirm'.tr,
                    cancelText: 'cancel'.tr,
                    confirmText: 'logout'.tr,
                    onConfirm: () async {
                      Get.back();
                      await ApiService.to.logout();
                      Get.offAllNamed(Routes.LOGIN);
                      Get.snackbar(
                        'logout'.tr,
                        'logout_success_msg'.tr,
                        backgroundColor: primaryOrange,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(12),
                        borderRadius: 12,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  'logout_account'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Hero User Profile Card ────────────────────────────────────────────────
  Widget _buildUserProfileCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Obx(() {
      final name = controller.userName.value.isNotEmpty
          ? controller.userName.value
          : 'Staff Member';
      final email = controller.userEmail.value.isNotEmpty
          ? controller.userEmail.value
          : 'No email registered';
      final phone = controller.phoneNumber.value.isNotEmpty
          ? controller.phoneNumber.value
          : 'No phone registered';
      final roleLabel = controller.roleDisplayLabel;
      final roleColor = controller.roleColor;
      final shift = controller.userShift.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Gradient Circle & Camera Action
                GestureDetector(
                  onTap: () => Get.to(() => const EditProfileScreen()),
                  child: Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [roleColor.withValues(alpha: 0.8), roleColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: roleColor.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppThemes.darkCard : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: roleColor,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 12,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Name & Role & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF1976D2),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Role Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: roleColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: roleColor,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              roleLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: roleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            ),
            const SizedBox(height: 12),

            // Contact & Shift Info Rows
            _buildInfoRow(
              icon: Icons.mail_outline_rounded,
              iconColor: const Color(0xFFE65100),
              label: 'user_email'.tr,
              value: email,
              theme: theme,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFF2E7D32),
              label: 'user_phone'.tr,
              value: phone,
              theme: theme,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFF0288D1),
              label: 'work_shift_label'.tr,
              value: shift,
              theme: theme,
              isDark: isDark,
            ),
            if (controller.telegramUsername.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.send_rounded,
                iconColor: const Color(0xFF0288D1),
                label: 'telegram'.tr,
                value: controller.telegramUsername.value,
                theme: theme,
                isDark: isDark,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppThemes.darkTextSecondary
                : AppThemes.lightTextSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // ── Store Tenancy Info Card ───────────────────────────────────────────────
  Widget _buildStoreTenancyCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Obx(() {
      final storeName = controller.storeName.value.isNotEmpty
          ? controller.storeName.value
          : 'Main Store';
      final storeBranch = controller.storeBranch.value;
      final storeId = controller.currentStoreId.value;
      final address = controller.storeAddress.value;

      return Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        child: InkWell(
          onTap: () => Get.to(() => const StoreInfoScreen()),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: primaryOrange,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  storeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ID: #$storeId',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            storeBranch,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: primaryOrange,
                    ),
                  ],
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showLanguageSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: primaryOrange,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'choose_language'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...AppTranslations.languages.map((lang) {
                return Obx(() {
                  final isSelected =
                      controller.currentLocale.value.languageCode ==
                      lang.languageCode;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isSelected
                          ? primaryOrange.withValues(alpha: 0.1)
                          : (isDark
                                ? AppThemes.darkSurface
                                : const Color(0xFFF9FAFC)),
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? primaryOrange
                                : (isDark
                                      ? AppThemes.darkBorder
                                      : Colors.grey.shade200),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Text(
                          lang.flag,
                          style: const TextStyle(fontSize: 26),
                        ),
                        title: Text(
                          lang.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? primaryOrange
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          lang.subName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade600,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: primaryOrange,
                                size: 24,
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: isDark
                                    ? AppThemes.darkTextSecondary
                                    : Colors.grey,
                                size: 24,
                              ),
                        onTap: () {
                          controller.changeLanguage(lang.locale);
                          Get.back();
                          Get.snackbar(
                            'language'.tr,
                            '${lang.flag} ${lang.name}',
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    ),
                  );
                });
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.03),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            ),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailingBadge,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryOrange, size: 20),
              ),
              const SizedBox(width: 14),
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
                        fontSize: 12,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                Text(trailingBadge, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
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
    required String title,
    required RxBool valueRx,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryOrange, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Obx(
            () => Switch.adaptive(
              activeTrackColor: primaryOrange,
              value: valueRx.value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
