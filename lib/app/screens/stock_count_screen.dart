import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/sales/controllers/sales_controller.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class StockCountItem {
  final String id;
  final String name;
  final String category;
  int systemQty;
  int physicalQty;

  StockCountItem({
    required this.id,
    required this.name,
    required this.category,
    required this.systemQty,
    required this.physicalQty,
  });

  int get variance => physicalQty - systemQty;
}

class StockCountScreen extends StatefulWidget {
  const StockCountScreen({super.key});

  @override
  State<StockCountScreen> createState() => _StockCountScreenState();
}

class _StockCountScreenState extends State<StockCountScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  String searchQuery = '';
  final searchController = TextEditingController();
  bool isLoading = false;

  final List<StockCountItem> stockItems = [];

  List<StockCountItem> get filteredStockItems {
    if (searchQuery.isEmpty) return stockItems;
    final q = searchQuery.toLowerCase();
    return stockItems.where((i) {
      return i.name.toLowerCase().contains(q) || i.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchLiveStock();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchLiveStock() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getProducts();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          stockItems.clear();
          for (var p in res.data!) {
            stockItems.add(StockCountItem(
              id: p.id.toString(),
              name: p.name,
              category: p.category,
              systemQty: p.stockQty,
              physicalQty: p.stockQty,
            ));
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _submitAudit() {
    int matched = stockItems.where((i) => i.variance == 0).length;
    int mismatched = stockItems.where((i) => i.variance != 0).length;

    Get.defaultDialog(
      title: 'submit_audit'.tr,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Text('${'matched_items'.tr}: $matched ${'item_unit'.tr}'),
            const SizedBox(height: 4),
            Text(
              '${'mismatched_items'.tr}: $mismatched ${'item_unit'.tr}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'confirm'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: primaryOrange,
      onConfirm: () async {
        Get.back();
        setState(() => isLoading = true);

        try {
          final api = ApiService.to;
          int updatedCount = 0;

          // Sync all items with variances to the FastAPI backend
          for (var item in stockItems) {
            if (item.variance != 0) {
              final prodId = int.tryParse(item.id);
              if (prodId != null) {
                final res = await api.updateProduct(prodId, {
                  'stock_qty': item.physicalQty,
                });
                if (res.isSuccess) {
                  item.systemQty = item.physicalQty;
                  updatedCount++;
                }
              }
            }
          }

          if (Get.isRegistered<SalesController>()) {
            Get.find<SalesController>().fetchLiveProducts();
          }

          Get.snackbar(
            'success'.tr,
            '$updatedCount ${'stock_count_saved_success'.tr}',
            backgroundColor: const Color(0xFF1B5E20),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } catch (_) {
          Get.snackbar(
            'error'.tr,
            'Failed to sync stock count with server',
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
          );
        } finally {
          if (mounted) setState(() => isLoading = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'stock_count'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomSearchDock(
        controller: searchController,
        hintText: 'search_stock_count_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.check_rounded,
        actionTooltip: 'verify_record_stock'.tr,
        onActionTap: _submitAudit,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkSurface : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppThemes.darkBorder
                      : const Color(0xFFFFD1B2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.fact_check_outlined,
                    color: primaryOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${'physical_inventory_audit'.tr}\n${'physical_inventory_desc'.tr}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : const Color(0xFF8A3B00),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stock Count Items
            if (filteredStockItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'no_data'.tr,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredStockItems.map((item) {
              final varVal = item.variance;
              Color varianceColor = const Color(0xFF4CAF50);
              if (varVal < 0) varianceColor = Colors.redAccent;
              if (varVal > 0) varianceColor = const Color(0xFF2196F3);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark
                      ? Border.all(color: AppThemes.darkBorder)
                      : Border.all(color: AppThemes.lightBorder),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${item.category} • ${'system_qty'.tr}: ${item.systemQty}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppThemes.darkTextSecondary
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: varianceColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            varVal == 0
                                ? 'match'.tr
                                : (varVal > 0 ? '+$varVal' : '$varVal'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: varianceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'physical_qty'.tr}:',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppThemes.darkSurface
                                    : const Color(0xFFF3F5F9),
                              ),
                              icon: Icon(
                                Icons.remove,
                                size: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                              onPressed: () {
                                if (item.physicalQty > 0) {
                                  setState(() => item.physicalQty--);
                                }
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppThemes.darkSurface
                                    : const Color(0xFFF9FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? AppThemes.darkBorder
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                '${item.physicalQty}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppThemes.darkSurface
                                    : const Color(0xFFF3F5F9),
                              ),
                              icon: Icon(
                                Icons.add,
                                size: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                              onPressed: () {
                                setState(() => item.physicalQty++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ],
),
    );
  }

}
