import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../themes/themes.dart';
import '../../../translations/translations.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color darkBlue = AppThemes.darkBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color darkOrange = darkBlue;
  static const Color accentGold = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Utility Controls (Language & Theme Toggle)
                  _buildTopBar(context),
                  const SizedBox(height: 16),

                  // Brand Hero Header
                  _buildBrandHeader(theme, isDark),
                  const SizedBox(height: 24),

                  // Main Login Container Card
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Segmented Tab Toggle (Password vs Quick PIN)
                        _buildModeSelector(theme, isDark),
                        const SizedBox(height: 22),

                        // Animated Switch between Password and PIN forms
                        Obx(() {
                          if (controller.loginMode.value == 'password') {
                            return _buildPasswordForm(context, theme, isDark);
                          } else {
                            return _buildPinKeypadForm(context, theme, isDark);
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer Register Navigation
                  _buildFooter(theme, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Top Bar with Language Switcher and Theme Toggle
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Language Switcher Pill
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showLanguageModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppTranslations.currentLanguage.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: primaryOrange,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Dark / Light Theme Toggle
        IconButton(
          tooltip: 'theme_mode'.tr,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Get.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: primaryOrange,
              size: 18,
            ),
          ),
          onPressed: () => AppThemes.toggleTheme(),
        ),
      ],
    );
  }

  // Brand Hero Header
  Widget _buildBrandHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Glowing Logo Badge
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [primaryOrange, darkOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.coffee_rounded, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 14),

        // Brand Name
        Text(
          'AudiCafe Retail POS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle
        Text(
          'login_subtitle'.tr,
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

  // Mode Selector Tabs (Password vs Quick PIN)
  Widget _buildModeSelector(ThemeData theme, bool isDark) {
    return Obx(() {
      final isPassword = controller.loginMode.value == 'password';
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkSurface : AppThemes.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => controller.setLoginMode('password'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isPassword ? primaryOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isPassword
                        ? [
                            BoxShadow(
                              color: primaryOrange.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.password_rounded,
                        size: 17,
                        color: isPassword
                            ? Colors.white
                            : (isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.lightTextSecondary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'tab_password'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isPassword
                              ? Colors.white
                              : (isDark
                                    ? AppThemes.darkTextSecondary
                                    : AppThemes.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => controller.setLoginMode('pin'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !isPassword ? primaryOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: !isPassword
                        ? [
                            BoxShadow(
                              color: primaryOrange.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pin_rounded,
                        size: 17,
                        color: !isPassword
                            ? Colors.white
                            : (isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.lightTextSecondary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'tab_pin'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: !isPassword
                              ? Colors.white
                              : (isDark
                                    ? AppThemes.darkTextSecondary
                                    : AppThemes.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Password Login Form
  Widget _buildPasswordForm(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identifier Input
          Text(
            'phone_or_email'.tr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.identifierController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'phone_or_email_hint'.tr,
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: primaryOrange,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'err_fill_all'.tr;
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Input
          Text(
            'password'.tr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
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
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'err_fill_all'.tr;
                if (val.trim().length < 6) return 'err_pass_short'.tr;
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Obx(
                    () => SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: controller.rememberMe.value,
                        activeColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: controller.toggleRememberMe,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'remember_me'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : AppThemes.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => controller.showForgotPasswordDialog(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'forgot_password'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit Login Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.loginWithPassword,
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
                          Text(
                            'login_btn'.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick PIN Keypad Form
  Widget _buildPinKeypadForm(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          'enter_cashier_pin'.tr,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppThemes.darkTextSecondary
                : AppThemes.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 18),

        // PIN 4-Dots Display
        Obx(() {
          final pinLength = controller.enteredPin.value.length;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < pinLength;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: isFilled ? 18 : 14,
                height: isFilled ? 18 : 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? primaryOrange : Colors.transparent,
                  border: Border.all(
                    color: isFilled
                        ? primaryOrange
                        : (isDark
                              ? AppThemes.darkBorder
                              : AppThemes.lightBorder),
                    width: 2,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: primaryOrange.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
              );
            }),
          );
        }),
        const SizedBox(height: 24),

        // 3x4 Numeric Keypad
        _buildKeypadGrid(theme, isDark),
      ],
    );
  }

  // Keypad Grid for PIN
  Widget _buildKeypadGrid(ThemeData theme, bool isDark) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key == 'C') {
                return _buildKeyButton(
                  theme: theme,
                  isDark: isDark,
                  label: key,
                  icon: null,
                  onTap: controller.onPinClear,
                  isSpecial: true,
                );
              } else if (key == '⌫') {
                return _buildKeyButton(
                  theme: theme,
                  isDark: isDark,
                  label: null,
                  icon: Icons.backspace_outlined,
                  onTap: controller.onPinDelete,
                  isSpecial: true,
                );
              } else {
                return _buildKeyButton(
                  theme: theme,
                  isDark: isDark,
                  label: key,
                  icon: null,
                  onTap: () => controller.onPinTapped(key),
                  isSpecial: false,
                );
              }
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // Single Keypad Button
  Widget _buildKeyButton({
    required ThemeData theme,
    required bool isDark,
    String? label,
    IconData? icon,
    required VoidCallback onTap,
    required bool isSpecial,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSpecial
                ? (isDark ? AppThemes.darkSurface : AppThemes.lightSurface)
                : (isDark ? AppThemes.darkSurface : const Color(0xFFF3F4F6)),
            border: Border.all(
              color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
              width: 1,
            ),
          ),
          child: Center(
            child: label != null
                ? Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSpecial
                          ? (isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.lightTextSecondary)
                          : theme.colorScheme.onSurface,
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.lightTextSecondary,
                  ),
          ),
        ),
      ),
    );
  }

  // Footer Navigation to Register
  Widget _buildFooter(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'dont_have_account'.tr,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppThemes.darkTextSecondary
                : AppThemes.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () => Get.toNamed(Routes.REGISTER),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
          child: Text(
            'register_now'.tr,
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

  // Language Modal Bottom Sheet
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
