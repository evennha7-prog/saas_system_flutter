import 'package:get/get.dart';

import '../controllers/list_sales_controller.dart';

class ListSalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListSalesController>(() => ListSalesController(), fenix: true);
  }
}
