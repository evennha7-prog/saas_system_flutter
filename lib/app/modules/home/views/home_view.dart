import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screens/account_approvals_screen.dart';
import '../../../screens/customers_screen.dart';
import '../../../screens/expense_screen.dart';
import '../../../screens/notifications.dart';
import '../../../screens/products_screen.dart';
import '../../../screens/purchases_screen.dart';
import '../../../screens/report_screen.dart';
import '../../../screens/stock_adjustment_screen.dart';
import '../../../screens/stock_count_screen.dart';
import '../../../screens/suppliers_screen.dart';
import '../../../themes/themes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color darkBlue = AppThemes.darkBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color darkOrange = darkBlue;
  static const Color bgLight = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : primaryBlue,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        toolbarHeight: 64,
        title: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_cafe_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.shopName.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.cashierName.value.isNotEmpty
                          ? controller.cashierName.value
                          : 'Store Cashier',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Get.to(() => const NotificationsScreen()),
            tooltip: 'notifications'.tr,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          children: [
            // Clean Search Bar
            _buildSearchBar(context),
            const SizedBox(height: 14),

            // Summary Card (ប្រតិបត្តិការសង្ខេប)
            _buildSummaryCard(),
            const SizedBox(height: 14),

            // Top 2 Quick Actions (ឡូជីស្ទីក, របាយការណ៍)
            _buildTopTwoActions(context),
            const SizedBox(height: 12),

            // 6 Action Grid
            _buildSixActionGrid(context),
            const SizedBox(height: 14),

            // Data Analytics Section (វិភាគទិន្នន័យ)
            _buildAnalyticsCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          width: 1.2,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // Search Icon in soft rounded badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        const Color(0xFFEFF6FF),
                        const Color(0xFFDBEAFE),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: primaryBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.search_rounded,
                color: primaryBlue,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Search Input Field
          Expanded(
            child: TextField(
              controller: controller.searchController,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              cursorColor: primaryBlue,
              cursorWidth: 2.0,
              cursorRadius: const Radius.circular(2),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : Colors.grey.shade400,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (value) {
                Get.to(() => const ProductsScreen());
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // Summary Card (ប្រតិបត្តិការសង្ខេប)
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'summary_operations'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              Obx(
                () => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: controller.toggleBalanceVisibility,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        controller.isBalanceVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final isVisible = controller.isBalanceVisible.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'income'.tr,
                  isVisible
                      ? '\$${controller.income.value.toStringAsFixed(2)}'
                      : '****',
                ),
                _buildSummaryItem(
                  'expense'.tr,
                  isVisible
                      ? '\$${controller.expense.value.toStringAsFixed(2)}'
                      : '****',
                ),
                _buildSummaryItem(
                  'net_profit'.tr,
                  isVisible
                      ? '\$${controller.netProfit.value.toStringAsFixed(2)}'
                      : '****',
                  isHighlight: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isHighlight ? 16 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Top 2 Quick Actions
  Widget _buildTopTwoActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildWideActionCard(
            context: context,
            title: 'suppliers'.tr,
            icon: Icons.delivery_dining,
            iconColor: const Color(0xFFE65100),
            bgColor: const Color(0xFFFFF3E0),
            onTap: () => Get.to(() => const SuppliersScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildWideActionCard(
            context: context,
            title: 'reports'.tr,
            icon: Icons.pie_chart_rounded,
            iconColor: const Color(0xFFD84315),
            bgColor: const Color(0xFFFBE9E7),
            onTap: () => Get.to(() => const ReportScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildWideActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6 Action Grid
  Widget _buildSixActionGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> actions = [
    
     
      {
        'key': 'expense',
        'title': 'expense'.tr,
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFFD84315),
      },
   
      {
        'key': 'stock_count',
        'title': 'stock_count'.tr,
        'icon': Icons.fact_check_rounded,
        'color': const Color(0xFFE65100),
      },
      {
        'key': 'stock_adjustment',
        'title': 'stock_adjustment'.tr,
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFFD84315),
      },
         {
        'key': 'purchases',
        'title': 'purchases'.tr,
        'icon': Icons.shopping_cart_rounded,
        'color': const Color(0xFFF57C00),
      },
        {
        'key': 'customers',
        'title': 'customers'.tr,
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFFEF6C00),
      },
       {
        'key': 'products',
        'title': 'products'.tr,
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFFE65100),
      },
     
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        final title = (item['key'] as String).tr;
        return InkWell(
          onTap: () {
            switch (item['key']) {
              case 'account_approvals':
              case 'approvals':
                Get.to(() => const AccountApprovalsScreen());
                break;
              case 'customers':
                Get.to(() => const CustomersScreen());
                break;
              case 'products':
                Get.to(() => const ProductsScreen());
                break;
              case 'expense':
                Get.to(() => const ExpenseScreen());
                break;
              case 'purchases':
                Get.to(() => const PurchasesScreen());
                break;
              case 'stock_count':
                Get.to(() => const StockCountScreen());
                break;
              case 'stock_adjustment':
                Get.to(() => const StockAdjustmentScreen());
                break;
              default:
                Get.snackbar(title, '${'open_section'.tr} $title');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Data Analytics Card (វិភាគទិន្នន័យ)
  Widget _buildAnalyticsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
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
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
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
                'data_analytics'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => Text(
              '${controller.totalTransactions.value}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'total_daily_transactions'.tr,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
