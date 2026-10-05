import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class RevenueOutletScreen extends StatefulWidget {
  const RevenueOutletScreen({super.key});

  @override
  State<RevenueOutletScreen> createState() => _RevenueOutletScreenState();
}

class _RevenueOutletScreenState extends State<RevenueOutletScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color primaryRed = Color(0xFFEF4444);

  final AdministratorController controller =
      Get.isRegistered<AdministratorController>()
      ? Get.find<AdministratorController>()
      : Get.put(AdministratorController());

  String selectedPeriod = 'all'; // 'today', 'week', 'month', 'all'
  String searchQuery = '';
  String sortBy = 'revenue'; // 'revenue', 'orders', 'name'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : primaryOrange,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: Material(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.lightImpact();
                Get.back();
              },
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'revenue_by_outlet'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'revenue_outlet_analytics_sub'.tr,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'refresh_revenue_data'.tr,
            onPressed: () async {
              HapticFeedback.lightImpact();
              await controller.fetchLivePlatformData();
              Get.snackbar(
                'refresh'.tr,
                'revenue_data_updated'.tr,
                backgroundColor: primaryOrange,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final allStores = controller.stores;
        final totalRevenue = controller.totalPlatformRevenue > 0
            ? controller.totalPlatformRevenue
            : 1.0;
        final totalOrders = controller.totalOrdersCount;

        // Apply search and sort
        var displayList = allStores.where((s) {
          if (searchQuery.isEmpty) return true;
          final q = searchQuery.toLowerCase();
          return s.name.toLowerCase().contains(q) ||
              s.branch.toLowerCase().contains(q) ||
              s.ownerName.toLowerCase().contains(q);
        }).toList();

        if (sortBy == 'revenue') {
          displayList.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
        } else if (sortBy == 'orders') {
          displayList.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
        } else if (sortBy == 'name') {
          displayList.sort((a, b) => a.name.compareTo(b.name));
        }

        final topStore = allStores.isNotEmpty
            ? (allStores.toList()
                    ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue)))
                  .first
            : null;

        return RefreshIndicator(
          color: primaryOrange,
          onRefresh: controller.fetchLivePlatformData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              // Summary KPI Hero Card
              _buildHeroSummaryCard(
                context,
                totalRevenue,
                totalOrders,
                topStore,
                isDark,
              ),
              const SizedBox(height: 14),

              // Period & Filter Selector Bar
              _buildFilterChipsBar(context, isDark),
              const SizedBox(height: 14),

              // Search and Sort Control
              _buildSearchAndSortBar(context, isDark),
              const SizedBox(height: 14),

              // Section Title with Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        size: 20,
                        color: primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'revenue_by_outlet'.tr,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${displayList.length} ${'outlets'.tr}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Main Outlets Revenue Card
              if (displayList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppThemes.darkBorder
                          : AppThemes.lightBorder,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'no_matching_stores'.tr,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppThemes.darkBorder
                          : AppThemes.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.0 : 0.03,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(displayList.length, (index) {
                      final store = displayList[index];
                      final percentage = (store.totalRevenue / totalRevenue)
                          .clamp(0.0, 1.0);
                      final isLast = index == displayList.length - 1;

                      return _buildOutletRowItem(
                        context: context,
                        store: store,
                        rank: index + 1,
                        percentage: percentage,
                        isLast: isLast,
                        isDark: isDark,
                      );
                    }),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroSummaryCard(
    BuildContext context,
    double totalRevenue,
    int totalOrders,
    StoreTenant? topStore,
    bool isDark,
  ) {
    final khr = (totalRevenue * 4100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60A5FA), // Royal Sky
            Color(0xFF2563EB), // Royal Blue
            Color(0xFF1D4ED8), // Deep Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Decorative background curves (Yellow + White wave highlights)
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: 30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
            ),

            // Foreground Logical Data Card Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Row: Wallet Icon + Title + Live Sync Badge (Wrapped in Expanded to fix 45px overflow!)
                  Row(
                    children: [
                      // White rounded icon box with warm orange wallet icon
                      Container(
                        padding: const EdgeInsets.all(7.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFF2563EB),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Title (Expanded with ellipsis -> GUARANTEED ZERO OVERFLOWS!)
                      Expanded(
                        child: Text(
                          'total_outlets_revenue'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Live Sync Badge (White frosted with pulsing green dot)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 7,
                              color: Color(0xFF4ADE80),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'live_sync'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Middle Row: Big Revenue Dollar Amount + KHR Equivalent
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$khr ៛',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Crisp White Translucent Divider
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                  const SizedBox(height: 12),

                  // 4. Bottom 2-Column Split: Top Outlet & Total Orders
                  Row(
                    children: [
                      // Left Column: Top Outlet
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'top_outlet'.tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              topStore != null
                                  ? '${topStore.name} (\$${topStore.totalRevenue.toStringAsFixed(0)})'
                                  : 'AudiCafe Flagship (\$6,420)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Middle Vertical Divider Line
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                      const SizedBox(width: 14),

                      // Right Column: Total Orders / Transactions
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'total_orders'.tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$totalOrders ${'transactions'.tr}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipsBar(BuildContext context, bool isDark) {
    final periods = [
      {'id': 'today', 'label': 'period_today'.tr},
      {'id': 'week', 'label': 'period_week'.tr},
      {'id': 'month', 'label': 'period_month'.tr},
      {'id': 'all', 'label': 'period_all'.tr},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: periods.map((p) {
          final isSelected = selectedPeriod == p['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(p['label']!),
              selectedColor: primaryOrange,
              backgroundColor: isDark ? AppThemes.darkCard : Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppThemes.darkTextPrimary : Colors.black87),
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? primaryOrange
                      : (isDark ? AppThemes.darkBorder : Colors.grey.shade300),
                ),
              ),
              onSelected: (_) {
                HapticFeedback.lightImpact();
                setState(() => selectedPeriod = p['id']!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
              ),
            ),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'search_outlet_hint'.tr,
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: primaryOrange,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: sortBy,
              icon: const Icon(
                Icons.sort_rounded,
                size: 18,
                color: primaryOrange,
              ),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              items: [
                DropdownMenuItem(value: 'revenue', child: Text('sort_revenue'.tr)),
                DropdownMenuItem(value: 'orders', child: Text('sort_orders'.tr)),
                DropdownMenuItem(value: 'name', child: Text('sort_name'.tr)),
              ],
              onChanged: (val) {
                if (val != null) {
                  HapticFeedback.lightImpact();
                  setState(() => sortBy = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutletRowItem({
    required BuildContext context,
    required StoreTenant store,
    required int rank,
    required double percentage,
    required bool isLast,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showOutletDetailSheet(context, store, percentage, isDark),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Outlet Row: Status Dot + Name + Revenue Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Status Dot (Green for Active, Red for Inactive matching reference)
                      Container(
                        width: 8.5,
                        height: 8.5,
                        decoration: BoxDecoration(
                          color: store.isActive ? primaryGreen : primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          store.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${store.totalRevenue.toStringAsFixed(2)} (${(percentage * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar (Blue / Grey matching design)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage > 0 ? percentage : 0.04,
                minHeight: 6,
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  store.isActive
                      ? primaryBlue
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOutletDetailSheet(
    BuildContext context,
    StoreTenant store,
    double percentage,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final aov = store.totalOrders > 0
        ? (store.totalRevenue / store.totalOrders)
        : 0.0;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          store.branch,
                          style: TextStyle(
                            fontSize: 12,
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (store.isActive ? primaryGreen : primaryRed)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: store.isActive ? primaryGreen : primaryRed,
                      ),
                    ),
                    child: Text(
                      store.isActive ? 'active'.tr : 'inactive'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: store.isActive ? primaryGreen : primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Detail Grid
              Row(
                children: [
                  Expanded(
                    child: _buildModalStatBox(
                      'total_revenue_amount'.tr,
                      '\$${store.totalRevenue.toStringAsFixed(2)}',
                      primaryOrange,
                      Icons.monetization_on_rounded,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildModalStatBox(
                      'market_share'.tr,
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      const Color(0xFF0288D1),
                      Icons.pie_chart_rounded,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildModalStatBox(
                      'total_orders'.tr,
                      '${store.totalOrders} ${'transactions'.tr}',
                      const Color(0xFF2E7D32),
                      Icons.receipt_long_rounded,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildModalStatBox(
                      'average_order_value'.tr,
                      '\$${aov.toStringAsFixed(2)}',
                      const Color(0xFF7B1FA2),
                      Icons.analytics_rounded,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Store Meta Info
              _buildDetailRow('store_owner'.tr, store.ownerName, isDark),
              _buildDetailRow('phone'.tr, store.phone, isDark),
              _buildDetailRow('store_address'.tr, store.address, isDark),
              _buildDetailRow(
                'staff_count'.tr,
                '${store.staffCount} ${'persons'.tr}',
                isDark,
              ),
              _buildDetailRow('store_plan'.tr, '${store.plan} Plan', isDark),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  if (store.phone.isNotEmpty && store.phone != 'N/A') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(
                            'tel:${store.phone.replaceAll(' ', '')}',
                          );
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        },
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: Text('phone'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text('close'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalStatBox(
    String title,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppThemes.darkTextSecondary
                  : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
