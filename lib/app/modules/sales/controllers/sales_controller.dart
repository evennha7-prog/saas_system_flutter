import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/services/api_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../list_sales/controllers/list_sales_controller.dart';

class ProductItem {
  final String id;
  final String name;
  final double price;
  final double costPrice;
  final String category;
  final String barcode;
  final int stock;
  final String colorHex;
  final String? description;

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.costPrice = 0.0,
    required this.category,
    this.barcode = '',
    this.stock = 50,
    this.colorHex = '#2E7D32',
    this.description,
  });

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF2E7D32);
  }
}

class PosCategoryItem {
  final String key;
  final String label;
  final String icon;

  PosCategoryItem({
    required this.key,
    required this.label,
    this.icon = 'category',
  });
}

class CartItem {
  final ProductItem product;
  var quantity = 1.obs;

  CartItem({required this.product, int qty = 1}) {
    quantity.value = qty;
  }
}

class SalesController extends GetxController {
  final selectedCategoryKey = 'cat_all'.obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();

  final categories = <PosCategoryItem>[
    PosCategoryItem(key: 'cat_all', label: 'cat_all', icon: 'all'),
  ].obs;

  final RxList<ProductItem> products = <ProductItem>[].obs;
  final cart = <CartItem>[].obs;
  final isCartExpanded = true.obs;

  void toggleCartExpanded() {
    isCartExpanded.value = !isCartExpanded.value;
  }

  @override
  void onInit() {
    super.onInit();
    fetchLiveCategories();
    fetchLiveProducts();
    try {
      ever(ApiService.to.currentStoreId, (_) {
        cart.clear();
        fetchLiveCategories();
        fetchLiveProducts();
      });
      ever(ApiService.to.currentUser, (_) {
        cart.clear();
        fetchLiveCategories();
        fetchLiveProducts();
      });
    } catch (_) {}
  }

  Future<void> fetchLiveCategories() async {
    try {
      final api = ApiService.to;
      final res = await api.getCategories();
      if (res.isSuccess && res.data != null) {
        categories.clear();
        categories.add(PosCategoryItem(key: 'cat_all', label: 'cat_all', icon: 'all'));

        for (var c in res.data!) {
          final code = c.code.toLowerCase();
          final key = code.startsWith('cat_') ? code : 'cat_$code';
          categories.add(PosCategoryItem(
            key: key,
            label: c.name,
            icon: c.icon,
          ));
        }
      }
    } catch (_) {}
  }

  Future<void> fetchLiveProducts() async {
    try {
      isLoading.value = true;
      final api = ApiService.to;
      final res = await api.getProducts();
      isLoading.value = false;

      if (res.isSuccess && res.data != null) {
        products.clear();
        for (var p in res.data!) {
          final c = p.category.toLowerCase();
          final catKey = c.startsWith('cat_') ? c : 'cat_$c';

          products.add(ProductItem(
            id: p.id.toString(),
            name: p.name,
            price: p.price,
            costPrice: p.costPrice,
            category: catKey,
            barcode: p.barcode,
            stock: p.stockQty,
            colorHex: p.color,
            description: p.description,
          ));
        }
      }
    } catch (_) {
      isLoading.value = false;
    }
  }

  void addNewProduct(ProductItem product) {
    products.insert(0, product);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  List<ProductItem> get filteredProducts {
    var list = products.toList();

    // Filter by Category
    if (selectedCategoryKey.value != 'cat_all' && selectedCategoryKey.value != 'all') {
      final target = selectedCategoryKey.value.toLowerCase().replaceAll('cat_', '');
      list = list.where((p) {
        final prodCat = p.category.toLowerCase().replaceAll('cat_', '');
        return prodCat == target;
      }).toList();
    }

    // Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value;
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.barcode.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  double get totalPrice {
    double total = 0;
    for (var item in cart) {
      total += item.product.price * item.quantity.value;
    }
    return total;
  }

  int get totalItemCount {
    int count = 0;
    for (var item in cart) {
      count += item.quantity.value;
    }
    return count;
  }

  int getProductCartCount(String productId) {
    final index = cart.indexWhere((c) => c.product.id == productId);
    if (index >= 0) {
      return cart[index].quantity.value;
    }
    return 0;
  }

  void addToCart(ProductItem product) {
    final index = cart.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      cart[index].quantity.value++;
    } else {
      cart.add(CartItem(product: product, qty: 1));
    }
  }

  void removeFromCart(ProductItem product) {
    final index = cart.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      if (cart[index].quantity.value > 1) {
        cart[index].quantity.value--;
      } else {
        cart.removeAt(index);
      }
    }
  }

  void deleteFromCart(ProductItem product) {
    cart.removeWhere((c) => c.product.id == product.id);
  }

  void clearCart() {
    cart.clear();
  }

  Future<SaleModel?> processCheckout({String paymentMethod = 'CASH'}) async {
    if (cart.isEmpty) return null;

    try {
      final items = cart.map((c) {
        return {
          'product_id': int.tryParse(c.product.id),
          'product_name': c.product.name,
          'quantity': c.quantity.value,
          'unit_price': c.product.price,
          'subtotal': c.product.price * c.quantity.value,
          if (c.product.barcode.isNotEmpty) 'barcode': c.product.barcode,
        };
      }).toList();

      final total = totalPrice;
      final api = ApiService.to;
      final res = await api.checkout(
        items: items,
        totalAmount: total,
        finalAmount: total,
        paymentMethod: paymentMethod,
      );

      if (res.isSuccess) {
        clearCart();
        fetchLiveProducts();

        // Refresh Dashboard and Sales List
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboardData();
        }
        if (Get.isRegistered<ListSalesController>()) {
          Get.find<ListSalesController>().fetchSales();
        }

        Get.snackbar(
          'success'.tr,
          'order_completed'.tr,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
        return res.data;
      } else {
        Get.snackbar(
          'error'.tr,
          res.message ?? 'checkout_failed'.tr,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return null;
    }
  }
}
