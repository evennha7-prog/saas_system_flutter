import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/themes.dart';
import '../../../widgets/invoice_slip_dialog.dart';
import '../controllers/list_sales_controller.dart';

class ListSalesView extends GetView<ListSalesController> {
  const ListSalesView({super.key});

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

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
        centerTitle: true,
        title: Text(
          'sales_list_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: () {
              Get.snackbar('filter'.tr, 'select_date_range'.tr);
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomSearchDock(context),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.filterKeys.length,
              itemBuilder: (context, index) {
                final filterKey = controller.filterKeys[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() {
                    final isSelected =
                        controller.selectedFilterKey.value == filterKey;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(filterKey.tr),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? AppThemes.darkTextPrimary
                                  : Colors.black87),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                      selectedColor: primaryOrange,
                      backgroundColor: isDark
                          ? AppThemes.darkCard
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? primaryOrange
                              : (isDark
                                    ? AppThemes.darkBorder
                                    : Colors.grey.shade300),
                        ),
                      ),
                      onSelected: (_) {
                        controller.changeFilter(filterKey);
                      },
                    );
                  }),
                );
              },
            ),
          ),

          // Total bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      '${'invoice_count'.tr}: ${controller.filteredSales.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${'total'.tr}: \$${controller.totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sales List
          Expanded(
            child: Obx(
              () => RefreshIndicator(
                color: primaryOrange,
                onRefresh: () => controller.fetchSales(),
                child: ListView.separated(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredSales.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final sale = controller.filteredSales[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        if (sale.rawSale != null) {
                          InvoiceSlipDialog.show(
                            context,
                            data: InvoiceSlipData.fromSaleModel(sale.rawSale!),
                          );
                        } else {
                          InvoiceSlipDialog.show(
                            context,
                            data: InvoiceSlipData.fromSaleRecord(sale),
                          );
                        }
                      },
                      child: Container(
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
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sale.invoiceNo,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        sale.status.tr,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryOrange.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.visibility_outlined,
                                            size: 13,
                                            color: primaryOrange,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'view'.tr,
                                            style: const TextStyle(
                                              color: primaryOrange,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: isDark
                                      ? AppThemes.darkTextSecondary
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sale.customer.startsWith('general_')
                                      ? sale.customer.tr
                                      : sale.customer,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: isDark
                                      ? AppThemes.darkTextSecondary
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sale.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? AppThemes.darkBorder
                                  : AppThemes.lightBorder,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${sale.itemCount} ${'item_unit'.tr} • ${sale.paymentMethod.tr}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '\$${sale.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSearchDock(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchCtrl = TextEditingController(text: controller.searchQuery.value);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(
        14,
        8,
        14,
        (isKeyboardVisible ? 8 : 14) + bottomInset,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppThemes.darkBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !isKeyboardVisible,
        child: Row(
          children: [
            // Pill Search Input Field Box
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppThemes.darkBorder : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade500,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        cursorColor: primaryOrange,
                        onChanged: (val) {
                          controller.searchQuery.value = val.trim();
                        },
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 13.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'search_sales_invoice_hint'.tr,
                          hintStyle: TextStyle(
                            color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Obx(
                      () => controller.searchQuery.value.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchCtrl.clear();
                                controller.searchQuery.value = '';
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Circular Refresh / Filter Button (matches user's screenshot)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.fetchSales(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF60A5FA), primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryOrange.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
