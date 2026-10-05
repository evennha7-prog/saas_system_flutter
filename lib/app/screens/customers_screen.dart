import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class CustomerModel {
  final String id;
  String name;
  String phone;
  String tier;
  int points;
  double totalSpent;
  int ordersCount;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.tier,
    this.points = 0,
    this.totalSpent = 0.0,
    this.ordersCount = 0,
  });
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String searchQuery = '';
  final searchController = TextEditingController();
  bool isLoading = false;

  final List<CustomerModel> customers = [];

  List<CustomerModel> get filteredCustomers {
    if (searchQuery.isEmpty) return customers;
    final q = searchQuery.toLowerCase();
    return customers.where((c) {
      return c.name.toLowerCase().contains(q) || c.phone.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchCustomersFromApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCustomersFromApi() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getCustomers();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          customers.clear();
          for (var c in res.data!) {
            String tier = 'Regular Customer';
            if (c.points >= 200) {
              tier = 'Gold VIP (10% Off)';
            } else if (c.points >= 100) {
              tier = 'Silver Member (5% Off)';
            }
            customers.add(CustomerModel(
              id: c.id.toString(),
              name: c.name,
              phone: c.phoneNumber,
              tier: tier,
              points: c.points,
              totalSpent: c.totalSpent,
              ordersCount: c.visitsCount,
            ));
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showAddCustomerDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedTier = 'Regular Customer';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'add_customer_title'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : Colors.grey,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'customer_name_label'.tr,
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
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'phone_number_label'.tr,
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
                const SizedBox(height: 14),
                Text(
                  'member_tier_label'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        'Regular Customer',
                        'Silver Member (5% Off)',
                        'Gold VIP (10% Off)',
                      ].map((t) {
                        final isSelected = selectedTier == t;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(t),
                          selectedColor: primaryOrange,
                          backgroundColor: isDark
                              ? AppThemes.darkSurface
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppThemes.darkTextPrimary
                                      : Colors.black87),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              setSheetState(() => selectedTier = t),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
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
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      if (name.isEmpty) return;

                      Get.back();
                      try {
                        final api = ApiService.to;
                        await api.createCustomer({
                          'name': name,
                          'phone_number': phone,
                        });
                        fetchCustomersFromApi();
                      } catch (_) {}

                      Get.snackbar(
                        'success'.tr,
                        '${'customer_added_msg'.tr}: $name',
                        backgroundColor: const Color(0xFF1B5E20),
                        colorText: Colors.white,
                      );
                    },
                    child: Text(
                      'save_customer'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
          'customers'.tr,
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
        hintText: 'search_customer_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.person_add_alt_1_rounded,
        actionTooltip: 'add_customer_title'.tr,
        onActionTap: _showAddCustomerDialog,
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
                  // Stat Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStatCard(
                          context: context,
                          title: 'customers'.tr,
                          value: '${customers.length}',
                          icon: Icons.people_alt_rounded,
                          color: primaryOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniStatCard(
                          context: context,
                          title: 'total_points'.tr,
                          value: '${customers.fold<int>(0, (sum, c) => sum + c.points)}',
                          icon: Icons.stars_rounded,
                          color: const Color(0xFFF57F17),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniStatCard(
                          context: context,
                          title: 'total_spent'.tr,
                          value: '\$${customers.fold<double>(0, (sum, c) => sum + c.totalSpent).toStringAsFixed(0)}',
                          icon: Icons.monetization_on_rounded,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Customers List
                  if (filteredCustomers.isEmpty)
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
                    ...filteredCustomers.map((c) {
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
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: primaryOrange.withValues(alpha: 0.12),
                              child: Text(
                                c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                                style: const TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          c.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: c.tier.contains('Gold')
                                              ? const Color(0xFFFFF8E1)
                                              : (c.tier.contains('Silver')
                                                    ? const Color(0xFFECEFF1)
                                                    : const Color(0xFFF1F8E9)),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          c.tier.split(' ')[0],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: c.tier.contains('Gold')
                                                ? const Color(0xFFFF8F00)
                                                : (c.tier.contains('Silver')
                                                      ? const Color(0xFF455A64)
                                                      : const Color(0xFF33691E)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '📱 ${c.phone} • 🪙 ${c.points} Points',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Spent: \$${c.totalSpent.toStringAsFixed(2)} (${c.ordersCount} orders)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                Get.snackbar(
                                  c.name,
                                  'customer_history'.tr,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  // Add Customer Button
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
                      onPressed: _showAddCustomerDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                      label: Text(
                        'add_customer'.tr,
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

  Widget _buildMiniStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
