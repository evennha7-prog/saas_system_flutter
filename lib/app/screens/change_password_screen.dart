import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/themes.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  // 'pin' or 'password'
  String authType = 'pin';

  // PIN state
  String currentPin = '';
  String newPin = '';
  String confirmPin = '';
  int pinStep = 1; // 1: Enter Current, 2: Enter New, 3: Confirm New

  // Password state
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void _onPinKeyTapped(String val) {
    setState(() {
      if (pinStep == 1) {
        if (currentPin.length < 4) currentPin += val;
        if (currentPin.length == 4) {
          Future.delayed(const Duration(milliseconds: 250), () {
            setState(() => pinStep = 2);
          });
        }
      } else if (pinStep == 2) {
        if (newPin.length < 4) newPin += val;
        if (newPin.length == 4) {
          Future.delayed(const Duration(milliseconds: 250), () {
            setState(() => pinStep = 3);
          });
        }
      } else if (pinStep == 3) {
        if (confirmPin.length < 4) confirmPin += val;
        if (confirmPin.length == 4) {
          if (newPin == confirmPin) {
            Get.snackbar(
              'success'.tr,
              'pin_changed_success'.tr,
              backgroundColor: const Color(0xFF1B5E20),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
            );
            Future.delayed(const Duration(milliseconds: 800), () => Get.back());
          } else {
            Get.snackbar(
              'error'.tr,
              'pin_mismatch_error'.tr,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            setState(() {
              confirmPin = '';
            });
          }
        }
      }
    });
  }

  void _onPinDelete() {
    setState(() {
      if (pinStep == 1 && currentPin.isNotEmpty) {
        currentPin = currentPin.substring(0, currentPin.length - 1);
      } else if (pinStep == 2 && newPin.isNotEmpty) {
        newPin = newPin.substring(0, newPin.length - 1);
      } else if (pinStep == 3 && confirmPin.isNotEmpty) {
        confirmPin = confirmPin.substring(0, confirmPin.length - 1);
      }
    });
  }

  void _savePassword() {
    final current = currentPassController.text.trim();
    final next = newPassController.text.trim();
    final confirm = confirmPassController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'err_fill_all'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    if (next.length < 6) {
      Get.snackbar(
        'warning'.tr,
        'err_pass_short'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    if (next != confirm) {
      Get.snackbar(
        'warning'.tr,
        'err_pass_not_match'.tr,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'success'.tr,
      'updated_success'.tr,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
    Future.delayed(const Duration(milliseconds: 800), () => Get.back());
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
          'change_password_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mode Segment Switcher: PIN vs Password
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAuthTypeTab(
                      title: 'pin_code_four_digits'.tr,
                      icon: Icons.pin_outlined,
                      isSelected: authType == 'pin',
                      onTap: () => setState(() => authType = 'pin'),
                    ),
                  ),
                  Expanded(
                    child: _buildAuthTypeTab(
                      title: 'password'.tr,
                      icon: Icons.password_rounded,
                      isSelected: authType == 'password',
                      onTap: () => setState(() => authType = 'password'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (authType == 'pin')
              _buildPinSection(context)
            else
              _buildPasswordSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthTypeTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppThemes.darkTextSecondary : Colors.black54),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppThemes.darkTextPrimary : Colors.black87),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. PIN Keypad & Dots UI
  Widget _buildPinSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String stepTitle = 'enter_current_pin'.tr;
    String currentBuffer = currentPin;

    if (pinStep == 2) {
      stepTitle = 'enter_new_pin'.tr;
      currentBuffer = newPin;
    } else if (pinStep == 3) {
      stepTitle = 'confirm_new_pin'.tr;
      currentBuffer = confirmPin;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: AppThemes.darkBorder)
            : Border.all(color: AppThemes.lightBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            stepTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${'step_of'.tr} $pinStep ${'of'.tr} 3',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppThemes.darkTextSecondary
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),

          // 4 PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < currentBuffer.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isFilled
                      ? primaryOrange
                      : (isDark ? AppThemes.darkSurface : Colors.grey.shade200),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFilled
                        ? primaryOrange
                        : (isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade400),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 26),

          // Numeric Keypad
          _buildNumericKeypad(context),

          if (pinStep > 1)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: TextButton.icon(
                onPressed: () => setState(() => pinStep--),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: primaryOrange,
                ),
                label: Text(
                  'back'.tr,
                  style: const TextStyle(color: primaryOrange),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', 'DEL'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key == 'C') {
                return SizedBox(
                  width: 64,
                  height: 64,
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (pinStep == 1) currentPin = '';
                        if (pinStep == 2) newPin = '';
                        if (pinStep == 3) confirmPin = '';
                      });
                    },
                  ),
                );
              }
              if (key == 'DEL') {
                return SizedBox(
                  width: 64,
                  height: 64,
                  child: IconButton(
                    icon: Icon(
                      Icons.backspace_outlined,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: _onPinDelete,
                  ),
                );
              }
              return Material(
                color: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _onPinKeyTapped(key),
                  child: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // 2. Standard Password Form UI
  Widget _buildPasswordSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: AppThemes.darkBorder)
            : Border.all(color: AppThemes.lightBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'change_login_password_title'.tr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'change_password_subtitle'.tr,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppThemes.darkTextSecondary
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18),

          _buildPasswordField(
            label: 'current_password_label'.tr,
            controller: currentPassController,
            isObscured: obscureCurrent,
            onToggle: () => setState(() => obscureCurrent = !obscureCurrent),
          ),
          const SizedBox(height: 14),

          _buildPasswordField(
            label: 'new_password_label'.tr,
            controller: newPassController,
            isObscured: obscureNew,
            onToggle: () => setState(() => obscureNew = !obscureNew),
          ),
          const SizedBox(height: 14),

          _buildPasswordField(
            label: 'confirm_password_label'.tr,
            controller: confirmPassController,
            isObscured: obscureConfirm,
            onToggle: () => setState(() => obscureConfirm = !obscureConfirm),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _savePassword,
              icon: const Icon(Icons.lock_reset_rounded, size: 20),
              label: Text(
                'save_changes'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppThemes.darkTextSecondary
                : const Color(0xFF4A5260),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isObscured,
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: primaryOrange,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryOrange, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
