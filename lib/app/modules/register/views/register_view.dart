import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../themes/themes.dart';
import '../../../translations/translations.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color darkBlue = AppThemes.darkBlue;
  static const Color accentBlue = AppThemes.accentBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color darkOrange = darkBlue;
  static const Color accentGold = accentBlue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Language Switcher Pill
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showLanguageModal(context),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryOrange.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppTranslations.currentLanguage.flag,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppTranslations.currentLanguage.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Theme Toggle
          IconButton(
            tooltip: 'theme_mode'.tr,
            icon: Icon(
              Get.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: primaryOrange,
              size: 20,
            ),
            onPressed: () => AppThemes.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Header
                  _buildHeader(theme, isDark),
                  const SizedBox(height: 18),

                  // Tab Navigation Switcher
                  _buildTabSwitcher(theme, isDark),
                  const SizedBox(height: 16),

                  // Registration Card Form
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppThemes.darkBorder
                            : AppThemes.lightBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Obx(
                        () => controller.currentTabIndex.value == 0
                            ? _buildTab1Content(theme, isDark, context)
                            : _buildTab2Content(theme, isDark, context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Footer Back to Login
                  _buildFooter(theme, isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tab Header Switcher (Tab 1 & Tab 2)
  Widget _buildTabSwitcher(ThemeData theme, bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppThemes.darkBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Tab 1: Account & Store
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.switchTab(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.currentTabIndex.value == 0
                        ? primaryOrange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: controller.currentTabIndex.value == 0
                        ? [
                            BoxShadow(
                              color: primaryOrange.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_pin_rounded,
                        size: 18,
                        color: controller.currentTabIndex.value == 0
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey.shade700),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'tab_account_store'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: controller.currentTabIndex.value == 0
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Tab 2: Business & Setup
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (controller.validateTab1()) {
                    controller.switchTab(1);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.currentTabIndex.value == 1
                        ? primaryOrange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: controller.currentTabIndex.value == 1
                        ? [
                            BoxShadow(
                              color: primaryOrange.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 18,
                        color: controller.currentTabIndex.value == 1
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey.shade700),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'tab_business_setup'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: controller.currentTabIndex.value == 1
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab 1: Account & Store Form
  Widget _buildTab1Content(ThemeData theme, bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Owner Registration Badge
        Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: primaryOrange,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'register_as_store_owner_badge'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Store Name
        _buildFieldLabel(theme, 'store_name_field'.tr, isRequired: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.storeNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'store_name_field_hint'.tr,
            prefixIcon: const Icon(
              Icons.storefront_rounded,
              color: primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Full Name
        _buildFieldLabel(theme, 'full_name'.tr, isRequired: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.fullNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'full_name_hint'.tr,
            prefixIcon: const Icon(
              Icons.person_outline_rounded,
              color: primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Phone Number
        _buildFieldLabel(theme, 'phone_number'.tr, isRequired: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'phone_number_hint'.tr,
            prefixIcon: const Icon(
              Icons.phone_iphone_rounded,
              color: primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Email (Optional)
        _buildFieldLabel(theme, 'email_optional'.tr),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'email_hint'.tr,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              color: primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Password & Strength Evaluation
        _buildFieldLabel(theme, 'password'.tr, isRequired: true),
        const SizedBox(height: 6),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            onChanged: controller.evaluatePassword,
            decoration: InputDecoration(
              hintText: 'password_hint'.tr,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: primaryOrange,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
        ),

        // Live Password Strength Meter
        Obx(() {
          final text = controller.passwordStrengthText.value;
          final strength = controller.passwordStrength.value;
          final color = controller.passwordStrengthColor.value;
          if (text.isEmpty) {
            return const SizedBox(height: 14);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: strength,
                        backgroundColor: isDark
                            ? AppThemes.darkSurface
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          color,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          );
        }),

        // Confirm Password & Live Match Check
        _buildFieldLabel(theme, 'confirm_password'.tr, isRequired: true),
        const SizedBox(height: 6),
        Obx(
          () => TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: !controller.isConfirmPasswordVisible.value,
            onChanged: controller.evaluateConfirmPassword,
            decoration: InputDecoration(
              hintText: 'confirm_password_hint'.tr,
              prefixIcon: const Icon(
                Icons.shield_outlined,
                color: primaryOrange,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            ),
          ),
        ),

        // Live Password Match Indicator
        Obx(() {
          final confirmText = controller.confirmPasswordText.value;
          final passText = controller.passwordText.value;
          final isMatch = controller.isPasswordMatch.value;

          if (confirmText.isEmpty || passText.isEmpty) {
            return const SizedBox(height: 18);
          }
          return Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 14),
            child: Row(
              children: [
                Icon(
                  isMatch ? Icons.check_circle_rounded : Icons.info_outline,
                  color: isMatch ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  isMatch
                      ? 'passwords_match'.tr
                      : 'passwords_dont_match'.tr,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isMatch
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
          );
        }),

        // Tab 1 Action Buttons (Next to Tab 2 or Submit)
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (controller.validateTab1()) {
                      controller.switchTab(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(
                    'next_step'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tab 2: Business & Setup Form
  Widget _buildTab2Content(ThemeData theme, bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Type
        _buildFieldLabel(theme, 'business_type_label'.tr, isRequired: true),
        const SizedBox(height: 6),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemes.darkSurface : AppThemes.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedBusinessType.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: primaryOrange,
                ),
                dropdownColor: theme.cardColor,
                items: controller.businessTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.setBusinessType(val);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Store Branch
        _buildFieldLabel(theme, 'store_branch_label'.tr),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.storeBranchController,
          decoration: InputDecoration(
            hintText: 'store_branch_hint'.tr,
            prefixIcon: const Icon(
              Icons.location_city_rounded,
              color: primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Store Address
        _buildFieldLabel(theme, 'store_address_label'.tr),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.storeAddressController,
          decoration: InputDecoration(
            hintText: 'store_address_hint'.tr,
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Quick 4-Digit PIN Setup
        _buildFieldLabel(theme, 'quick_pin_setup'.tr),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.quickPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            hintText: 'quick_pin_hint'.tr,
            counterText: '',
            prefixIcon: const Icon(
              Icons.pin_rounded,
              color: primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Terms Agreement Checkbox
        _buildTermsAgreement(context, theme, isDark),
        const SizedBox(height: 20),

        // Action Buttons: Back to Tab 1 & Submit Registration
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => controller.switchTab(0),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : Colors.grey.shade700,
                    side: BorderSide(
                      color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    'prev_step'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Obx(
                () => SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.registerAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryOrange.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.how_to_reg_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'submit_store_registration'.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(ThemeData theme, String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  // Header
  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [primaryBlue, accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'create_account_title'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'register_subtitle'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppThemes.darkTextSecondary
                : AppThemes.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  // Terms Agreement
  Widget _buildTermsAgreement(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: controller.agreeToTerms.value,
              activeColor: primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: controller.toggleAgreeTerms,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${'agree_terms_text'.tr} ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.lightTextSecondary,
                ),
              ),
              InkWell(
                onTap: () => controller.showTermsDialog(context),
                child: Text(
                  'terms_and_conditions'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Footer Navigation back to Login
  Widget _buildFooter(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppThemes.darkTextSecondary
                : AppThemes.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () {
            if (Get.previousRoute == Routes.LOGIN) {
              Get.back();
            } else {
              Get.offAllNamed(Routes.LOGIN);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
          child: Text(
            'login_now'.tr,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryOrange,
            ),
          ),
        ),
      ],
    );
  }

  // Language Modal
  void _showLanguageModal(BuildContext context) {
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
                  'choose_language'.tr,
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
                  (Get.locale?.languageCode ?? 'km') == lang.languageCode;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryOrange.withValues(alpha: 0.12)
                      : (isDark
                            ? AppThemes.darkSurface
                            : AppThemes.lightSurface),
                  borderRadius: BorderRadius.circular(14),
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
                      fontWeight: FontWeight.bold,
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
