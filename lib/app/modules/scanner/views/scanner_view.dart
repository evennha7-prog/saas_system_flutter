import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../themes/themes.dart';
import '../../sales/controllers/sales_controller.dart';
import '../controllers/scanner_controller.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with SingleTickerProviderStateMixin {
  late final ScannerController controller;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;
  MobileScannerController? _cameraController;

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color primaryGold = Color(0xFFFFB300);

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

  DateTime? _lastScannedTime;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ScannerController>()
        ? Get.find<ScannerController>()
        : Get.put(ScannerController());

    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _handleBarcodeDetected(BarcodeCapture capture) {
    final now = DateTime.now();
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        // Prevent duplicate trigger within 1.5s for same code
        if (_lastScannedCode == code &&
            _lastScannedTime != null &&
            now.difference(_lastScannedTime!).inMilliseconds < 1500) {
          continue;
        }

        _lastScannedCode = code;
        _lastScannedTime = now;
        controller.onBarcodeTriggered(code);
        break;
      }
    }
  }

  IconData _getCategoryIcon(String categoryKey) {
    switch (categoryKey) {
      case 'cat_coffee':
        return Icons.local_cafe_rounded;
      case 'cat_tea_milk':
        return Icons.emoji_food_beverage_rounded;
      case 'cat_bakery':
        return Icons.bakery_dining_rounded;
      case 'cat_beverages':
        return Icons.local_bar_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkBg : const Color(0xFF0F172A),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Control Header: Source (Camera vs Barcode Gun) & Mode Switcher
            _buildTopControlHeader(context),

            // 2. Dynamic Scanner Area (Live Camera Viewfinder OR Hardware Barcode Gun Panel)
            Obx(() {
              if (controller.scanInputSource.value == 'camera') {
                return _buildLiveCameraViewfinder(context);
              } else {
                return _buildHardwareScannerPanel(context);
              }
            }),

            // 3. Bottom Interactive Panel (Scan to Sell / Add Product)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Sheet Handle & Cart Quick Summary
                    _buildSheetHandleAndCartBar(context),

                    // Panel Content (Sell vs Add)
                    Expanded(
                      child: Obx(() {
                        if (controller.scanMode.value == 'sell') {
                          return _buildScanToSellContent(context);
                        } else {
                          return _buildAddProductContent(context);
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. TOP CONTROL HEADER
  // ==========================================
  Widget _buildTopControlHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          // Header Row: Title & Action Controls
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pos_scanner_title'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Camera & Barcode Gun',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Live Flash & Camera Flip
              Obx(
                () => Row(
                  children: [
                    if (controller.scanInputSource.value == 'camera') ...[
                      IconButton(
                        icon: Icon(
                          controller.isFlashOn.value
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: controller.isFlashOn.value
                              ? primaryGold
                              : Colors.white70,
                          size: 22,
                        ),
                        tooltip: 'flash'.tr,
                        onPressed: () {
                          controller.toggleFlash();
                          _cameraController?.toggleTorch();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.flip_camera_ios_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                        tooltip: 'camera_switch'.tr,
                        onPressed: () {
                          controller.toggleCamera();
                          _cameraController?.switchCamera();
                        },
                      ),
                    ],
                    IconButton(
                      icon: const Icon(
                        Icons.cached_rounded,
                        color: primaryOrange,
                        size: 22,
                      ),
                      tooltip: 'generate_barcode_test'.tr,
                      onPressed: controller.generateRandomBarcode,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Segment 1: Input Source Selector (Camera vs Hardware Barcode Gun)
          Obx(
            () => Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSourceTabButton(
                      sourceKey: 'camera',
                      icon: Icons.camera_alt_rounded,
                      title: 'camera_mode'.tr,
                      isSelected: controller.scanInputSource.value == 'camera',
                    ),
                  ),
                  Expanded(
                    child: _buildSourceTabButton(
                      sourceKey: 'hardware_scanner',
                      icon: Icons.barcode_reader,
                      title: 'scanner_gun_mode'.tr,
                      isSelected: controller.scanInputSource.value == 'hardware_scanner',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Segment 2: Operation Mode Selector (Scan to Sell vs Add Product)
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildModePillButton(
                    modeKey: 'sell',
                    icon: Icons.point_of_sale_rounded,
                    title: 'scan_to_sell_mode'.tr,
                    isSelected: controller.scanMode.value == 'sell',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildModePillButton(
                    modeKey: 'add',
                    icon: Icons.add_box_rounded,
                    title: 'add_new_mode'.tr,
                    isSelected: controller.scanMode.value == 'add',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTabButton({
    required String sourceKey,
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.setInputSource(sourceKey),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModePillButton({
    required String modeKey,
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.setScanMode(modeKey),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryGold.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primaryGold : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? primaryGold : Colors.white60,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? primaryGold : Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2A. LIVE CAMERA OPTICAL VIEWFINDER
  // ==========================================
  Widget _buildLiveCameraViewfinder(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Real Hardware Camera Video Stream
            if (_cameraController != null)
              MobileScanner(
                controller: _cameraController!,
                onDetect: _handleBarcodeDetected,
                errorBuilder: (context, error) {
                  return Container(
                    color: const Color(0xFF0F172A),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.videocam_off_rounded, color: primaryGold, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          '${'server_connection_failed'.tr.isNotEmpty ? 'error'.tr : 'error'.tr}: ${error.errorCode.name}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => controller.setInputSource('hardware_scanner'),
                          child: Text('switch_to_manual_scanner'.tr),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Targeting Reticle Overlay
            Obx(() {
              final is1D = controller.barcodeFormat.value == '1d_barcode';
              return Center(
                child: Container(
                  width: is1D ? 260 : 160,
                  height: is1D ? 120 : 160,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryOrange.withValues(alpha: 0.85),
                      width: 2.2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Animated Laser Scan Sweep Line
                      AnimatedBuilder(
                        animation: _laserAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: (is1D ? 120 : 160) * _laserAnimation.value,
                            left: 8,
                            right: 8,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryOrange.withValues(alpha: 0.9),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Format Toggle Pill (1D Barcode vs QR Code)
            Positioned(
              top: 8,
              left: 12,
              child: Obx(
                () => Row(
                  children: [
                    _buildFormatChip('1d_barcode', '1D Barcode'),
                    const SizedBox(width: 6),
                    _buildFormatChip('qr_code', '2D QR'),
                  ],
                ),
              ),
            ),

            // Current Barcode Number Display Badge
            Positioned(
              bottom: 8,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryGold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 14, color: primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        controller.currentBarcode.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
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
  }

  Widget _buildFormatChip(String formatKey, String label) {
    final isSelected = controller.barcodeFormat.value == formatKey;
    return InkWell(
      onTap: () => controller.setBarcodeFormat(formatKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryOrange
              : Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2B. HARDWARE BARCODE SCANNER / MANUAL INPUT
  // ==========================================
  Widget _buildHardwareScannerPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.barcode_reader, color: primaryGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'scanner_gun'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'READY',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barcode Input Field (Keyboard listener for Barcode Guns)
          TextField(
            controller: controller.manualInputCtrl,
            onSubmitted: controller.onBarcodeTriggered,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'scan_or_type_barcode_hint'.tr,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              prefixIcon: const Icon(Icons.qr_code_rounded, color: primaryGold, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_rounded, color: primaryOrange),
                onPressed: () => controller.onBarcodeTriggered(controller.manualInputCtrl.text),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Demo Barcode Trigger Chips
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: controller.liveBarcodes.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      backgroundColor: const Color(0xFF0F172A),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      avatar: const Icon(Icons.qr_code, size: 12, color: primaryOrange),
                      label: Text(
                        '${item['name']} (\$${item['price']})',
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => controller.onBarcodeTriggered(item['barcode']!),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3A. SHEET HANDLE & CART QUICK SUMMARY
  // ==========================================
  Widget _buildSheetHandleAndCartBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        if (Get.isRegistered<SalesController>())
          GetBuilder<SalesController>(
            builder: (salesCtrl) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${'pos_cart_summary'.tr}: ${salesCtrl.totalItemCount} ${'items_sold_count'.tr} • \$${salesCtrl.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: controller.goToSalesCart,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                            Text(
                              'proceed_to_checkout'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: primaryOrange),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        const Divider(height: 12),
      ],
    );
  }

  // ==========================================
  // 3B. SCAN TO SELL CONTENT (MATCHED PRODUCT)
  // ==========================================
  Widget _buildScanToSellContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matched Product Card
          Obx(() {
            if (controller.isSearching.value) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: primaryOrange),
                    const SizedBox(height: 12),
                    Text(
                      'fetching_product_info'.tr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            final product = controller.scannedProduct.value;
            if (product == null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.barcode_reader,
                      size: 44,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'no_product_matched_barcode'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'barcode_label'.tr}: ${controller.currentBarcode.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => controller.prepareAddNewWithBarcode(controller.currentBarcode.value),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('register_new_product_barcode'.tr),
                    ),
                  ],
                ),
              );
            }

            final prodColor = product.color;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: prodColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: prodColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: prodColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getCategoryIcon(product.category),
                          color: prodColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${'barcode_label'.tr}: ${product.barcode.isNotEmpty ? product.barcode : controller.currentBarcode.value}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${product.price.toStringAsFixed(2)} (${(product.price * 4100).toStringAsFixed(0)} ៛)',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: prodColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.stock} ${'item_unit'.tr}',
                          style: TextStyle(
                            color: prodColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
                  const SizedBox(height: 14),

                  // Quantity Stepper + Add To Cart Button
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppThemes.darkBorder : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: controller.decreaseQty,
                            ),
                            Obx(
                              () => Text(
                                '${controller.sellQuantity.value}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: controller.increaseQty,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: controller.addScannedToCart,
                            icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                            label: Text(
                              'add_to_cart'.tr,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Scanned History Header
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 16, color: primaryOrange),
              const SizedBox(width: 6),
              Text(
                'recent_scan_history'.tr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Scanned History List
          Obx(() {
            if (controller.scannedHistory.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text('no_scan_history'.tr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ),
              );
            }

            return Column(
              children: controller.scannedHistory.take(5).map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item.isMatched ? Icons.check_circle_rounded : Icons.help_outline_rounded,
                            size: 16,
                            color: item.isMatched ? const Color(0xFF4CAF50) : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.productName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        item.barcode,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 3C. ADD NEW PRODUCT REGISTRATION CONTENT
  // ==========================================
  Widget _buildAddProductContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barcode Ready Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, color: primaryOrange, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'barcode_sku'.tr}:',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Obx(
                        () => Text(
                          controller.currentBarcode.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: primaryOrange),
                  onPressed: controller.generateRandomBarcode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Form Inputs
          TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: '${'product_name'.tr} *',
              prefixIcon: const Icon(Icons.inventory_2_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${'product_price'.tr} *',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'stock_qty'.tr,
                    prefixIcon: const Icon(Icons.layers_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Color Theme Selector
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${'product_color_theme'.tr}:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final activeHex = controller.selectedColorHex.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: productPalette.map((p) {
                  final isSelected = activeHex == p['hex'];
                  final color = p['color'] as Color;
                  return GestureDetector(
                    onTap: () {
                      controller.selectedColorHex.value = p['hex'] as String;
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
            );
          }),
          const SizedBox(height: 14),

          // Category Selector Dropdown
          Obx(() {
            final categories = controller.availableCategories;
            final currentKey = controller.selectedCategoryKey.value;
            final selectedCode = categories.any((c) => c['code'] == currentKey)
                ? currentKey
                : (categories.isNotEmpty ? categories.first['code']! : 'coffee');

            return Container(
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
                  value: selectedCode,
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  items: categories.map((c) {
                    return DropdownMenuItem(
                      value: c['code'],
                      child: Row(
                        children: [
                          const Icon(Icons.category_rounded, size: 18, color: primaryOrange),
                          const SizedBox(width: 10),
                          Expanded(child: Text(c['name'] ?? c['code']!)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedCategoryKey.value = val;
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 18),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: controller.saveProductToCatalog,
              icon: const Icon(Icons.save_rounded, size: 20),
              label: Text(
                'save_new_product'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
