import 'package:get/get.dart';

import '../controllers/administrator_controller.dart';

class AdministratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdministratorController>(
      () => AdministratorController(),
      fenix: true,
    );
  }
}
