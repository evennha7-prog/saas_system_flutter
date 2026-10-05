import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kit_prak/app/data/services/api_service.dart';
import 'package:kit_prak/app/modules/navbar/views/navbar_view.dart';
import 'package:kit_prak/app/routes/app_pages.dart';
import 'package:kit_prak/app/themes/themes.dart';
import 'package:kit_prak/app/translations/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.reset();
    Get.put<ApiService>(ApiService(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('NavbarView smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: AppTranslations.defaultLocale,
        fallbackLocale: AppTranslations.fallbackLocale,
        theme: AppThemes.lightTheme,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavbarView), findsOneWidget);
    expect(find.text('ទំព័រដើម'), findsOneWidget);
  });
}
