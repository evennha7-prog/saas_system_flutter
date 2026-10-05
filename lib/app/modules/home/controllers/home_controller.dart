library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class HomeController extends GetxController {
  // Search
  final searchController = TextEditingController();

  // Store & profile info
  final shopName = 'AudiCafe'.obs;
  final cashierName = 'Store Cashier'.obs;
  final phoneNumber = ''.obs;

  // Financial summary
  final income = 0.0.obs;
  final expense = 0.0.obs;
  final netProfit = 0.0.obs;

  // Toggle privacy / eye visibility
  final isBalanceVisible = true.obs;

  // Analytics stat
  final totalTransactions = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    syncUserInfo();
    fetchDashboardData();
    try {
      ever(ApiService.to.currentUser, (_) {
        syncUserInfo();
        fetchDashboardData();
      });
      ever(ApiService.to.currentStoreId, (_) {
        syncUserInfo();
        fetchDashboardData();
      });
    } catch (_) {}
  }

  void syncUserInfo() {
    final user = ApiService.to.currentUser.value;
    if (user != null) {
      cashierName.value = user.fullName.isNotEmpty ? user.fullName : 'Store Staff';
      phoneNumber.value = user.phoneNumber;
      if (user.storeName != null && user.storeName!.isNotEmpty) {
        shopName.value = user.storeName!;
      }
    }
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      syncUserInfo();
      final api = ApiService.to;
      final res = await api.getDashboardSummary();
      isLoading.value = false;

      if (res.isSuccess && res.data != null) {
        final summary = res.data!;
        income.value = summary.totalSales;
        expense.value = summary.totalExpenses;
        netProfit.value = summary.netProfit;
        totalTransactions.value = summary.totalOrders;
      }
    } catch (_) {
      isLoading.value = false;
    }
  }
}
