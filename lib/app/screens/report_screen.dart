import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String selectedPeriod = 'today';
  bool isLoading = false;
  String searchQuery = '';
  final searchController = TextEditingController();

  double totalRevenue = 0.0;
  int totalOrders = 0;
  double netProfit = 0.0;
  double totalExpense = 0.0;

  final List<Map<String, dynamic>> topProducts = [];

  List<Map<String, dynamic>> get filteredTopProducts {
    if (searchQuery.isEmpty) return topProducts;
    final q = searchQuery.toLowerCase();
    return topProducts.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString().toLowerCase();
      return name.contains(q) || cat.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchReportData() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getDashboardSummary();
      if (res.isSuccess && res.data != null) {
        final d = res.data!;
        setState(() {
          totalRevenue = d.totalSales;
          totalOrders = d.totalOrders;
          totalExpense = d.totalExpenses;
          netProfit = d.netProfit;
        });
      }

      // Fetch products for catalog overview
      final prodRes = await api.getProducts();
      if (prodRes.isSuccess && prodRes.data != null && prodRes.data!.isNotEmpty) {
        setState(() {
          topProducts.clear();
          for (var p in prodRes.data!.take(10)) {
            topProducts.add({
              'name': p.name,
              'qty': p.stockQty,
              'revenue': p.price,
              'category': p.category,
            });
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
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
          'reports'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'export_audit_report'.tr,
                'export_success_msg'.tr,
                backgroundColor: const Color(0xFF1B5E20),
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomSearchDock(
        controller: searchController,
        hintText: 'search_report_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.refresh_rounded,
        actionTooltip: 'refresh'.tr,
        onActionTap: fetchReportData,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPeriodChip(context, 'today', 'filter_today'.tr),
                        const SizedBox(width: 8),
                        _buildPeriodChip(context, 'yesterday', 'filter_yesterday'.tr),
                        const SizedBox(width: 8),
                        _buildPeriodChip(context, 'this_week', 'filter_this_week'.tr),
                        const SizedBox(width: 8),
                        _buildPeriodChip(context, 'this_month', 'period_month'.tr),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
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
                              'total_revenue_amount'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+18.4% vs last week',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BannerStat(label: 'bills'.tr, value: '$totalOrders'),
                            _BannerStat(
                              label: 'net_profit'.tr,
                              value: '\$${netProfit.toStringAsFixed(2)}',
                            ),
                            _BannerStat(
                              label: 'avg_bill'.tr,
                              value: '\$${totalOrders > 0 ? (totalRevenue / totalOrders).toStringAsFixed(2) : "0.00"}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Methods Breakdown
                  _buildCardWrapper(
                    title: 'payment_breakdown'.tr,
                    icon: Icons.payments_rounded,
                    child: Column(
                      children: [
                        _buildPaymentProgress(
                          context,
                          'ABA KHQR (74%)',
                          0.74,
                          '\$1,362.00',
                          const Color(0xFF005A9C),
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentProgress(
                          context,
                          '${'payment_cash'.tr} (26%)',
                          0.26,
                          '\$478.50',
                          const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

            // Top Selling Products
            _buildCardWrapper(
              title: searchQuery.isNotEmpty
                  ? '${'top_selling_products'.tr} (${filteredTopProducts.length})'
                  : 'top_selling_products'.tr,
              icon: Icons.emoji_events_rounded,
              child: filteredTopProducts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          searchQuery.isNotEmpty ? 'no_data'.tr : 'no_data'.tr,
                          style: TextStyle(
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: filteredTopProducts.map((p) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppThemes.darkSurface
                                : const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(color: AppThemes.darkBorder)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: primaryOrange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_cafe_rounded,
                                  color: primaryOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${p['qty']} ${'items_sold_count'.tr}',
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
                                '\$${(p['revenue'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

  Widget _buildPeriodChip(BuildContext context, String id, String label) {
    final isSelected = selectedPeriod == id;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: primaryOrange,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? AppThemes.darkTextPrimary : Colors.black87),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      backgroundColor: isDark ? AppThemes.darkCard : Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? primaryOrange
              : (isDark ? AppThemes.darkBorder : Colors.grey.shade200),
        ),
      ),
      onSelected: (_) => setState(() => selectedPeriod = id),
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
              Icon(icon, color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentProgress(
    BuildContext context,
    String label,
    double value,
    String amount,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: isDark
                ? AppThemes.darkSurface
                : const Color(0xFFF0F2F5),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
