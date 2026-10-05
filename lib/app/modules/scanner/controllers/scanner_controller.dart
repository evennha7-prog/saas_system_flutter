import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../navbar/controllers/navbar_controller.dart';
import '../../sales/controllers/sales_controller.dart';
import '../../../data/services/api_service.dart';

class ScannedHistoryItem {
  final String barcode;
  final String productName;
  final double price;
  final DateTime scannedAt;
  final bool isMatched;

  ScannedHistoryItem({
    required this.barcode,
    required this.productName,
    required this.price,
    required this.scannedAt,
    required this.isMatched,
  });
}

class ScannerController extends GetxController {
  // Input Source Option: 'camera' (Live Camera Lens) vs 'hardware_scanner' (Barcode Gun / Manual Keypad)
  final scanInputSource = 'camera'.obs;

  // Barcode format: '1d_barcode' (1D EAN/Code128) vs 'qr_code' (2D QR)
  final barcodeFormat = '1d_barcode'.obs;

  // Operation Mode: 'sell' (Scan to POS Cart) or 'add' (Scan to Register New Product)
  final scanMode = 'sell'.obs;

  // Camera Controls
  final isFlashOn = false.obs;
  final isFrontCamera = false.obs;
  final isContinuousScan = true.obs;
  final autoAddToCart = false.obs;

  // Barcode & Scanned state
  final currentBarcode = '884500129001'.obs;
  final manualInputCtrl = TextEditingController();
  final isScanSuccess = false.obs;
  final isSearching = false.obs;

  // Scanned item for POS sell
  final scannedProduct = Rxn<ProductItem>();
  final sellQuantity = 1.obs;

  // Scanned History Archive
  final scannedHistory = <ScannedHistoryItem>[].obs;

  // Add Product Form Controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final costController = TextEditingController();
  final stockController = TextEditingController(text: '50');
  final selectedCategoryKey = ''.obs;
  final selectedColorHex = '#2E7D32'.obs;

  // Dynamic Categories from Backend
  final availableCategories = <Map<String, String>>[].obs;

  // Live quick test barcodes fetched from real store products
  final liveBarcodes = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initScanner();
  }

  Future<void> _initScanner() async {
    await fetchLiveCategories();
    await fetchLiveStoreBarcodes();
    await lookupBarcode(currentBarcode.value);
  }

  Future<void> fetchLiveCategories() async {
    try {
      final api = ApiService.to;
      final res = await api.getCategories();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        final list = <Map<String, String>>[];
        for (var c in res.data!) {
          list.add({'code': c.code, 'name': c.name});
        }
        availableCategories.assignAll(list);
        if (selectedCategoryKey.value.isEmpty ||
            !list.any((item) => item['code'] == selectedCategoryKey.value)) {
          selectedCategoryKey.value = list.first['code'] ?? 'coffee';
        }
      }
    } catch (_) {}
  }

  Future<void> fetchLiveStoreBarcodes() async {
    try {
      final api = ApiService.to;
      final res = await api.getProducts(limit: 20);
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        final list = <Map<String, String>>[];
        for (var p in res.data!) {
          list.add({
            'name': p.name,
            'barcode': p.barcode,
            'price': p.price.toStringAsFixed(2),
            'category': p.category,
          });
        }
        liveBarcodes.assignAll(list);
        if (list.isNotEmpty && scannedProduct.value == null) {
          currentBarcode.value = list.first['barcode']!;
          manualInputCtrl.text = list.first['barcode']!;
        }
      }
    } catch (_) {}
  }

  void setInputSource(String source) {
    scanInputSource.value = source;
  }

  void setBarcodeFormat(String format) {
    barcodeFormat.value = format;
  }

  void setScanMode(String mode) {
    scanMode.value = mode;
    if (mode == 'sell') {
      if (scannedProduct.value == null) {
        lookupBarcode(currentBarcode.value);
      }
    } else {
      if (nameController.text.isEmpty && scannedProduct.value != null) {
        nameController.text = scannedProduct.value!.name;
        priceController.text = scannedProduct.value!.price.toStringAsFixed(2);
      }
    }
  }

  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    HapticFeedback.lightImpact();
    Get.snackbar(
      'torch_flash'.tr,
      isFlashOn.value ? 'flash_on'.tr : 'flash_off'.tr,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black87,
      colorText: const Color(0xFFFFB300),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  void toggleCamera() {
    isFrontCamera.value = !isFrontCamera.value;
    HapticFeedback.lightImpact();
  }

  void generateRandomBarcode() {
    final random = Random();
    final code = '884500${100000 + random.nextInt(900000)}';
    currentBarcode.value = code;
    manualInputCtrl.text = code;
    lookupBarcode(code);
  }

  void onBarcodeTriggered(String barcode) {
    if (barcode.trim().isEmpty) return;
    final cleanCode = barcode.trim();
    currentBarcode.value = cleanCode;
    manualInputCtrl.text = cleanCode;
    lookupBarcode(cleanCode);
  }

  // Real-time lookup barcode from live API and SalesController catalog
  Future<void> lookupBarcode(String barcode) async {
    final cleanCode = barcode.trim();
    if (cleanCode.isEmpty) return;

    isSearching.value = true;
    currentBarcode.value = cleanCode;
    manualInputCtrl.text = cleanCode;

    ProductItem? foundProduct;

    // 1. Check in SalesController local catalog first for instant response
    if (Get.isRegistered<SalesController>()) {
      final sales = Get.find<SalesController>();
      foundProduct = sales.products.firstWhereOrNull(
        (p) => p.barcode == cleanCode || p.id == cleanCode || p.name.toLowerCase() == cleanCode.toLowerCase(),
      );
    }

    // 2. If not found in memory, query the real Backend API via getProductByBarcode
    if (foundProduct == null) {
      try {
        final api = ApiService.to;
        final res = await api.getProductByBarcode(cleanCode);
        if (res.isSuccess && res.data != null) {
          final p = res.data!;
          foundProduct = ProductItem(
            id: p.id.toString(),
            name: p.name,
            price: p.price,
            costPrice: p.costPrice,
            category: p.category.startsWith('cat_') ? p.category : 'cat_${p.category}',
            barcode: p.barcode,
            stock: p.stockQty,
            colorHex: p.color,
            description: p.description,
          );

          // Add to SalesController so POS is always synchronized
          if (Get.isRegistered<SalesController>()) {
            final sales = Get.find<SalesController>();
            final exists = sales.products.any((x) => x.id == foundProduct!.id || x.barcode == foundProduct.barcode);
            if (!exists) {
              sales.products.add(foundProduct);
            }
          }
        }
      } catch (_) {}
    }

    if (foundProduct != null) {
      scannedProduct.value = foundProduct;
      isScanSuccess.value = true;

      // Add to scan history
      scannedHistory.removeWhere((item) => item.barcode == cleanCode);
      scannedHistory.insert(
        0,
        ScannedHistoryItem(
          barcode: cleanCode,
          productName: foundProduct.name,
          price: foundProduct.price,
          scannedAt: DateTime.now(),
          isMatched: true,
        ),
      );

      // Auto Add To Cart if enabled
      if (autoAddToCart.value && scanMode.value == 'sell') {
        addScannedToCart();
      } else {
        HapticFeedback.mediumImpact();
      }
    } else {
      scannedProduct.value = null;
      isScanSuccess.value = false;

      scannedHistory.removeWhere((item) => item.barcode == cleanCode);
      scannedHistory.insert(
        0,
        ScannedHistoryItem(
          barcode: cleanCode,
          productName: 'Unregistered SKU ($cleanCode)',
          price: 0.0,
          scannedAt: DateTime.now(),
          isMatched: false,
        ),
      );
    }

    isSearching.value = false;
  }

  void prepareAddNewWithBarcode(String barcode) {
    currentBarcode.value = barcode;
    manualInputCtrl.text = barcode;
    nameController.clear();
    priceController.clear();
    costController.clear();
    stockController.text = '50';
    selectedColorHex.value = '#2E7D32';
    scanMode.value = 'add';
  }

  void increaseQty() => sellQuantity.value++;
  void decreaseQty() {
    if (sellQuantity.value > 1) sellQuantity.value--;
  }

  void addScannedToCart() {
    if (scannedProduct.value != null && Get.isRegistered<SalesController>()) {
      final salesCtrl = Get.find<SalesController>();
      for (int i = 0; i < sellQuantity.value; i++) {
        salesCtrl.addToCart(scannedProduct.value!);
      }

      HapticFeedback.heavyImpact();

      Get.snackbar(
        'item_added_to_cart'.tr,
        '${scannedProduct.value!.name} (x${sellQuantity.value}) • \$${(scannedProduct.value!.price * sellQuantity.value).toStringAsFixed(2)}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white),
      );

      sellQuantity.value = 1;
    }
  }

  void goToSalesCart() {
    if (Get.isRegistered<NavbarController>()) {
      Get.find<NavbarController>().changePage(1); // Switch to POS Sales Tab
    }
  }

  Future<void> saveProductToCatalog() async {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final costText = costController.text.trim();
    final stockText = stockController.text.trim();
    final barcode = currentBarcode.value.trim();

    if (name.isEmpty || priceText.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'enter_name_price_warn'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    final price = double.tryParse(priceText) ?? 2.0;
    final cost = double.tryParse(costText) ?? 0.0;
    final stock = int.tryParse(stockText) ?? 50;
    final categoryCode = selectedCategoryKey.value.replaceAll('cat_', '');

    try {
      final api = ApiService.to;
      final res = await api.createProduct({
        'name': name,
        'price': price,
        'cost_price': cost,
        'barcode': barcode,
        'category': categoryCode,
        'stock_qty': stock,
        'color': selectedColorHex.value,
      });

      if (res.isSuccess && res.data != null) {
        final p = res.data!;
        final newProduct = ProductItem(
          id: p.id.toString(),
          name: p.name,
          price: p.price,
          costPrice: p.costPrice,
          category: p.category.startsWith('cat_') ? p.category : 'cat_${p.category}',
          barcode: p.barcode,
          stock: p.stockQty,
          colorHex: p.color,
        );

        if (Get.isRegistered<SalesController>()) {
          Get.find<SalesController>().addNewProduct(newProduct);
          Get.find<SalesController>().fetchLiveProducts();
        }

        await fetchLiveStoreBarcodes();

        HapticFeedback.mediumImpact();

        Get.snackbar(
          'success'.tr,
          'product_saved_success'.tr,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );

        // Switch to sell mode with newly created product
        scannedProduct.value = newProduct;
        isScanSuccess.value = true;
        scanMode.value = 'sell';
        nameController.clear();
        priceController.clear();
        costController.clear();
      } else {
        Get.snackbar(
          'error'.tr,
          res.message ?? 'error'.tr,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (_) {}
  }
}
