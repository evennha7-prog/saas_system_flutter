import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../screens/registration_pending_screen.dart';
import '../../../themes/themes.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  // Observables
  final isPasswordVisible = false.obs;
  final rememberMe = true.obs;
  final isLoading = false.obs;
  final loginMode = 'password'.obs; // 'password' or 'pin'
  final enteredPin = ''.obs;


  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? val) {
    rememberMe.value = val ?? false;
  }

  void setLoginMode(String mode) {
    loginMode.value = mode;
    enteredPin.value = '';
  }


  // Password Login
  Future<void> loginWithPassword() async {
    if (formKey.currentState?.validate() != true) return;

    final identifier = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'err_fill_all'.tr,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;

    try {
      final api = ApiService.to;
      final res = await api.login(identifier, password);

      isLoading.value = false;

      if (res.isSuccess && res.data != null) {
        final token = res.data!;
        _updateSessionAndNavigate(
          name: token.fullName.isNotEmpty ? token.fullName : identifier,
          phone: token.user?.phoneNumber.isNotEmpty == true
              ? token.user!.phoneNumber
              : identifier,
          role: token.role,
        );
      } else {
        final errorMsg = res.message ?? 'Login failed';
        final lower = errorMsg.toLowerCase();
        if (lower.contains('pending') ||
            lower.contains('រង់ចាំ') ||
            lower.contains('@cpanha14') ||
            lower.contains('rejected') ||
            lower.contains('បដិសេធ') ||
            lower.contains('inactive') ||
            lower.contains('disabled') ||
            lower.contains('disable')) {
          _navigateToPendingScreen(identifier, errorMsg);
        } else {
          Get.snackbar(
            'error'.tr,
            errorMsg,
            backgroundColor: Colors.redAccent.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
          );
        }
      }
    } catch (e) {
      isLoading.value = false;
      final errStr = e.toString().replaceFirst('Exception: ', '');
      final lower = errStr.toLowerCase();
      if (lower.contains('pending') ||
          lower.contains('រង់ចាំ') ||
          lower.contains('@cpanha14') ||
          lower.contains('rejected') ||
          lower.contains('បដិសេធ') ||
          lower.contains('inactive') ||
          lower.contains('disabled') ||
          lower.contains('disable')) {
        _navigateToPendingScreen(identifier, errStr);
      } else {
        Get.snackbar(
          'error'.tr,
          errStr,
          backgroundColor: Colors.redAccent.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    }
  }

  Future<void> _navigateToPendingScreen(String identifier, String message) async {
    try {
      final statusRes = await ApiService.to.checkRegistrationStatus(identifier);
      if (statusRes.isSuccess && statusRes.data != null && statusRes.data!.isNotEmpty) {
        final data = statusRes.data!;
        Get.to(() => RegistrationPendingScreen(
              storeName: data['store_name']?.toString().isNotEmpty == true
                  ? data['store_name'].toString()
                  : 'KaShop',
              ownerName: data['owner_name']?.toString().isNotEmpty == true
                  ? data['owner_name'].toString()
                  : (data['full_name']?.toString() ?? 'Store Owner'),
              phone: data['phone_number']?.toString().isNotEmpty == true
                  ? data['phone_number'].toString()
                  : (data['phone']?.toString() ?? identifier),
              email: data['email']?.toString() ?? (identifier.contains('@') ? identifier : ''),
              businessType: data['business_type']?.toString() ?? 'Cafe & Beverage',
              branch: data['store_branch']?.toString() ?? 'Main Branch',
              address: data['address']?.toString() ?? 'Phnom Penh, Cambodia',
              submittedAt: data['created_at'] != null
                  ? data['created_at'].toString().split('T').first
                  : 'Recently',
            ));
        return;
      }
    } catch (_) {}

    // Fallback if status lookup was not reachable
    Get.to(() => RegistrationPendingScreen(
          storeName: 'Store Account',
          ownerName: identifier.contains('@') ? identifier.split('@').first : identifier,
          phone: identifier.contains('@') ? '' : identifier,
          email: identifier.contains('@') ? identifier : '',
          businessType: 'Cafe & Beverage',
          submittedAt: 'Recently',
        ));
  }


  // PIN Keypad actions
  void onPinTapped(String digit) {
    if (enteredPin.value.length < 4) {
      enteredPin.value += digit;
      if (enteredPin.value.length == 4) {
        _validateAndSubmitPin();
      }
    }
  }

  void onPinDelete() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(
        0,
        enteredPin.value.length - 1,
      );
    }
  }

  void onPinClear() {
    enteredPin.value = '';
  }

  Future<void> _validateAndSubmitPin() async {
    isLoading.value = true;

    try {
      final api = ApiService.to;
      final res = await api.pinLogin(enteredPin.value);

      isLoading.value = false;

      if (res.isSuccess && res.data != null) {
        final token = res.data!;
        _updateSessionAndNavigate(
          name: token.fullName.isNotEmpty ? token.fullName : 'Staff User',
          phone: 'PIN User',
          role: token.role,
        );
      } else {
        final errorMsg = res.message ?? 'err_invalid_pin'.tr;
        final lower = errorMsg.toLowerCase();
        if (lower.contains('pending') ||
            lower.contains('រង់ចាំ') ||
            lower.contains('@cpanha14') ||
            lower.contains('disabled') ||
            lower.contains('disable') ||
            lower.contains('inactive')) {
          _navigateToPendingScreen(enteredPin.value, errorMsg);
        } else {
          Get.snackbar(
            'error'.tr,
            errorMsg,
            backgroundColor: Colors.redAccent.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
          );
        }
        enteredPin.value = '';
      }
    } catch (e) {
      isLoading.value = false;
      final errStr = e.toString().replaceFirst('Exception: ', '');
      final lower = errStr.toLowerCase();
      if (lower.contains('pending') ||
          lower.contains('រង់ចាំ') ||
          lower.contains('@cpanha14') ||
          lower.contains('disabled') ||
          lower.contains('disable') ||
          lower.contains('inactive')) {
        _navigateToPendingScreen(enteredPin.value, errStr);
      } else {
        Get.snackbar(
          'error'.tr,
          errStr,
          backgroundColor: Colors.redAccent.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
      enteredPin.value = '';
    }
  }

  void _updateSessionAndNavigate({
    required String name,
    required String phone,
    required String role,
  }) {
    ApiService.to.syncActiveControllers();

    Get.snackbar(
      'success'.tr,
      'login_success'.tr,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );

    Get.offAllNamed(Routes.NAVBAR);
  }

  void showForgotPasswordDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppThemes.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'forgot_password_title'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'forgot_password_desc'.tr,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.check_rounded),
                label: Text('confirm'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
