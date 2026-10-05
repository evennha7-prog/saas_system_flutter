import 'package:get/get.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/services/api_service.dart';

class SaleRecord {
  final String invoiceNo;
  final String time;
  final DateTime? fullDate;
  final String customer;
  final int itemCount;
  final double amount;
  final String paymentMethod;
  final String status;
  final SaleModel? rawSale;

  SaleRecord({
    required this.invoiceNo,
    required this.time,
    this.fullDate,
    required this.customer,
    required this.itemCount,
    required this.amount,
    required this.paymentMethod,
    this.status = 'paid_status',
    this.rawSale,
  });
}

class ListSalesController extends GetxController {
  final selectedFilterKey = 'filter_today'.obs;
  final isLoading = false.obs;

  final filterKeys = [
    'filter_all',
    'filter_today',
    'filter_yesterday',
    'filter_this_week',
  ];

  final RxList<SaleRecord> sales = <SaleRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
    try {
      ever(ApiService.to.currentStoreId, (_) {
        sales.clear();
        fetchSales();
      });
      ever(ApiService.to.currentUser, (_) {
        sales.clear();
        fetchSales();
      });
    } catch (_) {}
  }

  void changeFilter(String key) {
    selectedFilterKey.value = key;
    fetchSales();
  }

  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      String? preset;
      if (selectedFilterKey.value == 'filter_today') preset = 'today';
      if (selectedFilterKey.value == 'filter_yesterday') preset = 'yesterday';
      if (selectedFilterKey.value == 'filter_this_week') preset = 'this_week';

      final api = ApiService.to;
      final res = await api.getSales(filterPreset: preset);
      isLoading.value = false;

      if (res.isSuccess && res.data != null) {
        sales.clear();
        for (var s in res.data!) {
          final timeStr =
              '${s.createdAt.hour.toString().padLeft(2, '0')}:${s.createdAt.minute.toString().padLeft(2, '0')}';
          sales.add(SaleRecord(
            invoiceNo: s.invoiceNumber,
            time: timeStr,
            fullDate: s.createdAt,
            customer: s.customerName?.isNotEmpty == true
                ? s.customerName!
                : 'general_customer',
            itemCount: s.items.isNotEmpty
                ? s.items.fold<int>(0, (sum, i) => sum + i.quantity)
                : 1,
            amount: s.finalAmount,
            paymentMethod: s.paymentMethod.toUpperCase().contains('KHQR')
                ? 'payment_khqr'
                : 'payment_cash',
            status: 'paid_status',
            rawSale: s,
          ));
        }
      }
    } catch (_) {
      isLoading.value = false;
    }
  }

  final searchQuery = ''.obs;

  List<SaleRecord> get filteredSales {
    if (searchQuery.value.isEmpty) return sales;
    final q = searchQuery.value.toLowerCase();
    return sales.where((s) => s.invoiceNo.toLowerCase().contains(q) || s.customer.toLowerCase().contains(q)).toList();
  }

  double get totalRevenue =>
      filteredSales.fold(0, (sum, item) => sum + item.amount);
}
