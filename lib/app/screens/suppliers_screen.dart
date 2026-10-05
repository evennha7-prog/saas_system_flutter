import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class SupplierModel {
  final String id;
  String companyName;
  String contactPerson;
  String phone;
  String category;
  double pendingPayables;

  SupplierModel({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.category,
    this.pendingPayables = 0.0,
  });
}

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  String searchQuery = '';
  final searchController = TextEditingController();
  bool isLoading = false;

  final List<SupplierModel> suppliers = [];

  List<SupplierModel> get filteredSuppliers {
    if (searchQuery.isEmpty) return suppliers;
    final q = searchQuery.toLowerCase();
    return suppliers.where((s) {
      return s.companyName.toLowerCase().contains(q) ||
          s.contactPerson.toLowerCase().contains(q) ||
          s.phone.contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchSuppliersFromApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSuppliersFromApi() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getSuppliers();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          suppliers.clear();
          for (var s in res.data!) {
            suppliers.add(SupplierModel(
              id: s.id.toString(),
              companyName: s.companyName ?? s.name,
              contactPerson: s.name,
              phone: s.phoneNumber,
              category: 'General Supplier',
              pendingPayables: s.totalPurchases,
            ));
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showAddSupplierDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final companyCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final catCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'add_supplier_title'.tr,
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
                controller: companyCtrl,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'supplier_company_name'.tr,
                  prefixIcon: const Icon(
                    Icons.business_rounded,
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
              const SizedBox(height: 10),
              TextField(
                controller: contactCtrl,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'customer_name'.tr,
                  prefixIcon: const Icon(
                    Icons.person_outline,
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
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'phone_number'.tr,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
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
              const SizedBox(height: 10),
              TextField(
                controller: catCtrl,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'supply_category_items'.tr,
                  prefixIcon: const Icon(
                    Icons.category_outlined,
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
                  onPressed: () async {
                    final company = companyCtrl.text.trim();
                    final contact = contactCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();
                    if (company.isEmpty) return;

                    Get.back();
                    try {
                      final api = ApiService.to;
                      await api.createSupplier({
                        'name': contact.isNotEmpty ? contact : company,
                        'company_name': company,
                        'phone_number': phone,
                      });
                      fetchSuppliersFromApi();
                    } catch (_) {}

                    Get.snackbar(
                      'success'.tr,
                      'supplier_saved_success'.tr,
                      backgroundColor: const Color(0xFF1B5E20),
                      colorText: Colors.white,
                    );
                  },
                  child: Text(
                    'save_supplier'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
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
          'suppliers'.tr,
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
        hintText: 'search_supplier_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.add_business_rounded,
        actionTooltip: 'add_supplier_title'.tr,
        onActionTap: _showAddSupplierDialog,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  // Top Suppliers Summary Card
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
                          'total_suppliers'.tr,
                          '${suppliers.length}',
                          Icons.storefront_rounded,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                        ),
                        _buildStat(
                          context,
                          'total_payable'.tr,
                          '\$${suppliers.fold<double>(0, (sum, s) => sum + s.pendingPayables).toStringAsFixed(2)}',
                          Icons.account_balance_wallet_outlined,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Suppliers List
                  if (filteredSuppliers.isEmpty)
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
                    ...filteredSuppliers.map((s) {
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
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: primaryOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.business_center_rounded,
                                color: primaryOrange,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.companyName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '👤 ${s.contactPerson} • 📱 ${s.phone}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '📦 ${s.category}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFE65100),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  s.pendingPayables > 0
                                      ? '\$${s.pendingPayables.toStringAsFixed(2)}'
                                      : 'Paid',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: s.pendingPayables > 0
                                        ? Colors.redAccent
                                        : const Color(0xFF4CAF50),
                                  ),
                                ),
                                Text(
                                  s.pendingPayables > 0 ? 'unpaid'.tr : 'paid'.tr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  // Add Supplier Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: primaryOrange.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _showAddSupplierDialog,
                      icon: const Icon(Icons.add_business_rounded, size: 20),
                      label: Text(
                        'add_supplier'.tr,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
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
            fontSize: 15,
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
