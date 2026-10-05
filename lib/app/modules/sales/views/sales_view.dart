import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/themes.dart';
import '../../../widgets/invoice_slip_dialog.dart';
import '../../navbar/controllers/navbar_controller.dart';
import '../controllers/sales_controller.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({super.key});

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  IconData _getCategoryIcon(String iconKey, String categoryKey) {
    if (iconKey == 'all' || categoryKey == 'cat_all') return Icons.apps_rounded;
    if (iconKey == 'local_cafe' || categoryKey.contains('coffee')) return Icons.local_cafe_rounded;
    if (iconKey == 'emoji_food_beverage' || categoryKey.contains('tea')) return Icons.emoji_food_beverage_rounded;
    if (iconKey == 'bakery_dining' || categoryKey.contains('bakery') || categoryKey.contains('bread')) return Icons.bakery_dining_rounded;
    if (iconKey == 'liquor' || iconKey == 'local_bar' || categoryKey.contains('beverage') || categoryKey.contains('drink')) return Icons.local_bar_rounded;
    if (iconKey == 'icecream' || categoryKey.contains('dessert')) return Icons.icecream_rounded;
    if (iconKey == 'restaurant' || categoryKey.contains('food')) return Icons.restaurant_rounded;
    if (iconKey == 'fastfood' || categoryKey.contains('snack')) return Icons.fastfood_rounded;
    return Icons.category_rounded;
  }

  IconData _getProductCategoryIcon(String categoryKey) {
    final c = categoryKey.toLowerCase();
    if (c.contains('coffee')) return Icons.local_cafe_rounded;
    if (c.contains('tea')) return Icons.emoji_food_beverage_rounded;
    if (c.contains('bakery') || c.contains('bread')) return Icons.bakery_dining_rounded;
    if (c.contains('beverage') || c.contains('drink')) return Icons.local_bar_rounded;
    if (c.contains('dessert') || c.contains('ice')) return Icons.icecream_rounded;
    if (c.contains('food')) return Icons.restaurant_rounded;
    return Icons.category_rounded;
  }

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
        title: Text(
          'pos_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              if (Get.isRegistered<NavbarController>()) {
                Get.find<NavbarController>().changePage(2);
              }
            },
            tooltip: 'nav_scanner'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
            onPressed: () {
              if (controller.cart.isNotEmpty) {
                controller.clearCart();
                Get.snackbar('clear'.tr, 'cart_cleared_msg'.tr);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.updateSearchQuery,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'search_product_hint'.tr,
                hintStyle: TextStyle(
                  color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade400,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade500,
                  size: 22,
                ),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.updateSearchQuery('');
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: isDark
                      ? const BorderSide(color: AppThemes.darkBorder)
                      : const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: isDark
                      ? const BorderSide(color: AppThemes.darkBorder)
                      : const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: isDark
                      ? const BorderSide(color: AppThemes.darkBorder)
                      : const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // Category horizontal selector
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                final isSelected =
                    controller.selectedCategoryKey.value == cat.key;
                final displayName = cat.key == 'cat_all'
                    ? 'cat_all'.tr
                    : (cat.label.tr == cat.label ? cat.label : cat.label.tr);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    avatar: isSelected
                        ? null
                        : Icon(
                            _getCategoryIcon(cat.icon, cat.key),
                            size: 16,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.black54,
                          ),
                    label: Text(displayName),
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
                    backgroundColor: isDark
                        ? AppThemes.darkCard
                        : Colors.white,
                    selectedColor: primaryOrange,
                    checkmarkColor: Colors.white,
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
                      controller.selectedCategoryKey.value = cat.key;
                    },
                  ),
                );
              },
            )),
          ),

          // Product Grid with Pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              color: primaryOrange,
              onRefresh: () => controller.fetchLiveProducts(),
              child: Obx(() {
                final items = controller.filteredProducts;
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'no_data'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Thumbnail with Icon and Badges (Matched to Design Style)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Container(
                                  height: 98,
                                  width: double.infinity,
                                  color: item.color.withValues(alpha: 0.12),
                                  child: Center(
                                    child: Icon(
                                      _getProductCategoryIcon(item.category),
                                      color: item.color,
                                      size: 38,
                                    ),
                                  ),
                                ),
                              ),

                              // Stock badge (Top Right)
                              Positioned(
                                top: 7,
                                right: 7,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${'stock'.tr}: ${item.stock}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // Category pill (Top Left)
                              Positioned(
                                top: 7,
                                left: 7,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getProductCategoryIcon(item.category),
                                        color: Colors.white,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        item.category.tr == item.category
                                            ? item.category.replaceFirst('cat_', '')
                                            : item.category.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Product Info & Price
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '\$${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    color: primaryOrange,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Add to cart button with in-cart count badge and +/- stepper
                                Obx(() {
                                  final inCartCount =
                                      controller.getProductCartCount(item.id);
                                  final isInCart = inCartCount > 0;

                                  if (isInCart) {
                                    return Container(
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E7D32),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Minus Button
                                          InkWell(
                                            onTap: () =>
                                                controller.removeFromCart(item),
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                                    left: Radius.circular(10)),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.remove_rounded,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                            ),
                                          ),
                                          // Count
                                          Text(
                                            '$inCartCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          // Plus Button
                                          InkWell(
                                            onTap: () =>
                                                controller.addToCart(item),
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                                    right: Radius.circular(10)),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.add_rounded,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 32,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryOrange,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () =>
                                          controller.addToCart(item),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'add_extra'.tr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      bottomSheet: Obx(() {
        if (controller.cart.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: isDark
                ? const Border(top: BorderSide(color: AppThemes.darkBorder, width: 1.2))
                : Border(top: BorderSide(color: Colors.grey.shade200, width: 1.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cart Header with Items count, Clear, and Expand toggle
                InkWell(
                  onTap: controller.toggleCartExpanded,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Column(
                      children: [
                        // Drag Indicator
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: primaryOrange.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: primaryOrange,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${controller.totalItemCount} ${'item_unit'.tr}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  controller.isCartExpanded.value
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_up_rounded,
                                  color: isDark
                                      ? AppThemes.darkTextSecondary
                                      : Colors.grey.shade600,
                                  size: 20,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'total'.tr,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : Colors.grey.shade600,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '\$${controller.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17.5,
                                    color: primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded Cart Items List
                if (controller.isCartExpanded.value) ...[
                  const Divider(height: 1, thickness: 0.8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.28,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      itemCount: controller.cart.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 12,
                        color: isDark ? AppThemes.darkBorder : Colors.grey.shade100,
                      ),
                      itemBuilder: (context, index) {
                        final cartItem = controller.cart[index];
                        final product = cartItem.product;

                        return Obx(() {
                          final qty = cartItem.quantity.value;
                          final subtotal = product.price * qty;

                          return Row(
                            children: [
                              // Product Thumbnail Icon
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: product.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(
                                    _getProductCategoryIcon(product.category),
                                    color: product.color,
                                    size: 19,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Product Name & Price / Subtotal
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)} × $qty = \$${subtotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppThemes.darkTextSecondary
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Stepper: [-] [qty] [+]
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppThemes.darkSurface
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark
                                        ? AppThemes.darkBorder
                                        : Colors.grey.shade300,
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Minus / Remove
                                    InkWell(
                                      onTap: () => controller.removeFromCart(product),
                                      borderRadius: const BorderRadius.horizontal(
                                          left: Radius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          qty == 1
                                              ? Icons.delete_outline_rounded
                                              : Icons.remove_rounded,
                                          size: 16,
                                          color: qty == 1
                                              ? Colors.red.shade400
                                              : primaryOrange,
                                        ),
                                      ),
                                    ),
                                    // Quantity Text
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '$qty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    // Plus
                                    InkWell(
                                      onTap: () => controller.addToCart(product),
                                      borderRadius: const BorderRadius.horizontal(
                                          right: Radius.circular(20)),
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 16,
                                          color: primaryOrange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                      },
                    ),
                  ),
                ],

                const Divider(height: 1, thickness: 0.8),

                // Checkout Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _showCheckoutDialog(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.point_of_sale_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${'checkout'.tr} • \$${controller.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
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
                  'checkout_dialog_title'.tr,
                  style: TextStyle(
                    fontSize: 18,
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
            Text(
              'checkout_prompt'.tr,
              style: TextStyle(
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // ABA KHQR Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00385F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  final sale = await controller.processCheckout(paymentMethod: 'ABA_KHQR');
                  if (sale != null && context.mounted) {
                    InvoiceSlipDialog.show(
                      context,
                      data: InvoiceSlipData.fromSaleModel(sale),
                    );
                  }
                },
                icon: const Icon(Icons.qr_code_2_rounded, size: 24),
                label: Text(
                  'ABA KHQR - \$${controller.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cash Payment Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryOrange,
                  side: const BorderSide(color: primaryOrange, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  final sale = await controller.processCheckout(paymentMethod: 'CASH');
                  if (sale != null && context.mounted) {
                    InvoiceSlipDialog.show(
                      context,
                      data: InvoiceSlipData.fromSaleModel(sale),
                    );
                  }
                },
                icon: const Icon(Icons.payments_outlined, size: 24),
                label: Text(
                  'payment_cash'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
