import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/services/api_service.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/themes.dart';
import 'app/translations/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = Get.put<ApiService>(ApiService(), permanent: true);
  await apiService.autoDiscoverHost();
  await apiService.initSession();

  runApp(
    GetMaterialApp(
      title: "KITPRAK",
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: AppTranslations.defaultLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: apiService.isAuthenticated ? Routes.NAVBAR : Routes.LOGIN,
      getPages: AppPages.routes,
    ),
  );
}
