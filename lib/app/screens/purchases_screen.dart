import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class PurchaseOrder {
  final String id;
  String supplier;
  String itemsSummary;
  double totalAmount;
  String date;
  String status; // 'Received', 'Pending', 'Cancelled'

  PurchaseOrder({
    required this.id,
    required this.supplier,
    required this.itemsSummary,
    required this.totalAmount,
    required this.date,
    this.status = 'Received',
  });
}

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  String searchQuery = '';
  final searchController = TextEditingController();
  bool isLoading = false;

  final List<PurchaseOrder> purchases = [];

  List<PurchaseOrder> get filteredPurchases {
    if (searchQuery.isEmpty) return purchases;
    final q = searchQuery.toLowerCase();
    return purchases.where((p) {
      return p.supplier.toLowerCase().contains(q) ||
          p.itemsSummary.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchPurchasesFromApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPurchasesFromApi() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getPurchases();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          purchases.clear();
          for (var p in res.data!) {
            final dateStr =
                '${p.createdAt.day}/${p.createdAt.month} ${p.createdAt.hour.toString().padLeft(2, '0')}:${p.createdAt.minute.toString().padLeft(2, '0')}';
            final summary = p.items.isNotEmpty
                ? p.items.map((i) => '${i.quantity}x ${i.productName}').join(', ')
                : 'Stock Procurement';
            purchases.add(PurchaseOrder(
              id: p.invoiceNumber,
              supplier: p.supplierName ?? 'General Supplier',
              itemsSummary: summary,
              totalAmount: p.totalAmount,
              date: dateStr,
              status: p.status,
            ));
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showAddPurchaseDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final supplierCtrl = TextEditingController(text: 'Boncafé Cambodia');
    final itemsCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'add_purchase_title'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: supplierCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'supplier_label'.tr,
                prefixIcon: const Icon(
                  Icons.store_rounded,
                  color: primaryOrange,
                ),
                filled: true,
                fillColor: isDark
                    ? AppThemes.darkSurface
                    : const Color(0xFFF9FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: itemsCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'items_and_qty_label'.tr,
                prefixIcon: const Icon(
                  Icons.inventory_2_outlined,
                  color: primaryOrange,
                ),
                filled: true,
                fillColor: isDark
                    ? AppThemes.darkSurface
                    : const Color(0xFFF9FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'total_cost_label'.tr,
                prefixIcon: const Icon(
                  Icons.attach_money_rounded,
                  color: primaryOrange,
                ),
                filled: true,
                fillColor: isDark
                    ? AppThemes.darkSurface
                    : const Color(0xFFF9FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final supplier = supplierCtrl.text.trim();
                  final items = itemsCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                  if (supplier.isEmpty || items.isEmpty || amount <= 0) return;

                  setState(() {
                    purchases.insert(
                      0,
                      PurchaseOrder(
                        id: 'PO-2026-${(purchases.length + 1).toString().padLeft(3, '0')}',
                        supplier: supplier,
                        itemsSummary: items,
                        totalAmount: amount,
                        date: 'Just now',
                        status: 'Pending',
                      ),
                    );
                  });
                  Get.back();
                  Get.snackbar(
                    'po_created'.tr,
                    '${'po_created_msg'.tr}: \$${amount.toStringAsFixed(2)}',
                    backgroundColor: const Color(0xFF1B5E20),
                    colorText: Colors.white,
                  );
                },
                child: Text(
                  'save_purchase'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
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
          'purchases'.tr,
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
        hintText: 'search_purchase_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.add_shopping_cart_rounded,
        actionTooltip: 'add_purchase_title'.tr,
        onActionTap: _showAddPurchaseDialog,
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
            // Purchases Summary Card
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    context,
                    'total_purchases'.tr,
                    '\$${purchases.fold<double>(0, (sum, p) => sum + p.totalAmount).toStringAsFixed(2)}',
                    Icons.shopping_bag_outlined,
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                  ),
                  _buildStat(
                    context,
                    'received_status'.tr,
                    '${purchases.where((p) => p.status == 'Received').length} POs',
                    Icons.check_circle_outline,
                    color: const Color(0xFF4CAF50),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                  ),
                  _buildStat(
                    context,
                    'pending_delivery_status'.tr,
                    '${purchases.where((p) => p.status == 'Pending').length} POs',
                    Icons.schedule_rounded,
                    color: const Color(0xFFFFB300),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Purchases List
            if (filteredPurchases.isEmpty)
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
              ...filteredPurchases.map((po) {
              final isReceived = po.status == 'Received';
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          po.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: primaryOrange,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isReceived
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            po.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isReceived
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      po.supplier,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      po.itemsSummary,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : Colors.grey.shade600,
                      ),
                    ),
                    Divider(
                      height: 16,
                      color: isDark
                          ? AppThemes.darkBorder
                          : AppThemes.lightBorder,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          po.date,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          '\$${po.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
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

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: color ?? primaryOrange, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
