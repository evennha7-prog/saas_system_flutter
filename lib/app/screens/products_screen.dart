import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/models/product_model.dart';
import '../data/services/api_service.dart';
import '../modules/sales/controllers/sales_controller.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class CategoryItem {
  final int? id;
  final String key;
  final String label;
  final String icon;
  final bool isCustom;

  CategoryItem({
    this.id,
    required this.key,
    required this.label,
    this.icon = 'category',
    this.isCustom = false,
  });
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  final TextEditingController searchCtrl = TextEditingController();

  bool isLoading = false;
  String selectedCategory = 'all';
  String searchQuery = '';
  String stockFilter = 'all'; // 'all', 'in_stock', 'low_stock', 'out_of_stock'
  String sortBy = 'default'; // 'default', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'stock_asc', 'stock_desc'

  final List<ProductModel> products = [];
  final List<CategoryItem> categories = [];

  final List<CategoryItem> defaultCategories = [
    CategoryItem(key: 'all', label: 'cat_all', icon: 'all'),
  ];

  final List<Map<String, dynamic>> productPalette = [
    {'name': 'Emerald Forest', 'hex': '#2E7D32', 'color': const Color(0xFF2E7D32)},
    {'name': 'Matcha Teal', 'hex': '#00897B', 'color': const Color(0xFF00897B)},
    {'name': 'Espresso Roast', 'hex': '#6D4C41', 'color': const Color(0xFF6D4C41)},
    {'name': 'Amber Orange', 'hex': '#F35E17', 'color': const Color(0xFFF35E17)},
    {'name': 'Golden Honey', 'hex': '#F57F17', 'color': const Color(0xFFF57F17)},
    {'name': 'Ocean Blue', 'hex': '#1E88E5', 'color': const Color(0xFF1E88E5)},
    {'name': 'Midnight Indigo', 'hex': '#3949AB', 'color': const Color(0xFF3949AB)},
    {'name': 'Velvet Purple', 'hex': '#8E24AA', 'color': const Color(0xFF8E24AA)},
    {'name': 'Crimson Berry', 'hex': '#C2185B', 'color': const Color(0xFFC2185B)},
    {'name': 'Ruby Red', 'hex': '#D32F2F', 'color': const Color(0xFFD32F2F)},
  ];

  Color _parseColor(String? hexString, {Color fallback = const Color(0xFF2E7D32)}) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _initCategories();
    fetchCategoriesFromApi();
    fetchProductsFromApi();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void _initCategories() {
    categories.clear();
    categories.addAll(defaultCategories);
  }

  Future<void> fetchCategoriesFromApi() async {
    try {
      final api = ApiService.to;
      final res = await api.getCategories();
      if (res.isSuccess && res.data != null) {
        setState(() {
          categories.clear();
          categories.addAll(defaultCategories);

          for (var c in res.data!) {
            final exists = categories.any((item) => item.key.toLowerCase() == c.code.toLowerCase());
            if (!exists) {
              categories.add(CategoryItem(
                id: c.id,
                key: c.code,
                label: c.name,
                icon: c.icon,
                isCustom: true,
              ));
            }
          }
        });
      }
    } catch (_) {}
  }

  Future<void> fetchProductsFromApi() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getProducts(
        category: selectedCategory == 'all' ? null : selectedCategory,
        query: searchQuery.isNotEmpty ? searchQuery : null,
      );

      if (res.isSuccess && res.data != null) {
        setState(() {
          products.clear();
          products.addAll(res.data!);
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  int get activeFiltersCount {
    int count = 0;
    if (selectedCategory != 'all') count++;
    if (stockFilter != 'all') count++;
    if (sortBy != 'default') count++;
    return count;
  }

  List<ProductModel> get filteredProducts {
    var list = products.where((p) {
      final matchesCategory = selectedCategory == 'all' ||
          p.category.toLowerCase() == selectedCategory.toLowerCase();
      final q = searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.barcode.toLowerCase().contains(q) ||
          (p.description != null && p.description!.toLowerCase().contains(q)) ||
          p.category.toLowerCase().contains(q);

      bool matchesStock = true;
      if (stockFilter == 'in_stock') {
        matchesStock = p.stockQty > 0;
      } else if (stockFilter == 'low_stock') {
        matchesStock = p.stockQty > 0 && p.stockQty < 15;
      } else if (stockFilter == 'out_of_stock') {
        matchesStock = p.stockQty <= 0;
      }

      return matchesCategory && matchesSearch && matchesStock;
    }).toList();

    switch (sortBy) {
      case 'name_asc':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_desc':
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'stock_asc':
        list.sort((a, b) => a.stockQty.compareTo(b.stockQty));
        break;
      case 'stock_desc':
        list.sort((a, b) => b.stockQty.compareTo(a.stockQty));
        break;
      case 'default':
      default:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return list;
  }

  String _generateBarcode() {
    final random = Random();
    const prefix = '8845';
    final number = random.nextInt(90000000) + 10000000;
    return '$prefix$number';
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return Icons.local_cafe_rounded;
      case 'tea_milk':
        return Icons.emoji_food_beverage_rounded;
      case 'bakery':
        return Icons.cake_rounded;
      case 'beverages':
        return Icons.wine_bar_rounded;
      case 'smoothies':
      case 'drinks':
        return Icons.local_bar_rounded;
      case 'food':
      case 'meals':
        return Icons.restaurant_rounded;
      case 'snacks':
        return Icons.fastfood_rounded;
      case 'icecream':
      case 'dessert':
        return Icons.icecream_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return const Color(0xFF8D6E63);
      case 'tea_milk':
        return const Color(0xFF26A69A);
      case 'bakery':
        return const Color(0xFFFFA726);
      case 'beverages':
        return const Color(0xFF42A5F5);
      case 'smoothies':
      case 'drinks':
        return const Color(0xFFAB47BC);
      case 'food':
      case 'meals':
        return const Color(0xFFE53935);
      case 'snacks':
        return const Color(0xFFFF7043);
      case 'icecream':
      case 'dessert':
        return const Color(0xFFEC407A);
      default:
        return primaryOrange;
    }
  }

  String _getCategoryDisplayName(CategoryItem cat) {
    if (cat.isCustom) {
      return cat.label;
    }
    return cat.label.tr;
  }

  void _showAddCategoryDialog({Function(String newCategoryCode)? onCategoryCreated}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    String selectedIcon = 'category';

    final presetIcons = [
      {'icon': 'category', 'key': 'product_category', 'iconData': Icons.category_rounded},
      {'icon': 'smoothies', 'key': 'cat_smoothies', 'iconData': Icons.local_bar_rounded},
      {'icon': 'food', 'key': 'cat_food', 'iconData': Icons.restaurant_rounded},
      {'icon': 'snacks', 'key': 'cat_snacks', 'iconData': Icons.fastfood_rounded},
      {'icon': 'icecream', 'key': 'cat_dessert', 'iconData': Icons.icecream_rounded},
      {'icon': 'shopping', 'key': 'cat_retail', 'iconData': Icons.shopping_bag_rounded},
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_circle_outline_rounded, color: primaryOrange, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'add_category'.tr,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
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
                  const SizedBox(height: 16),

                  // Category Name
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    onChanged: (val) {
                      final generated = val.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
                      if (generated.isNotEmpty) {
                        codeCtrl.text = generated;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'category_name'.tr,
                      hintText: 'category_name_hint'.tr,
                      prefixIcon: const Icon(Icons.label_outline_rounded, color: primaryOrange),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Code
                  TextField(
                    controller: codeCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'category_code'.tr,
                      hintText: 'category_code_hint'.tr,
                      prefixIcon: const Icon(Icons.tag_rounded, color: Colors.blueGrey),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Icon Picker
                  Text(
                    'choose_icon'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetIcons.map((item) {
                      final isSelected = selectedIcon == item['icon'];
                      final iconData = item['iconData'] as IconData;
                      return InkWell(
                        onTap: () {
                          setSheetState(() => selectedIcon = item['icon'] as String);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryOrange.withValues(alpha: 0.15)
                                : (isDark ? AppThemes.darkSurface : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? primaryOrange : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                size: 18,
                                color: isSelected ? primaryOrange : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (item['key'] as String).tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? primaryOrange : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // Save Category Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        var code = codeCtrl.text.trim().toLowerCase().replaceAll(' ', '_');

                        if (name.isEmpty) {
                          Get.snackbar(
                            'warning'.tr,
                            'enter_category_name_warn'.tr,
                            backgroundColor: Colors.amber.shade800,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (code.isEmpty) {
                          code = 'cat_${DateTime.now().millisecondsSinceEpoch % 10000}';
                        }

                        Get.back();
                        try {
                          final api = ApiService.to;
                          final res = await api.createCategory({
                            'name': name,
                            'code': code,
                            'icon': selectedIcon,
                          });

                          if (res.isSuccess) {
                            await fetchCategoriesFromApi();

                            setState(() {
                              selectedCategory = code;
                            });

                            if (onCategoryCreated != null) {
                              onCategoryCreated(code);
                            }

                            Get.snackbar(
                              'success'.tr,
                              'category_saved_success'.tr,
                              backgroundColor: const Color(0xFF1B5E20),
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'error'.tr,
                              res.message ?? 'error'.tr,
                              backgroundColor: Colors.red.shade700,
                              colorText: Colors.white,
                            );
                          }
                        } catch (_) {}
                      },
                      child: Text(
                        'save'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDeleteCategory(CategoryItem cat) {
    if (cat.id == null || !cat.isCustom) return;

    Get.defaultDialog(
      title: 'delete'.tr,
      middleText: '${'delete_category_confirm'.tr}\n(${cat.label})',
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        Get.back();
        try {
          final api = ApiService.to;
          final res = await api.deleteCategory(cat.id!);
          if (res.isSuccess) {
            if (selectedCategory == cat.key) {
              selectedCategory = 'all';
            }
            await fetchCategoriesFromApi();
            fetchProductsFromApi();

            Get.snackbar(
              'success'.tr,
              'category_deleted_success'.tr,
              backgroundColor: const Color(0xFF1B5E20),
              colorText: Colors.white,
            );
          }
        } catch (_) {}
      },
    );
  }

  void _showAddProductDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costPriceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '50');
    final barcodeCtrl = TextEditingController(text: _generateBarcode());
    final descCtrl = TextEditingController();
    
    String category = categories.any((c) => c.key == selectedCategory && c.key != 'all')
        ? selectedCategory
        : 'coffee';
    String selectedColor = '#2E7D32';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final selectableCategories = categories.where((c) => c.key != 'all').toList();
          final hasCategory = selectableCategories.any((c) => c.key == category);
          if (!hasCategory && selectableCategories.isNotEmpty) {
            category = selectableCategories.first.key;
          }

          final currentColor = _parseColor(selectedColor);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
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
                        'add_product'.tr,
                        style: TextStyle(
                          fontSize: 17,
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

                  // Live Product Card Preview
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: currentColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: currentColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(_getCategoryIcon(category), color: Colors.white, size: 28),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameCtrl.text.isEmpty ? 'product_name_preview'.tr : nameCtrl.text,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${priceCtrl.text.isEmpty ? '0.00' : priceCtrl.text}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${'stock'.tr}: ${stockCtrl.text.isEmpty ? '0' : stockCtrl.text}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Color Picker Section
                  Text(
                    'product_color_theme'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: productPalette.map((p) {
                        final isSelected = selectedColor == p['hex'];
                        final color = p['color'] as Color;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() => selectedColor = p['hex'] as String);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10, bottom: 4, top: 2),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: isSelected ? 0.6 : 0.25),
                                  blurRadius: isSelected ? 8 : 3,
                                  spreadRadius: isSelected ? 2 : 0,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Product Name
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => setSheetState(() {}),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'product_name'.tr,
                      hintText: 'product_name_hint'.tr,
                      prefixIcon: const Icon(Icons.shopping_bag_outlined, color: primaryOrange),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Dropdown + Quick Add Category Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: category,
                              isExpanded: true,
                              dropdownColor: theme.cardColor,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              items: selectableCategories.map((c) {
                                return DropdownMenuItem(
                                  value: c.key,
                                  child: Row(
                                    children: [
                                      Icon(_getCategoryIcon(c.key), size: 18, color: _getCategoryColor(c.key)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(_getCategoryDisplayName(c))),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setSheetState(() => category = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quick Add Category Button
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: primaryOrange.withValues(alpha: 0.15),
                          foregroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        tooltip: 'add_category'.tr,
                        onPressed: () {
                          _showAddCategoryDialog(
                            onCategoryCreated: (newCode) {
                              setSheetState(() {
                                category = newCode;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Barcode SKU + Auto Generate
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: barcodeCtrl,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'barcode_sku'.tr,
                            prefixIcon: const Icon(Icons.qr_code_rounded, color: primaryOrange),
                            filled: true,
                            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: primaryOrange.withValues(alpha: 0.15),
                          foregroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.autorenew_rounded),
                        tooltip: 'generate_barcode'.tr,
                        onPressed: () {
                          setSheetState(() {
                            barcodeCtrl.text = _generateBarcode();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price & Cost Price
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          onChanged: (_) => setSheetState(() {}),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'product_price'.tr,
                            hintText: 'product_price_hint'.tr,
                            prefixIcon: const Icon(Icons.attach_money_rounded, color: primaryOrange),
                            filled: true,
                            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: costPriceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'cost_price'.tr,
                            hintText: 'cost_price_hint'.tr,
                            prefixIcon: const Icon(Icons.price_change_outlined, color: Colors.blueGrey),
                            filled: true,
                            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock Qty
                  TextField(
                    controller: stockCtrl,
                    onChanged: (_) => setSheetState(() {}),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'stock_quantity'.tr,
                      prefixIcon: const Icon(Icons.inventory_rounded, color: primaryOrange),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'description'.tr,
                      prefixIcon: const Icon(Icons.notes_rounded, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
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
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                        final costPrice = double.tryParse(costPriceCtrl.text.trim()) ?? 0.0;
                        final stockQty = int.tryParse(stockCtrl.text.trim()) ?? 0;
                        final barcode = barcodeCtrl.text.trim();
                        final desc = descCtrl.text.trim();

                        if (name.isEmpty || price <= 0) {
                          Get.snackbar(
                            'warning'.tr,
                            'enter_name_price_warn'.tr,
                            backgroundColor: Colors.amber.shade800,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        Get.back();
                        try {
                          final api = ApiService.to;
                          await api.createProduct({
                            'name': name,
                            'barcode': barcode.isNotEmpty ? barcode : _generateBarcode(),
                            'category': category,
                            'price': price,
                            'cost_price': costPrice,
                            'stock_qty': stockQty,
                            'color': selectedColor,
                            'description': desc,
                          });

                          fetchProductsFromApi();

                          if (Get.isRegistered<SalesController>()) {
                            Get.find<SalesController>().fetchLiveProducts();
                          }

                          Get.snackbar(
                            'success'.tr,
                            'product_saved_success'.tr,
                            backgroundColor: const Color(0xFF1B5E20),
                            colorText: Colors.white,
                          );
                        } catch (_) {}
                      },
                      child: Text(
                        'save_new_product'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showEditProductDialog(ProductModel product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    final costPriceCtrl = TextEditingController(text: product.costPrice.toStringAsFixed(2));
    final stockCtrl = TextEditingController(text: product.stockQty.toString());
    final barcodeCtrl = TextEditingController(text: product.barcode);
    final descCtrl = TextEditingController(text: product.description ?? '');
    String category = product.category;
    String selectedColor = product.color;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final selectableCategories = categories.where((c) => c.key != 'all').toList();
          final hasCategory = selectableCategories.any((c) => c.key == category);
          if (!hasCategory && selectableCategories.isNotEmpty) {
            category = selectableCategories.first.key;
          }

          final currentColor = _parseColor(selectedColor);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
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
                        'edit_product'.tr,
                        style: TextStyle(
                          fontSize: 17,
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

                  // Live Product Card Preview
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: currentColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: currentColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(_getCategoryIcon(category), color: Colors.white, size: 28),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameCtrl.text.isEmpty ? 'product_name_preview'.tr : nameCtrl.text,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${priceCtrl.text.isEmpty ? '0.00' : priceCtrl.text}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${'stock'.tr}: ${stockCtrl.text.isEmpty ? '0' : stockCtrl.text}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Color Picker Section
                  Text(
                    'product_color_theme'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: productPalette.map((p) {
                        final isSelected = selectedColor == p['hex'];
                        final color = p['color'] as Color;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() => selectedColor = p['hex'] as String);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10, bottom: 4, top: 2),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: isSelected ? 0.6 : 0.25),
                                  blurRadius: isSelected ? 8 : 3,
                                  spreadRadius: isSelected ? 2 : 0,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Product Name
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => setSheetState(() {}),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'product_name'.tr,
                      prefixIcon: const Icon(Icons.shopping_bag_outlined, color: primaryOrange),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Dropdown + Quick Add Category
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: category,
                              isExpanded: true,
                              dropdownColor: theme.cardColor,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              items: selectableCategories.map((c) {
                                return DropdownMenuItem(
                                  value: c.key,
                                  child: Row(
                                    children: [
                                      Icon(_getCategoryIcon(c.key), size: 18, color: _getCategoryColor(c.key)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(_getCategoryDisplayName(c))),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setSheetState(() => category = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quick Add Category Button
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: primaryOrange.withValues(alpha: 0.15),
                          foregroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        tooltip: 'add_category'.tr,
                        onPressed: () {
                          _showAddCategoryDialog(
                            onCategoryCreated: (newCode) {
                              setSheetState(() {
                                category = newCode;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Barcode SKU
                  TextField(
                    controller: barcodeCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'barcode_sku'.tr,
                      prefixIcon: const Icon(Icons.qr_code_rounded, color: primaryOrange),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price & Cost Price
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          onChanged: (_) => setSheetState(() {}),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'product_price'.tr,
                            prefixIcon: const Icon(Icons.attach_money_rounded, color: primaryOrange),
                            filled: true,
                            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: costPriceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'cost_price'.tr,
                            hintText: 'cost_price_hint'.tr,
                            prefixIcon: const Icon(Icons.price_change_outlined, color: Colors.blueGrey),
                            filled: true,
                            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock Qty
                  TextField(
                    controller: stockCtrl,
                    onChanged: (_) => setSheetState(() {}),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'stock_quantity'.tr,
                      prefixIcon: const Icon(Icons.inventory_rounded, color: primaryOrange),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'description'.tr,
                      prefixIcon: const Icon(Icons.notes_rounded, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
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
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                        final costPrice = double.tryParse(costPriceCtrl.text.trim()) ?? 0.0;
                        final stockQty = int.tryParse(stockCtrl.text.trim()) ?? 0;
                        final barcode = barcodeCtrl.text.trim();
                        final desc = descCtrl.text.trim();

                        if (name.isEmpty || price <= 0) {
                          Get.snackbar(
                            'warning'.tr,
                            'enter_name_price_warn'.tr,
                            backgroundColor: Colors.amber.shade800,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        Get.back();
                        try {
                          final api = ApiService.to;
                          await api.updateProduct(product.id, {
                            'name': name,
                            'barcode': barcode,
                            'category': category,
                            'price': price,
                            'cost_price': costPrice,
                            'stock_qty': stockQty,
                            'color': selectedColor,
                            'description': desc,
                          });

                          fetchProductsFromApi();

                          if (Get.isRegistered<SalesController>()) {
                            Get.find<SalesController>().fetchLiveProducts();
                          }

                          Get.snackbar(
                            'success'.tr,
                            'product_updated_success'.tr,
                            backgroundColor: const Color(0xFF1B5E20),
                            colorText: Colors.white,
                          );
                        } catch (_) {}
                      },
                      child: Text(
                        'save'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDeleteProduct(ProductModel product) {
    Get.defaultDialog(
      title: 'delete_product'.tr,
      middleText: '${'delete_product_confirm'.tr}\n(${product.name})',
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        Get.back();
        try {
          final api = ApiService.to;
          await api.deleteProduct(product.id);
          fetchProductsFromApi();

          if (Get.isRegistered<SalesController>()) {
            Get.find<SalesController>().fetchLiveProducts();
          }

          Get.snackbar(
            'success'.tr,
            'product_deleted_success'.tr,
            backgroundColor: const Color(0xFF1B5E20),
            colorText: Colors.white,
          );
        } catch (_) {}
      },
    );
  }

  void _showBarcodeScannerSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scannerCtrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    final manualInputCtrl = TextEditingController();
    bool isTorchOn = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: primaryOrange,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'scan_barcode_search'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'scan_barcode_hint'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
                        ),
                        onPressed: () {
                          scannerCtrl.dispose();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Camera Scanner Viewfinder
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryOrange.withValues(alpha: 0.4), width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: scannerCtrl,
                          onDetect: (capture) {
                            final barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty) {
                              final code = barcodes.first.rawValue ?? '';
                              if (code.isNotEmpty) {
                                scannerCtrl.dispose();
                                Get.back();
                                searchCtrl.text = code;
                                setState(() {
                                  searchQuery = code;
                                });
                                Get.snackbar(
                                  'scan_barcode_search'.tr,
                                  '${'barcode_sku'.tr}: $code',
                                  backgroundColor: primaryOrange,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                );
                              }
                            }
                          },
                        ),
                        // Scanner Target Box
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryOrange, width: 2.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        // Overlay controls (torch, switch camera)
                        Positioned(
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                    color: isTorchOn ? Colors.amber : Colors.white70,
                                    size: 22,
                                  ),
                                  tooltip: 'flash'.tr,
                                  onPressed: () {
                                    scannerCtrl.toggleTorch();
                                    setSheetState(() => isTorchOn = !isTorchOn);
                                  },
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70, size: 22),
                                  tooltip: 'switch_camera'.tr,
                                  onPressed: () => scannerCtrl.switchCamera(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Manual Barcode Input Fallback
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: manualInputCtrl,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'manual_input_barcode_hint'.tr,
                            hintStyle: TextStyle(fontSize: 12, color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.keyboard_alt_outlined, size: 20, color: primaryOrange),
                            filled: true,
                            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF3F4F6),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (code) {
                            if (code.trim().isNotEmpty) {
                              scannerCtrl.dispose();
                              Get.back();
                              searchCtrl.text = code.trim();
                              setState(() {
                                searchQuery = code.trim();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          final code = manualInputCtrl.text.trim();
                          if (code.isNotEmpty) {
                            scannerCtrl.dispose();
                            Get.back();
                            searchCtrl.text = code;
                            setState(() {
                              searchQuery = code;
                            });
                          }
                        },
                        child: Text('search'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    ).then((_) {
      try {
        scannerCtrl.dispose();
      } catch (_) {}
    });
  }

  void _showFilterSortBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String tempCategory = selectedCategory;
    String tempStockFilter = stockFilter;
    String tempSortBy = sortBy;

    final sortOptions = [
      {'key': 'default', 'label': 'sort_default'.tr, 'icon': Icons.access_time_rounded},
      {'key': 'name_asc', 'label': 'sort_name_asc'.tr, 'icon': Icons.sort_by_alpha_rounded},
      {'key': 'name_desc', 'label': 'sort_name_desc'.tr, 'icon': Icons.sort_by_alpha_rounded},
      {'key': 'price_asc', 'label': 'sort_price_asc'.tr, 'icon': Icons.arrow_upward_rounded},
      {'key': 'price_desc', 'label': 'sort_price_desc'.tr, 'icon': Icons.arrow_downward_rounded},
      {'key': 'stock_asc', 'label': 'sort_stock_asc'.tr, 'icon': Icons.trending_down_rounded},
      {'key': 'stock_desc', 'label': 'sort_stock_desc'.tr, 'icon': Icons.trending_up_rounded},
    ];

    final stockStatusOptions = [
      {'key': 'all', 'label': 'filter_all_status'.tr, 'icon': Icons.all_inclusive_rounded, 'color': Colors.blueGrey},
      {'key': 'in_stock', 'label': 'in_stock'.tr, 'icon': Icons.check_circle_outline_rounded, 'color': const Color(0xFF2E7D32)},
      {'key': 'low_stock', 'label': 'low_stock'.tr, 'icon': Icons.warning_amber_rounded, 'color': const Color(0xFFE65100)},
      {'key': 'out_of_stock', 'label': 'out_of_stock'.tr, 'icon': Icons.remove_circle_outline_rounded, 'color': Colors.red},
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune_rounded, color: primaryOrange, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'sort_and_filter'.tr,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            tempCategory = 'all';
                            tempStockFilter = 'all';
                            tempSortBy = 'default';
                          });
                        },
                        icon: const Icon(Icons.restart_alt_rounded, size: 16, color: primaryOrange),
                        label: Text(
                          'reset_filters'.tr,
                          style: const TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 1. Stock Status Filter Section
                  Text(
                    'stock_status'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: stockStatusOptions.map((st) {
                      final isSelected = tempStockFilter == st['key'];
                      final color = st['color'] as Color;
                      return ChoiceChip(
                        avatar: Icon(
                          st['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        label: Text(
                          st['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: color,
                        backgroundColor: isDark ? AppThemes.darkSurface : Colors.grey.shade100,
                        side: BorderSide(
                          color: isSelected ? color : (isDark ? AppThemes.darkBorder : Colors.grey.shade300),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() => tempStockFilter = st['key'] as String);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 2. Category Filter Section
                  Text(
                    'select_category'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = tempCategory == cat.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(
                              _getCategoryIcon(cat.key),
                              size: 15,
                              color: isSelected ? Colors.white : (isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700),
                            ),
                            label: Text(
                              _getCategoryDisplayName(cat),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: primaryOrange,
                            backgroundColor: isDark ? AppThemes.darkSurface : Colors.grey.shade100,
                            side: BorderSide(
                              color: isSelected ? primaryOrange : (isDark ? AppThemes.darkBorder : Colors.grey.shade300),
                            ),
                            onSelected: (val) {
                              if (val) {
                                setSheetState(() => tempCategory = cat.key);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Sort By Section
                  Text(
                    'sort_by'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sortOptions.map((so) {
                      final isSelected = tempSortBy == so['key'];
                      return ChoiceChip(
                        avatar: Icon(
                          so['icon'] as IconData,
                          size: 15,
                          color: isSelected ? Colors.white : primaryOrange,
                        ),
                        label: Text(
                          so['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: primaryOrange,
                        backgroundColor: isDark ? AppThemes.darkSurface : Colors.grey.shade100,
                        side: BorderSide(
                          color: isSelected ? primaryOrange : (isDark ? AppThemes.darkBorder : Colors.grey.shade300),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() => tempSortBy = so['key'] as String);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCategory = tempCategory;
                          stockFilter = tempStockFilter;
                          sortBy = tempSortBy;
                        });
                        Get.back();
                      },
                      child: Text(
                        'apply_filters'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
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
    final displayItems = filteredProducts;
    final totalStockCount = products.fold<int>(0, (sum, p) => sum + p.stockQty);
    final lowStockCount = products.where((p) => p.stockQty < 15).length;
    final hasActiveFilter = searchQuery.isNotEmpty || stockFilter != 'all' || sortBy != 'default' || selectedCategory != 'all';
    final activeCount = activeFiltersCount;

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
          'products_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            tooltip: 'add_category'.tr,
            onPressed: () => _showAddCategoryDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'refresh'.tr,
            onPressed: () {
              fetchCategoriesFromApi();
              fetchProductsFromApi();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomSearchDock(
        controller: searchCtrl,
        hintText: 'search_product_barcode_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        inlineActions: [
          // Barcode scanner inside search bar
          GestureDetector(
            onTap: _showBarcodeScannerSheet,
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: primaryOrange,
                size: 18,
              ),
            ),
          ),
          // Filter & Sort inside search bar
          GestureDetector(
            onTap: _showFilterSortBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: activeCount > 0
                    ? primaryOrange
                    : (isDark ? Colors.white12 : Colors.grey.shade200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.tune_rounded,
                color: activeCount > 0
                    ? Colors.white
                    : (isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700),
                size: 18,
              ),
            ),
          ),
        ],
        actionIcon: Icons.add_rounded,
        actionTooltip: 'add_product'.tr,
        onActionTap: _showAddProductDialog,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchCategoriesFromApi();
                await fetchProductsFromApi();
              },
              color: primaryOrange,
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Stats Card
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
                      'total_products'.tr,
                      '${products.length}',
                      Icons.inventory_2_rounded,
                      primaryOrange,
                    ),
                    Container(
                      height: 36,
                      width: 1,
                      color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                    ),
                    _buildStat(
                      context,
                      'stock_quantity'.tr,
                      '$totalStockCount',
                      Icons.layers_rounded,
                      const Color(0xFF2E7D32),
                    ),
                    Container(
                      height: 36,
                      width: 1,
                      color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                    ),
                    _buildStat(
                      context,
                      'low_stock'.tr,
                      '$lowStockCount',
                      Icons.warning_amber_rounded,
                      const Color(0xFFE65100),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Category Filter Pills with "+ Add Category" button
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    ...categories.map((cat) {
                      final isSelected = selectedCategory == cat.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onLongPress: cat.isCustom ? () => _confirmDeleteCategory(cat) : null,
                          child: ChoiceChip(
                            avatar: isSelected
                                ? null
                                : Icon(
                                    _getCategoryIcon(cat.key),
                                    size: 15,
                                    color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                                  ),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getCategoryDisplayName(cat),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700),
                                  ),
                                ),
                                if (cat.isCustom) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _confirmDeleteCategory(cat),
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      size: 14,
                                      color: isSelected ? Colors.white70 : Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: primaryOrange,
                            backgroundColor: theme.cardColor,
                            side: BorderSide(
                              color: isSelected
                                  ? primaryOrange
                                  : (isDark ? AppThemes.darkBorder : Colors.grey.shade300),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => selectedCategory = cat.key);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                    // "+ Add Category" Action Chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 16, color: primaryOrange),
                        label: Text(
                          'add_category'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                        backgroundColor: primaryOrange.withValues(alpha: 0.1),
                        side: const BorderSide(color: primaryOrange, width: 1),
                        onPressed: () => _showAddCategoryDialog(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Active Filters & Results Summary Banner (if active filter or search)
              if (hasActiveFilter) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryOrange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 16, color: primaryOrange),
                      const SizedBox(width: 6),
                      Text(
                        '${'search_results_count'.tr}: ${displayItems.length}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          searchCtrl.clear();
                          setState(() {
                            searchQuery = '';
                            selectedCategory = 'all';
                            stockFilter = 'all';
                            sortBy = 'default';
                          });
                        },
                        child: Text(
                          'clear_all_filters'.tr,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Products Count Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'products'.tr} (${displayItems.length})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Loading / Empty / List State
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: CircularProgressIndicator(color: primaryOrange),
                  ),
                )
              else if (displayItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark
                        ? Border.all(color: AppThemes.darkBorder)
                        : Border.all(color: AppThemes.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        hasActiveFilter ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                        size: 48,
                        color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hasActiveFilter ? 'no_products_found_search'.tr : 'no_data'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasActiveFilter ? 'search_no_results_subhint'.tr : 'add_product_to_store'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      if (hasActiveFilter)
                        ElevatedButton.icon(
                          onPressed: () {
                            searchCtrl.clear();
                            setState(() {
                              searchQuery = '';
                              selectedCategory = 'all';
                              stockFilter = 'all';
                              sortBy = 'default';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text('reset_filters'.tr),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showAddProductDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: Text('add_product'.tr),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () => _showAddCategoryDialog(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryOrange,
                                side: const BorderSide(color: primaryOrange),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.category_rounded, size: 18),
                              label: Text('add_category'.tr),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = displayItems[index];
                    return _buildProductCard(context, item);
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  ],
),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemColor = _parseColor(item.color, fallback: _getCategoryColor(item.category));
    final catIcon = _getCategoryIcon(item.category);

    final isLowStock = item.stockQty > 0 && item.stockQty < 15;
    final isOutOfStock = item.stockQty <= 0;

    return Container(
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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category Icon Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: itemColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(catIcon, color: itemColor, size: 24),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // SKU Barcode
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemes.darkSurface : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code, size: 11, color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            item.barcode,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Stock badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? Colors.red.withValues(alpha: 0.12)
                            : isLowStock
                                ? Colors.orange.withValues(alpha: 0.12)
                                : Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOutOfStock
                            ? 'out_of_stock'.tr
                            : isLowStock
                                ? '${'low_stock'.tr} (${item.stockQty})'
                                : '${item.stockQty} ${'item_unit'.tr}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? Colors.red.shade700
                              : isLowStock
                                  ? Colors.orange.shade800
                                  : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primaryOrange,
                      ),
                    ),
                    if (item.costPrice > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${'cost_price'.tr}: \$${item.costPrice.toStringAsFixed(2)})',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions (Edit, Delete)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                tooltip: 'edit'.tr,
                onPressed: () => _showEditProductDialog(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red.shade400,
                tooltip: 'delete'.tr,
                onPressed: () => _confirmDeleteProduct(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
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
