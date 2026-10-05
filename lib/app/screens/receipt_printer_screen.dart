import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../themes/themes.dart';

class ReceiptPrinterScreen extends StatefulWidget {
  const ReceiptPrinterScreen({super.key});

  @override
  State<ReceiptPrinterScreen> createState() => _ReceiptPrinterScreenState();
}

class _ReceiptPrinterScreenState extends State<ReceiptPrinterScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String selectedPaperSize = '80mm';
  String connectedDevice = 'POS-80B Thermal Printer';
  bool isScanning = false;

  bool printStoreLogo = true;
  bool printKhqr = true;
  bool printCashierName = true;
  bool autoCutPaper = true;
  bool soundOnPrint = true;
  int copyCount = 1;

  String storeName = 'AUDICAFE POS';
  String storeAddress = '#128 St 2004, Phnom Penh';
  String storePhone = 'Tel: 097 534 8338';

  final List<Map<String, dynamic>> pairedDevices = [
    {
      'name': 'POS-80B Thermal Printer',
      'mac': '00:11:22:33:44:55',
      'type': 'Bluetooth 4.0 / ESC-POS',
      'isConnected': true,
      'signal': 95,
    },
    {
      'name': 'RPP-02 Mobile Printer (58mm)',
      'mac': '88:44:22:11:00:AA',
      'type': 'Bluetooth 4.2',
      'isConnected': false,
      'signal': 70,
    },
    {
      'name': 'Sunmi POS Wireless Printer',
      'mac': 'AA:BB:CC:DD:EE:FF',
      'type': 'Wi-Fi / LAN',
      'isConnected': false,
      'signal': 85,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStoreSettings();
  }

  Future<void> _loadStoreSettings() async {
    try {
      final res = await ApiService.to.getSettings();
      if (res.isSuccess && res.data != null) {
        setState(() {
          storeName = res.data!.storeName;
          if (res.data!.address != null && res.data!.address!.isNotEmpty) {
            storeAddress = res.data!.address!;
          }
          if (res.data!.phoneNumber != null && res.data!.phoneNumber!.isNotEmpty) {
            storePhone = 'Tel: ${res.data!.phoneNumber}';
          }
        });
      }
    } catch (_) {}
  }

  void _toggleConnect(int index) {
    setState(() {
      for (int i = 0; i < pairedDevices.length; i++) {
        if (i == index) {
          pairedDevices[i]['isConnected'] = !pairedDevices[i]['isConnected'];
          if (pairedDevices[i]['isConnected']) {
            connectedDevice = pairedDevices[i]['name'];
            Get.snackbar(
              'printer_connected'.tr,
              'Connected to ${pairedDevices[i]['name']}',
              backgroundColor: const Color(0xFF1B5E20),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2),
            );
          } else {
            connectedDevice = 'Disconnected';
          }
        } else {
          pairedDevices[i]['isConnected'] = false;
        }
      }
    });
  }

  void _scanBluetoothDevices() {
    setState(() => isScanning = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isScanning = false);
        Get.snackbar(
          'bluetooth_scan'.tr,
          'Found ${pairedDevices.length} POS thermal printers nearby.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    });
  }

  void _printTestReceipt() {
    Get.defaultDialog(
      title: 'receipt'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(
              '☕ $storeName ☕',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              storeAddress,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              storePhone,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('sample_item_latte'.tr, style: const TextStyle(fontSize: 12)),
                const Text(
                  '\$2.25',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('sample_item_croissant'.tr, style: const TextStyle(fontSize: 12)),
                const Text(
                  '\$1.80',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL (USD):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '\$4.05',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryOrange,
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL (KHR):',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  '16,600 KHR',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Text(
              '*** TEST PRINT OK (80mm) ***',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
      textConfirm: 'print_receipt'.tr,
      textCancel: 'close'.tr,
      confirmTextColor: Colors.white,
      buttonColor: primaryOrange,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'printing_receipt'.tr,
          'Sent test receipt to $connectedDevice ($selectedPaperSize)',
          backgroundColor: const Color(0xFF1B5E20),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.print_rounded, color: Colors.white),
        );
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'receipt_printer'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Connection Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C323F), Color(0xFF1B1E26)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: primaryOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.print_rounded,
                      color: primaryOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: connectedDevice != 'Disconnected'
                                    ? const Color(0xFF4CAF50)
                                    : Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              connectedDevice != 'Disconnected'
                                  ? 'printer_connected'.tr
                                  : 'Disconnected',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          connectedDevice,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                    onPressed: isScanning ? null : _scanBluetoothDevices,
                    icon: isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Paper Size Selector (80mm vs 58mm)
            _buildCardWrapper(
              title: 'paper_size_label'.tr,
              icon: Icons.aspect_ratio_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: _buildPaperSizeOption(
                      title: 'paper_size_80mm_label'.tr,
                      subtitle: 'paper_size_standard'.tr,
                      size: '80mm',
                      isSelected: selectedPaperSize == '80mm',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaperSizeOption(
                      title: 'paper_size_58mm_label'.tr,
                      subtitle: 'paper_size_compact'.tr,
                      size: '58mm',
                      isSelected: selectedPaperSize == '58mm',
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Paired Bluetooth Devices List
            _buildCardWrapper(
              title: 'paired_bluetooth_devices'.tr,
              icon: Icons.bluetooth_rounded,
              child: Column(
                children: List.generate(pairedDevices.length, (index) {
                  final device = pairedDevices[index];
                  final isConnected = device['isConnected'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? primaryOrange.withValues(alpha: 0.08)
                          : (isDark
                                ? AppThemes.darkSurface
                                : const Color(0xFFF9FAFC)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isConnected
                            ? primaryOrange
                            : (isDark
                                  ? AppThemes.darkBorder
                                  : Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bluetooth_searching_rounded,
                          color: isConnected
                              ? primaryOrange
                              : (isDark
                                    ? AppThemes.darkTextSecondary
                                    : Colors.grey.shade500),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${device['mac']} • ${device['type']}',
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConnected
                                ? (isDark
                                      ? AppThemes.darkBorder
                                      : Colors.grey.shade200)
                                : primaryOrange,
                            foregroundColor: isConnected
                                ? (isDark
                                      ? AppThemes.darkTextPrimary
                                      : Colors.black87)
                                : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _toggleConnect(index),
                          child: Text(
                            isConnected
                                ? 'disconnect_btn'.tr
                                : 'connect_btn'.tr,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Receipt Format Options
            _buildCardWrapper(
              title: 'print_options_title'.tr,
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'print_logo_opt'.tr,
                    value: printStoreLogo,
                    onChanged: (val) => setState(() => printStoreLogo = val),
                  ),
                  const Divider(height: 16),
                  _buildSwitchRow(
                    title: 'print_qr_opt'.tr,
                    value: printKhqr,
                    onChanged: (val) => setState(() => printKhqr = val),
                  ),
                  const Divider(height: 16),
                  _buildSwitchRow(
                    title: 'print_cashier_opt'.tr,
                    value: printCashierName,
                    onChanged: (val) => setState(() => printCashierName = val),
                  ),
                  const Divider(height: 16),
                  _buildSwitchRow(
                    title: 'auto_cut_opt'.tr,
                    value: autoCutPaper,
                    onChanged: (val) => setState(() => autoCutPaper = val),
                  ),
                  const Divider(height: 16),
                  _buildSwitchRow(
                    title: 'sound_beep_opt'.tr,
                    value: soundOnPrint,
                    onChanged: (val) => setState(() => soundOnPrint = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Test Print CTA Button
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
                onPressed: _printTestReceipt,
                icon: const Icon(Icons.print_rounded, size: 20),
                label: Text(
                  'print_receipt'.tr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperSizeOption({
    required String title,
    required String subtitle,
    required String size,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => selectedPaperSize = size),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryOrange.withValues(alpha: 0.1)
              : (isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryOrange
                : (isDark ? AppThemes.darkBorder : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? primaryOrange
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? primaryOrange
                      : (isDark ? AppThemes.darkTextSecondary : Colors.grey),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
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

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: primaryOrange,
        ),
      ],
    );
  }
}
