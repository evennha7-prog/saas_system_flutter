import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_service.dart';
import '../../../screens/registration_pending_screen.dart';
import '../../../themes/themes.dart';
import '../../administrator/controllers/administrator_controller.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Tab 1: Account & Store Fields
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final storeNameController = TextEditingController();

  // Tab 2: Business & Setup Fields
  final storeBranchController = TextEditingController(text: 'Main Branch');
  final storeAddressController = TextEditingController();
  final quickPinController = TextEditingController();

  // Observables
  final currentTabIndex = 0.obs; // 0: Account & Store (Tab 1), 1: Business Details (Tab 2)
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedBusinessType = 'Cafe & Beverage'.obs;
  final agreeToTerms = true.obs;
  final isLoading = false.obs;

  // Real-time password feedback
  final passwordText = ''.obs;
  final confirmPasswordText = ''.obs;
  final passwordStrength = 0.0.obs; // 0.0 to 1.0
  final passwordStrengthText = ''.obs;
  final passwordStrengthColor = const Color(0xFF9E9E9E).obs;
  final isPasswordMatch = false.obs;

  final List<String> businessTypes = [
    'Cafe & Beverage',
    'Retail & Mini Mart',
    'Bakery & Pastry',
    'Restaurant & Food',
  ];


  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void setBusinessType(String type) {
    selectedBusinessType.value = type;
  }

  void toggleAgreeTerms(bool? val) {
    agreeToTerms.value = val ?? false;
  }

  // Live password validation
  void evaluatePassword(String password) {
    passwordText.value = password;
    if (password.isEmpty) {
      passwordStrength.value = 0.0;
      passwordStrengthText.value = '';
      passwordStrengthColor.value = const Color(0xFF9E9E9E);
    } else if (password.length < 6) {
      passwordStrength.value = 0.25;
      passwordStrengthText.value = 'password_strength_weak'.tr;
      passwordStrengthColor.value = const Color(0xFFD32F2F);
    } else {
      int score = 1;
      if (password.length >= 8) score++;
      if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
      if (RegExp(r'[0-9]').hasMatch(password)) score++;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

      if (score <= 2) {
        passwordStrength.value = 0.5;
        passwordStrengthText.value = 'password_strength_weak'.tr;
        passwordStrengthColor.value = const Color(0xFFF57C00);
      } else if (score == 3 || score == 4) {
        passwordStrength.value = 0.75;
        passwordStrengthText.value = 'password_strength_medium'.tr;
        passwordStrengthColor.value = const Color(0xFFFFA000);
      } else {
        passwordStrength.value = 1.0;
        passwordStrengthText.value = 'password_strength_strong'.tr;
        passwordStrengthColor.value = const Color(0xFF2E7D32);
      }
    }

    evaluateConfirmPassword(confirmPasswordController.text);
  }

  void evaluateConfirmPassword(String confirmPassword) {
    confirmPasswordText.value = confirmPassword;
    final password = passwordController.text;
    if (confirmPassword.isEmpty || password.isEmpty) {
      isPasswordMatch.value = false;
    } else {
      isPasswordMatch.value = password == confirmPassword;
    }
  }

  bool validateTab1() {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final storeName = storeNameController.text.trim();

    if (fullName.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty || storeName.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'err_fill_all'.tr,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    }

    if (password.length < 6) {
      Get.snackbar(
        'warning'.tr,
        'err_pass_short'.tr,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'error'.tr,
        'err_pass_not_match'.tr,
        backgroundColor: Colors.redAccent.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    }

    return true;
  }

  Future<void> registerAccount() async {
    if (!validateTab1()) {
      currentTabIndex.value = 0;
      return;
    }

    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final storeName = storeNameController.text.trim();
    final branch = storeBranchController.text.trim().isNotEmpty
        ? storeBranchController.text.trim()
        : 'Main Branch';
    final address = storeAddressController.text.trim();
    final pin = quickPinController.text.trim();

    if (pin.isNotEmpty && pin.length != 4) {
      currentTabIndex.value = 1;
      Get.snackbar(
        'warning'.tr,
        'err_invalid_pin'.tr,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    if (!agreeToTerms.value) {
      currentTabIndex.value = 1;
      Get.snackbar(
        'warning'.tr,
        'err_agree_terms'.tr,
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
      final res = await ApiService.to.register({
        'full_name': fullName,
        'phone_number': phone,
        'email': email.isNotEmpty ? email : null,
        'password': password,
        'pin_code': pin.isNotEmpty ? pin : '1234',
        'role': 'store_admin',
        'store_name': storeName,
        'store_branch': branch,
        'business_type': selectedBusinessType.value,
        'address': address.isNotEmpty ? address : 'Phnom Penh, Cambodia',
      }, autoSetAuth: false);

      isLoading.value = false;

      if (!res.isSuccess) {
        Get.snackbar(
          'error'.tr,
          res.message ?? 'Registration failed',
          backgroundColor: Colors.redAccent.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        return;
      }

      // If AdministratorController is active, refresh live registrations queue
      if (Get.isRegistered<AdministratorController>()) {
        Get.find<AdministratorController>().fetchLivePlatformData();
      }
    } catch (_) {
      isLoading.value = false;
    }

    // Navigate to Registration Pending Approval Screen
    Get.off(() => RegistrationPendingScreen(
          storeName: storeName,
          ownerName: fullName,
          phone: phone,
          email: email,
          businessType: selectedBusinessType.value,
          branch: branch,
          address: address.isNotEmpty ? address : 'Phnom Penh, Cambodia',
          submittedAt: 'Just now',
        ));
  }

  void showTermsDialog(BuildContext context) {
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
                    Icons.verified_user_rounded,
                    color: AppThemes.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'terms_title'.tr,
                    style: TextStyle(
                      fontSize: 17,
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
              'terms_content'.tr,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  agreeToTerms.value = true;
                  Get.back();
                },
                child: Text('confirm'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
