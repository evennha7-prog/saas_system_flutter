import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/home/controllers/home_controller.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../themes/themes.dart';

class StoreInfoScreen extends StatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  State<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends State<StoreInfoScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  late final TextEditingController nameController;
  late final TextEditingController branchController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController taxController;
  late final TextEditingController rateController;
  late final TextEditingController receiptHeaderController;
  late final TextEditingController receiptFooterController;

  int selectedLogoIndex = 0;
  final List<IconData> logoPresets = [
    Icons.local_cafe_rounded,
    Icons.storefront_rounded,
    Icons.coffee_rounded,
    Icons.restaurant_rounded,
    Icons.emoji_food_beverage_rounded,
  ];

  @override
  void initState() {
    super.initState();
    String initialShopName = 'AudiCafe';
    String initialPhone = '097 534 8338';

    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      initialShopName = home.shopName.value;
      initialPhone = home.phoneNumber.value;
    }

    nameController = TextEditingController(text: initialShopName);
    branchController = TextEditingController(text: 'POS 01 - Main Branch');
    phoneController = TextEditingController(text: initialPhone);
    addressController = TextEditingController(
      text: '#128, St 2004, Sangkat Teuk Thla, Phnom Penh',
    );
    taxController = TextEditingController(text: 'VAT-884920194');
    rateController = TextEditingController(text: '4,100 KHR');
    receiptHeaderController = TextEditingController(
      text: 'Welcome to AudiCafe! Fresh Coffee Everyday',
    );
    receiptFooterController = TextEditingController(
      text: 'Thank you for your visit! Please come again.',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    branchController.dispose();
    phoneController.dispose();
    addressController.dispose();
    taxController.dispose();
    rateController.dispose();
    receiptHeaderController.dispose();
    receiptFooterController.dispose();
    super.dispose();
  }

  void _saveStoreInfo() {
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      home.shopName.value = nameController.text.trim();
      home.phoneNumber.value = phoneController.text.trim();
    }

    if (Get.isRegistered<ProfileController>()) {
      final profile = Get.find<ProfileController>();
      profile.phoneNumber.value = phoneController.text.trim();
    }

    Get.snackbar(
      'success'.tr,
      'store_info_updated_msg'.tr,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }

  void _showLogoPicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'select_store_logo'.tr,
                    style: TextStyle(
                      fontSize: 16,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(logoPresets.length, (index) {
                  final isSelected = selectedLogoIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedLogoIndex = index);
                      Get.back();
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryOrange
                            : (isDark
                                  ? AppThemes.darkSurface
                                  : const Color(0xFFF4F5F8)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? primaryOrange
                              : (isDark
                                    ? AppThemes.darkBorder
                                    : Colors.grey.shade300),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        logoPresets[index],
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? AppThemes.darkTextPrimary
                                  : Colors.black87),
                        size: 26,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
          'store_info'.tr,
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
            // 1. Logo & Brand Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryOrange, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      logoPresets[selectedLogoIndex],
                      color: primaryOrange,
                      size: 50,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showLogoPicker,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'store_info_subtitle'.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // 2. Form Card 1: Store Basic Details
            _buildCardWrapper(
              title: 'basic_info'.tr,
              icon: Icons.storefront_rounded,
              children: [
                _buildInputField(
                  label: 'store_name'.tr,
                  controller: nameController,
                  icon: Icons.badge_outlined,
                  hint: 'store_name_hint'.tr,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'branch_terminal'.tr,
                  controller: branchController,
                  icon: Icons.point_of_sale_rounded,
                  hint: 'branch_name_hint'.tr,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'store_phone'.tr,
                  controller: phoneController,
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  hint: 'store_phone_hint'.tr,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'store_address'.tr,
                  controller: addressController,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  hint: 'store_address_hint'.tr,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Form Card 2: Tax & Financial Info
            _buildCardWrapper(
              title: 'tax_and_rates'.tr,
              icon: Icons.receipt_long_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'tax_vat_no'.tr,
                        controller: taxController,
                        icon: Icons.pin_rounded,
                        hint: 'VAT-884920194',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'exchange_rate_khr'.tr,
                        controller: rateController,
                        icon: Icons.currency_exchange_rounded,
                        hint: '4,100 KHR',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Form Card 3: Receipt Template Messages
            _buildCardWrapper(
              title: 'receipt_messages'.tr,
              icon: Icons.format_quote_rounded,
              children: [
                _buildInputField(
                  label: 'receipt_header_msg'.tr,
                  controller: receiptHeaderController,
                  icon: Icons.notes_rounded,
                  hint: 'Welcome to AudiCafe',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'receipt_footer_msg'.tr,
                  controller: receiptFooterController,
                  icon: Icons.favorite_border_rounded,
                  hint: 'Thank you! Please come again',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Save Button
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
                onPressed: _saveStoreInfo,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  'save_store_info'.tr,
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

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppThemes.darkTextSecondary
                : const Color(0xFF4A5260),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: primaryOrange, size: 20),
            filled: true,
            fillColor: isDark ? AppThemes.darkSurface : const Color(0xFFF9FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryOrange, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
