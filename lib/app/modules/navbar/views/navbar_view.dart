import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/themes.dart';
import '../../../widgets/exit_app_dialog.dart';
import '../../home/views/home_view.dart';
import '../../list_sales/views/list_sales_view.dart';
import '../../profile/views/profile_view.dart';
import '../../sales/views/sales_view.dart';
import '../../scanner/views/scanner_view.dart';
import '../controllers/navbar_controller.dart';

class NavbarView extends GetView<NavbarController> {
  const NavbarView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = AppThemes.primaryBlue;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (controller.currentIndex.value != 0) {
          controller.changePage(0);
          return;
        }
        await showExitAppDialog(context);
      },
      child: Obx(
        () => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              const HomeView(),
              const SalesView(),
              controller.currentIndex.value == 2
                  ? const ScannerView()
                  : const SizedBox.shrink(),
              const ListSalesView(),
              const ProfileView(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: controller.currentIndex.value,
                onTap: controller.changePage,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).cardColor,
                selectedItemColor: primaryBlue,
                unselectedItemColor: const Color(0xFF8E8E93),
                selectedFontSize: 11,
                unselectedFontSize: 10,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.storefront_outlined),
                    activeIcon: const Icon(Icons.storefront_rounded),
                    label: 'nav_home'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.point_of_sale_outlined),
                    activeIcon: const Icon(Icons.point_of_sale_rounded),
                    label: 'nav_sales'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    label: 'nav_scanner'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.receipt_long_outlined),
                    activeIcon: const Icon(Icons.receipt_long_rounded),
                    label: 'nav_sales_list'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline_rounded),
                    activeIcon: const Icon(Icons.person_rounded),
                    label: 'nav_profile'.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
