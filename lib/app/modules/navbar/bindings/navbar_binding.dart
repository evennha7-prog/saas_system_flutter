import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../../list_sales/controllers/list_sales_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../sales/controllers/sales_controller.dart';
import '../../scanner/controllers/scanner_controller.dart';
import '../controllers/navbar_controller.dart';

class NavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavbarController>(() => NavbarController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SalesController>(() => SalesController(), fenix: true);
    Get.lazyPut<ScannerController>(() => ScannerController(), fenix: true);
    Get.lazyPut<ListSalesController>(() => ListSalesController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
