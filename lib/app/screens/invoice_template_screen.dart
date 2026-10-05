import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/api_service.dart';
import '../themes/themes.dart';

enum InvoiceStyle {
  minimal,
  cafeClassic,
  retailCompact,
  taxOfficial,
}

class InvoiceTemplateScreen extends StatefulWidget {
  const InvoiceTemplateScreen({super.key});

  @override
  State<InvoiceTemplateScreen> createState() => _InvoiceTemplateScreenState();
}

class _InvoiceTemplateScreenState extends State<InvoiceTemplateScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  // Template Style & Paper
  InvoiceStyle selectedStyle = InvoiceStyle.minimal;
  String selectedPaperSize = '80mm'; // '58mm', '80mm', 'A4'

  // Header & Info Controllers
  final TextEditingController storeNameCtrl = TextEditingController(text: 'KITLUY Coffee & Bakery');
  final TextEditingController branchNameCtrl = TextEditingController(text: 'Toul Kork Branch');
  final TextEditingController phoneCtrl = TextEditingController(text: '097 534 8338 / 012 345 678');
  final TextEditingController addressCtrl = TextEditingController(text: '#128 St 2004, Phnom Penh');
  final TextEditingController headerMsgCtrl = TextEditingController(text: 'សូមស្វាគមន៍មកកាន់ហាងយើងខ្ញុំ! Welcome!');
  final TextEditingController footerMsgCtrl = TextEditingController(text: 'ទំនិញទិញរួចមិនអាចប្តូរវិញបានទេ\nThank you & See you again!');
  final TextEditingController wifiInfoCtrl = TextEditingController(text: 'Wi-Fi: KITLUY_GUEST / Pass: 88888888');
  final TextEditingController vatTinCtrl = TextEditingController(text: 'K001-902345890');

  // Feature Toggles
  bool showLogo = true;
  bool showKhqr = true;
  bool showBarcode = true;
  bool showCashier = true;
  bool showTableNum = true;
  bool showExchangeRate = true;
  bool showVatDetails = true;
  bool showWifiInfo = true;

  bool isSaving = false;
  bool isPrintingTest = false;

  @override
  void initState() {
    super.initState();
    _loadCachedSettings();
    _loadCurrentSettings();
  }

  InvoiceStyle _parseStyle(String styleStr) {
    switch (styleStr.toLowerCase()) {
      case 'cafeclassic':
        return InvoiceStyle.cafeClassic;
      case 'retailcompact':
        return InvoiceStyle.retailCompact;
      case 'taxofficial':
        return InvoiceStyle.taxOfficial;
      default:
        return InvoiceStyle.minimal;
    }
  }

  Future<void> _loadCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_user_invoice_template');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(cachedStr);
        if (mounted) {
          setState(() {
            if (data['style'] != null) selectedStyle = _parseStyle(data['style']);
            if (data['paper_size'] != null) selectedPaperSize = data['paper_size'];
            if (data['store_name'] != null && data['store_name'].toString().isNotEmpty) {
              storeNameCtrl.text = data['store_name'];
            }
            if (data['branch_name'] != null && data['branch_name'].toString().isNotEmpty) {
              branchNameCtrl.text = data['branch_name'];
            }
            if (data['address'] != null && data['address'].toString().isNotEmpty) {
              addressCtrl.text = data['address'];
            }
            if (data['phone_number'] != null && data['phone_number'].toString().isNotEmpty) {
              phoneCtrl.text = data['phone_number'];
            }
            if (data['vat_tin'] != null && data['vat_tin'].toString().isNotEmpty) {
              vatTinCtrl.text = data['vat_tin'];
            }
            if (data['header_message'] != null && data['header_message'].toString().isNotEmpty) {
              headerMsgCtrl.text = data['header_message'];
            }
            if (data['footer_message'] != null && data['footer_message'].toString().isNotEmpty) {
              footerMsgCtrl.text = data['footer_message'];
            }
            if (data['wifi_info'] != null && data['wifi_info'].toString().isNotEmpty) {
              wifiInfoCtrl.text = data['wifi_info'];
            }
            if (data['show_logo'] != null) showLogo = data['show_logo'] == true;
            if (data['show_khqr'] != null) showKhqr = data['show_khqr'] == true;
            if (data['show_barcode'] != null) showBarcode = data['show_barcode'] == true;
            if (data['show_cashier'] != null) showCashier = data['show_cashier'] == true;
            if (data['show_table_num'] != null) showTableNum = data['show_table_num'] == true;
            if (data['show_exchange_rate'] != null) showExchangeRate = data['show_exchange_rate'] == true;
            if (data['show_vat_details'] != null) showVatDetails = data['show_vat_details'] == true;
            if (data['show_wifi_info'] != null) showWifiInfo = data['show_wifi_info'] == true;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadCurrentSettings() async {
    try {
      final res = await ApiService.to.getInvoiceTemplate();
      if (res.isSuccess && res.data != null) {
        final d = res.data!;
        if (mounted) {
          setState(() {
            selectedStyle = _parseStyle(d.style);
            if (d.paperSize.isNotEmpty) selectedPaperSize = d.paperSize;
            if (d.storeName.isNotEmpty) storeNameCtrl.text = d.storeName;
            if (d.branchName.isNotEmpty) branchNameCtrl.text = d.branchName;
            if (d.address.isNotEmpty) addressCtrl.text = d.address;
            if (d.phoneNumber.isNotEmpty) phoneCtrl.text = d.phoneNumber;
            if (d.vatTin.isNotEmpty) vatTinCtrl.text = d.vatTin;
            if (d.headerMessage.isNotEmpty) headerMsgCtrl.text = d.headerMessage;
            if (d.footerMessage.isNotEmpty) footerMsgCtrl.text = d.footerMessage;
            if (d.wifiInfo.isNotEmpty) wifiInfoCtrl.text = d.wifiInfo;

            showLogo = d.showLogo;
            showKhqr = d.showKhqr;
            showBarcode = d.showBarcode;
            showCashier = d.showCashier;
            showTableNum = d.showTableNum;
            showExchangeRate = d.showExchangeRate;
            showVatDetails = d.showVatDetails;
            showWifiInfo = d.showWifiInfo;
          });
        }
        return;
      }
    } catch (_) {}

    // Fallback to general settings if template is not yet initialized
    try {
      final res = await ApiService.to.getSettings();
      if (res.isSuccess && res.data != null) {
        final d = res.data!;
        if (mounted) {
          setState(() {
            if (d.storeName.isNotEmpty) storeNameCtrl.text = d.storeName;
            if (d.address != null && d.address!.isNotEmpty) addressCtrl.text = d.address!;
            if (d.phoneNumber != null && d.phoneNumber!.isNotEmpty) phoneCtrl.text = d.phoneNumber!;
            if (d.receiptHeader != null && d.receiptHeader!.isNotEmpty) headerMsgCtrl.text = d.receiptHeader!;
            if (d.receiptFooter != null && d.receiptFooter!.isNotEmpty) footerMsgCtrl.text = d.receiptFooter!;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    storeNameCtrl.dispose();
    branchNameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    headerMsgCtrl.dispose();
    footerMsgCtrl.dispose();
    wifiInfoCtrl.dispose();
    vatTinCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => isSaving = true);
    HapticFeedback.mediumImpact();

    final payload = {
      'style': selectedStyle.name,
      'paper_size': selectedPaperSize,
      'store_name': storeNameCtrl.text.trim(),
      'branch_name': branchNameCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'phone_number': phoneCtrl.text.trim(),
      'vat_tin': vatTinCtrl.text.trim(),
      'header_message': headerMsgCtrl.text.trim(),
      'footer_message': footerMsgCtrl.text.trim(),
      'wifi_info': wifiInfoCtrl.text.trim(),
      'show_logo': showLogo,
      'show_khqr': showKhqr,
      'show_barcode': showBarcode,
      'show_cashier': showCashier,
      'show_table_num': showTableNum,
      'show_exchange_rate': showExchangeRate,
      'show_vat_details': showVatDetails,
      'show_wifi_info': showWifiInfo,
    };

    // 1. Immediately cache locally for instant responsiveness & offline resilience
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_invoice_template', jsonEncode(payload));
    } catch (_) {}

    try {
      await ApiService.to.updateInvoiceTemplate(payload);
      // Also update general store settings in background
      ApiService.to.updateSettings({
        'store_name': storeNameCtrl.text.trim(),
        'store_branch': branchNameCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'phone_number': phoneCtrl.text.trim(),
        'receipt_header': headerMsgCtrl.text.trim(),
        'receipt_footer': footerMsgCtrl.text.trim(),
      });

      if (mounted) setState(() => isSaving = false);

      Get.snackbar(
        'success'.tr,
        'saved_template_success'.tr,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    } catch (e) {
      if (mounted) setState(() => isSaving = false);
      Get.snackbar(
        'success'.tr,
        'saved_template_local'.tr,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    }
  }

  void _printTestReceipt() {
    setState(() => isPrintingTest = true);
    HapticFeedback.selectionClick();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => isPrintingTest = false);
        Get.snackbar(
          'print_receipt'.tr,
          '${'test_receipt_sent'.tr} ($selectedPaperSize)',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.print_rounded, color: Colors.white),
        );
      }
    });
  }

  Future<void> _resetToDefaults() async {
    Get.defaultDialog(
      title: 'reset_template_title'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'reset_template_confirm'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
      ),
      textConfirm: 'reset_template_title'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: primaryOrange,
      onConfirm: () async {
        Get.back();
        try {
          final res = await ApiService.to.resetInvoiceTemplate();
          if (res.isSuccess && res.data != null) {
            final d = res.data!;
            setState(() {
              selectedStyle = _parseStyle(d.style);
              selectedPaperSize = d.paperSize;
              storeNameCtrl.text = d.storeName;
              branchNameCtrl.text = d.branchName;
              addressCtrl.text = d.address;
              phoneCtrl.text = d.phoneNumber;
              vatTinCtrl.text = d.vatTin;
              headerMsgCtrl.text = d.headerMessage;
              footerMsgCtrl.text = d.footerMessage;
              wifiInfoCtrl.text = d.wifiInfo;

              showLogo = d.showLogo;
              showKhqr = d.showKhqr;
              showBarcode = d.showBarcode;
              showCashier = d.showCashier;
              showTableNum = d.showTableNum;
              showExchangeRate = d.showExchangeRate;
              showVatDetails = d.showVatDetails;
              showWifiInfo = d.showWifiInfo;
            });
            Get.snackbar(
              'success'.tr,
              'template_reset_success'.tr,
              backgroundColor: const Color(0xFF2E7D32),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
            );
          }
        } catch (_) {}
      },
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'invoice_template'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white),
            tooltip: 'reset_template_title'.tr,
            onPressed: _resetToDefaults,
          ),
          IconButton(
            icon: isPrintingTest
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.print_rounded, color: Colors.white),
            tooltip: 'print_receipt'.tr,
            onPressed: isPrintingTest ? null : _printTestReceipt,
          ),
          IconButton(
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_rounded, color: Colors.white),
            tooltip: 'save'.tr,
            onPressed: isSaving ? null : _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interactive Real-Time Receipt Preview
            _buildLiveReceiptPreview(context),
            const SizedBox(height: 20),

            // 2. Paper Size & Style Selector
            _buildStyleAndPaperSelector(context),
            const SizedBox(height: 20),

            // 3. Store Header & Details
            _buildStoreDetailsSection(context),
            const SizedBox(height: 20),

            // 4. Content Display Toggles
            _buildContentTogglesSection(context),
            const SizedBox(height: 20),

            // 5. Messages & Notes
            _buildMessagesSection(context),
            const SizedBox(height: 30),

            // Save & Test Print Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printTestReceipt,
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text('test_print_btn'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryOrange,
                      side: const BorderSide(color: primaryOrange),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : _saveSettings,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text('save'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. LIVE RECEIPT PREVIEW WIDGET
  // ==========================================
  Widget _buildLiveReceiptPreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperWidth = selectedPaperSize == '58mm'
        ? 260.0
        : (selectedPaperSize == 'A4' ? double.infinity : 320.0);

    return Center(
      child: Container(
        width: paperWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Jagged top edge or clean top
            Container(
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                children: [
                  // Logo / Header Icon
                  if (showLogo) ...[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selectedStyle == InvoiceStyle.cafeClassic
                            ? Icons.coffee_rounded
                            : (selectedStyle == InvoiceStyle.taxOfficial
                                ? Icons.account_balance_rounded
                                : Icons.store_rounded),
                        color: primaryOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Store Name
                  Text(
                    storeNameCtrl.text.isNotEmpty ? storeNameCtrl.text : 'Store Name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: selectedStyle == InvoiceStyle.taxOfficial ? 'serif' : null,
                      fontSize: selectedStyle == InvoiceStyle.taxOfficial ? 16 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),

                  // Branch Name
                  if (branchNameCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      branchNameCtrl.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  // Address & Phone
                  if (addressCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      addressCtrl.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ],
                  if (phoneCtrl.text.isNotEmpty) ...[
                    Text(
                      'Tel: ${phoneCtrl.text}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ],

                  // VAT / TIN if Tax Official
                  if (selectedStyle == InvoiceStyle.taxOfficial && vatTinCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VATTIN: ${vatTinCtrl.text}',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],

                  // Custom Header Greeting
                  if (headerMsgCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      headerMsgCtrl.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  _buildReceiptDashedLine(),
                  const SizedBox(height: 8),

                  // Order & Cashier Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'INV: #INV-2026-0889',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        'Date: ${DateTime.now().toString().split(' ').first}',
                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    ],
                  ),
                  if (showCashier || showTableNum) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showCashier)
                          Text(
                            'Cashier: Admin',
                            style: TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        if (showTableNum)
                          Text(
                            'Table: #04 (Dine-In)',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),
                  _buildReceiptDashedLine(),
                  const SizedBox(height: 8),

                  // Sample Items Table
                  _buildSampleItemRow('1', 'Iced Latte (L)', '\$2.50', '\$2.50'),
                  const SizedBox(height: 4),
                  _buildSampleItemRow('2', 'Croissant Chocolate', '\$1.75', '\$3.50'),
                  const SizedBox(height: 4),
                  _buildSampleItemRow('1', 'Matcha Green Tea', '\$2.80', '\$2.80'),

                  const SizedBox(height: 8),
                  _buildReceiptDashedLine(),
                  const SizedBox(height: 8),

                  // Subtotal & Totals
                  _buildTotalRow('subtotal'.tr, '\$8.80'),
                  _buildTotalRow('discount'.tr, '-\$0.88', isDiscount: true),
                  if (showVatDetails) _buildTotalRow('VAT (10%)', '\$0.79'),
                  const SizedBox(height: 4),
                  const Divider(color: Colors.black87, thickness: 1.2),
                  const SizedBox(height: 2),

                  // Grand Total USD & KHR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'total'.tr}:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const Text(
                        '\$8.71',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  if (showExchangeRate) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'currency_khr'.tr} (4,100):',
                          style: const TextStyle(fontSize: 10.5, color: Colors.black87),
                        ),
                        const Text(
                          '35,700 ៛',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],

                  // Payment Method
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${'payment_method'.tr}:', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      Text('payment_khqr'.tr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    ],
                  ),

                  // KHQR Code Preview
                  if (showKhqr) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'KHQR BAKONG',
                              style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Icon(Icons.qr_code_2_rounded, size: 72, color: Colors.black87),
                          Text(
                            'Scan to Pay with Any Banking App',
                            style: TextStyle(fontSize: 8.5, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Wi-Fi Info
                  if (showWifiInfo && wifiInfoCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_rounded, size: 12, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            wifiInfoCtrl.text,
                            style: const TextStyle(fontSize: 9.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Footer Message
                  if (footerMsgCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      footerMsgCtrl.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ],

                  // Barcode
                  if (showBarcode) ...[
                    const SizedBox(height: 8),
                    const Icon(Icons.barcode_reader, size: 36, color: Colors.black87),
                    Text(
                      '*INV20260889*',
                      style: TextStyle(fontSize: 8, color: Colors.black54, letterSpacing: 2),
                    ),
                  ],

                  const SizedBox(height: 6),
                  Text(
                    'Powered by KITLUY POS Cloud',
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black38),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSampleItemRow(String qty, String name, String price, String total) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            qty,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 10.5, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            price,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            total,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDiscount ? const Color(0xFFD32F2F) : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDiscount ? const Color(0xFFD32F2F) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. TEMPLATE STYLE & PAPER SELECTOR
  // ==========================================
  Widget _buildStyleAndPaperSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final styles = [
      {'id': InvoiceStyle.minimal, 'name': 'Minimal Modern', 'icon': Icons.view_headline_rounded},
      {'id': InvoiceStyle.cafeClassic, 'name': 'Cafe & Dining', 'icon': Icons.coffee_rounded},
      {'id': InvoiceStyle.retailCompact, 'name': 'Retail Supermarket', 'icon': Icons.shopping_basket_rounded},
      {'id': InvoiceStyle.taxOfficial, 'name': 'Formal Tax / VAT', 'icon': Icons.receipt_long_rounded},
    ];

    final paperSizes = ['58mm', '80mm', 'A4'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.style_rounded, color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'template_paper_title'.tr,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Style Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: styles.length,
            itemBuilder: (context, index) {
              final s = styles[index];
              final isSelected = selectedStyle == s['id'];
              return InkWell(
                onTap: () {
                  setState(() => selectedStyle = s['id'] as InvoiceStyle);
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryOrange.withValues(alpha: 0.12)
                        : (isDark ? AppThemes.darkSurface : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryOrange : (isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        s['icon'] as IconData,
                        size: 18,
                        color: isSelected ? primaryOrange : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s['name'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? primaryOrange : theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Paper Size Switcher
          Text(
            'thermal_paper_width'.tr,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: paperSizes.map((size) {
              final isSelected = selectedPaperSize == size;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() => selectedPaperSize = size);
                      HapticFeedback.selectionClick();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryOrange : (isDark ? AppThemes.darkSurface : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. STORE DETAILS & BRANDING
  // ==========================================
  Widget _buildStoreDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'store_branding'.tr,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: storeNameCtrl,
            label: 'store_name'.tr,
            icon: Icons.business_rounded,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: branchNameCtrl,
            label: 'branch_name'.tr,
            icon: Icons.location_city_rounded,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: phoneCtrl,
            label: 'store_phone'.tr,
            icon: Icons.phone_rounded,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: addressCtrl,
            label: 'store_address'.tr,
            icon: Icons.place_rounded,
            onChanged: (v) => setState(() {}),
          ),
          if (selectedStyle == InvoiceStyle.taxOfficial) ...[
            const SizedBox(height: 10),
            _buildTextField(
              controller: vatTinCtrl,
              label: 'tax_vat_no'.tr,
              icon: Icons.badge_rounded,
              onChanged: (v) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 4. CONTENT DISPLAY TOGGLES
  // ==========================================
  Widget _buildContentTogglesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.toggle_on_rounded, color: primaryOrange, size: 22),
              const SizedBox(width: 8),
              Text(
                'content_options_title'.tr,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _buildSwitchRow('show_logo_opt'.tr, 'show_logo_opt_sub'.tr, showLogo, (v) => setState(() => showLogo = v)),
          _buildSwitchRow('show_khqr_opt'.tr, 'show_khqr_opt_sub'.tr, showKhqr, (v) => setState(() => showKhqr = v)),
          _buildSwitchRow('show_barcode_opt'.tr, 'show_barcode_opt_sub'.tr, showBarcode, (v) => setState(() => showBarcode = v)),
          _buildSwitchRow('show_cashier_opt'.tr, 'show_cashier_opt_sub'.tr, showCashier, (v) => setState(() => showCashier = v)),
          _buildSwitchRow('show_table_opt'.tr, 'show_table_opt_sub'.tr, showTableNum, (v) => setState(() => showTableNum = v)),
          _buildSwitchRow('show_rate_opt'.tr, 'show_rate_opt_sub'.tr, showExchangeRate, (v) => setState(() => showExchangeRate = v)),
          _buildSwitchRow('show_vat_opt'.tr, 'show_vat_opt_sub'.tr, showVatDetails, (v) => setState(() => showVatDetails = v)),
          _buildSwitchRow('show_wifi_opt'.tr, 'show_wifi_opt_sub'.tr, showWifiInfo, (v) => setState(() => showWifiInfo = v)),
        ],
      ),
    );
  }

  // ==========================================
  // 5. MESSAGES & NOTES SECTION
  // ==========================================
  Widget _buildMessagesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'custom_notes_title'.tr,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: headerMsgCtrl,
            label: 'header_greeting_label'.tr,
            icon: Icons.waving_hand_rounded,
            maxLines: 2,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: footerMsgCtrl,
            label: 'footer_note_label'.tr,
            icon: Icons.sentiment_satisfied_alt_rounded,
            maxLines: 2,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: wifiInfoCtrl,
            label: 'guest_wifi_label'.tr,
            icon: Icons.wifi_rounded,
            onChanged: (v) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: primaryOrange),
        filled: true,
        fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    String titleKh,
    String titleEn,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKh,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  titleEn,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: primaryOrange,
            activeTrackColor: primaryOrange.withValues(alpha: 0.5),
            onChanged: (v) {
              onChanged(v);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }
}
