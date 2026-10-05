import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class StockAdjustmentLog {
  final String id;
  final String productName;
  final int qtyAdjusted;
  final String reason;
  final String date;

  StockAdjustmentLog({
    required this.id,
    required this.productName,
    required this.qtyAdjusted,
    required this.reason,
    required this.date,
  });
}

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String selectedProduct = '';
  String selectedReason = 'reason_damage_spoilage'.tr;
  String adjustmentType = 'Subtract (- Stock)';
  final qtyController = TextEditingController(text: '1');
  final noteController = TextEditingController();

  final List<String> productOptions = [];
  final List<String> reasonOptions = [
    'reason_damage_spoilage'.tr,
    'reason_sample_tasting'.tr,
    'reason_inventory_count_correction'.tr,
    'reason_lost_stolen'.tr,
  ];
  String searchQuery = '';
  final searchController = TextEditingController();
  final List<StockAdjustmentLog> recentLogs = [];

  List<StockAdjustmentLog> get filteredRecentLogs {
    if (searchQuery.isEmpty) return recentLogs;
    final q = searchQuery.toLowerCase();
    return recentLogs.where((l) {
      return l.productName.toLowerCase().contains(q) || l.reason.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    selectedReason = 'reason_damage_spoilage'.tr;
    fetchProductsForAdjustment();
  }

  @override
  void dispose() {
    qtyController.dispose();
    noteController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProductsForAdjustment() async {
    try {
      final api = ApiService.to;
      final res = await api.getProducts();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          productOptions.clear();
          for (var p in res.data!) {
            productOptions.add(p.name);
          }
          if (productOptions.isNotEmpty) {
            selectedProduct = productOptions.first;
          }
        });
      }
    } catch (_) {}
  }

  void _saveAdjustment() {
    final qty = int.tryParse(qtyController.text.trim()) ?? 1;
    final finalQty = adjustmentType.startsWith('Subtract') ? -qty : qty;

    setState(() {
      recentLogs.insert(
        0,
        StockAdjustmentLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productName: selectedProduct,
          qtyAdjusted: finalQty,
          reason: selectedReason,
          date: 'Just now',
        ),
      );
    });

    Get.snackbar(
      'success'.tr,
      'adjustment_saved_success'.tr,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
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
          'stock_adjustment'.tr,
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
        hintText: 'search_adjustment_history_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.check_rounded,
        actionTooltip: 'save_adjustment_btn'.tr,
        onActionTap: _saveAdjustment,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Adjustment Input Form Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: isDark
                    ? Border.all(color: AppThemes.darkBorder)
                    : Border.all(color: AppThemes.lightBorder),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: primaryOrange,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'inventory_adjustment_title'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Select Product Dropdown
                  Text(
                    'select_product_label'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : const Color(0xFF4A5260),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppThemes.darkBorder
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: isDark
                            ? AppThemes.darkCard
                            : Colors.white,
                        isExpanded: true,
                        value: selectedProduct,
                        items: productOptions.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedProduct = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // In/Out Type Switcher
                  Text(
                    'adjustment_type_label'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : const Color(0xFF4A5260),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          selected: adjustmentType.startsWith('Subtract'),
                          label: Text('stock_out_btn'.tr),
                          selectedColor: Colors.redAccent,
                          backgroundColor: isDark
                              ? AppThemes.darkSurface
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: adjustmentType.startsWith('Subtract')
                                ? Colors.white
                                : (isDark
                                      ? AppThemes.darkTextPrimary
                                      : Colors.black87),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(
                            () => adjustmentType = 'Subtract (- Stock)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          selected: adjustmentType.startsWith('Add'),
                          label: Text('stock_in_btn'.tr),
                          selectedColor: const Color(0xFF4CAF50),
                          backgroundColor: isDark
                              ? AppThemes.darkSurface
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: adjustmentType.startsWith('Add')
                                ? Colors.white
                                : (isDark
                                      ? AppThemes.darkTextPrimary
                                      : Colors.black87),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) =>
                              setState(() => adjustmentType = 'Add (+ Stock)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quantity
                  Text(
                    'adjustment_qty_label'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : const Color(0xFF4A5260),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.numbers_rounded,
                        color: primaryOrange,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryOrange,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reason Dropdown
                  Text(
                    'adjustment_reason_label'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : const Color(0xFF4A5260),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppThemes.darkBorder
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: isDark
                            ? AppThemes.darkCard
                            : Colors.white,
                        isExpanded: true,
                        value: selectedReason,
                        items: reasonOptions.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedReason = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveAdjustment,
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        'save_adjustment'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Adjustment History Log
            Text(
              'recent_adjustments_title'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            if (filteredRecentLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'no_data'.tr,
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              ...filteredRecentLogs.map((log) {
              final isNegative = log.qtyAdjusted < 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
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
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isNegative
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isNegative
                            ? Icons.remove_circle_outline_rounded
                            : Icons.add_circle_outline_rounded,
                        color: isNegative
                            ? Colors.redAccent
                            : const Color(0xFF4CAF50),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.productName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${log.reason} • ${log.date}',
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
                    Text(
                      isNegative ? '${log.qtyAdjusted}' : '+${log.qtyAdjusted}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isNegative
                            ? Colors.redAccent
                            : const Color(0xFF4CAF50),
                      ),
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
