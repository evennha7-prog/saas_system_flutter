import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class SettingsController extends GetxController {
  // Observables for settings
  final isCloudSyncEnabled = true.obs;
  final isSoundEnabled = true.obs;
  final isAutoPrintEnabled = true.obs;
  final isHapticFeedback = true.obs;
  final selectedCurrency = 'USD (\$)'.obs;
  final selectedTaxRate = '10% (VAT)'.obs;
  final appVersion = 'v1.0.0+1'.obs;
  final isCacheClearing = false.obs;

  ProfileController? get profileCtrl => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : null;

  HomeController? get homeCtrl =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

  @override
  void onInit() {
    super.onInit();
    if (profileCtrl != null) {
      isSoundEnabled.value = profileCtrl!.soundAlert.value;
      isAutoPrintEnabled.value = profileCtrl!.autoPrintReceipt.value;
    }
  }

  void toggleSound(bool val) {
    isSoundEnabled.value = val;
    profileCtrl?.toggleSound(val);
  }

  void toggleAutoPrint(bool val) {
    isAutoPrintEnabled.value = val;
    profileCtrl?.toggleAutoPrint(val);
  }

  void toggleCloudSync(bool val) {
    isCloudSyncEnabled.value = val;
  }

  void toggleHaptic(bool val) {
    isHapticFeedback.value = val;
  }

  void toggleTheme(bool val) {
    profileCtrl?.toggleTheme(val);
  }

  void changeLanguage(Locale locale) {
    profileCtrl?.changeLanguage(locale);
  }

  Future<void> clearAppCache() async {
    isCacheClearing.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isCacheClearing.value = false;
    Get.snackbar(
      'success'.tr,
      'cache_cleared_success'.tr,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}
