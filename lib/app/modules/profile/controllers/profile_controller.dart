import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_service.dart';
import '../../../themes/themes.dart';
import '../../../translations/translations.dart';

class ProfileController extends GetxController {
  final userName = 'Store User'.obs;
  final userEmail = ''.obs;
  final phoneNumber = ''.obs;
  final telegramUsername = ''.obs;
  final userRole = 'cashier'.obs;
  final userShift = 'Morning Shift (06:30 AM - 03:00 PM)'.obs;
  final avatarIndex = 0.obs;
  final storeName = 'Store'.obs;
  final storeBranch = 'Main Branch'.obs;
  final storeAddress = '#128, St 2004, Sangkat Teuk Thla, Phnom Penh'.obs;
  final currentStoreId = 1.obs;

  final autoPrintReceipt = true.obs;
  final soundAlert = true.obs;
  final isDarkMode = false.obs;
  final currentThemeMode = ThemeMode.light.obs;
  final currentLocale = (Get.locale ?? AppTranslations.defaultLocale).obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = Get.isDarkMode;
    currentThemeMode.value = Get.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _syncWithCurrentUser();
    try {
      ever(Get.find<ApiService>().currentUser, (_) => _syncWithCurrentUser());
      ever(Get.find<ApiService>().currentStoreId, (_) => _syncWithCurrentUser());
    } catch (_) {}
  }

  void _syncWithCurrentUser() {
    try {
      final user = Get.find<ApiService>().currentUser.value;
      if (user != null) {
        userName.value = user.fullName;
        userEmail.value = user.email ?? '';
        phoneNumber.value = user.phoneNumber;
        telegramUsername.value = user.telegramUsername ?? '';
        userRole.value = user.role;
        userShift.value = user.shift ?? 'Morning Shift';
        avatarIndex.value = user.avatarIndex;
        if (user.storeName != null && user.storeName!.isNotEmpty) {
          storeName.value = user.storeName!;
        }
        if (user.storeId > 0) {
          currentStoreId.value = user.storeId;
        }
      }
    } catch (_) {}
  }


  String get roleDisplayLabel {
    final role = userRole.value.toLowerCase().trim();
    if (role == 'super_admin' || role == 'administrator' || role == 'superadmin') {
      return 'role_super_admin'.tr;
    } else if (role == 'store_admin' || role == 'store_manager' || role == 'owner') {
      return 'role_store_admin'.tr;
    } else if (role == 'stock_admin') {
      return 'role_stock_admin'.tr;
    }
    return 'role_cashier'.tr;
  }

  Color get roleColor {
    final role = userRole.value.toLowerCase().trim();
    if (role == 'super_admin' || role == 'administrator' || role == 'superadmin') {
      return const Color(0xFF6200EE);
    } else if (role == 'store_admin' || role == 'store_manager' || role == 'owner') {
      return AppThemes.primaryBlue;
    } else if (role == 'stock_admin') {
      return const Color(0xFF00897B);
    }
    return const Color(0xFF1E88E5);
  }

  bool get isSuperAdmin {
    final role = userRole.value.toLowerCase().trim();
    if (role == 'super_admin' || role == 'superadmin') {
      return true;
    }
    try {
      final apiUser = Get.find<ApiService>().currentUser.value;
      if (apiUser != null) {
        final apiRole = apiUser.role.toLowerCase().trim();
        if (apiRole == 'super_admin' || apiRole == 'superadmin') {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }


  void toggleAutoPrint(bool val) => autoPrintReceipt.value = val;
  void toggleSound(bool val) => soundAlert.value = val;

  void updateProfile({
    required String name,
    required String phone,
    required String role,
  }) {
    userName.value = name;
    phoneNumber.value = phone;
    userRole.value = role;
  }

  void toggleTheme(bool val) {
    setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    currentThemeMode.value = mode;
    isDarkMode.value = (mode == ThemeMode.dark);
    AppThemes.setThemeMode(mode);
  }

  String get currentThemeTitle {
    if (currentThemeMode.value == ThemeMode.dark) {
      return 'dark_mode'.tr;
    } else if (currentThemeMode.value == ThemeMode.light) {
      return 'light_mode'.tr;
    }
    return 'system_mode'.tr;
  }

  void changeLanguage(Locale locale) {
    currentLocale.value = locale;
    AppTranslations.changeLocale(locale);
  }

  String get currentLanguageTitle {
    final code = currentLocale.value.languageCode;
    if (code == 'km') {
      return 'ភាសាខ្មែរ (Khmer)';
    }
    return 'English (US)';
  }
}
