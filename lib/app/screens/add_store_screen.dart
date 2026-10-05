import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({super.key});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final storeNameCtrl = TextEditingController();
  final branchNameCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(text: '123456');
  final pinCtrl = TextEditingController(text: '1234');
  final addressCtrl = TextEditingController();
  final customerPhoneCtrl = TextEditingController();
  final cashFloatCtrl = TextEditingController(text: '50.00');

  // Selections
  String selectedBusinessType = 'Cafe & Coffee Shop';
  String selectedCity = 'Phnom Penh';
  String selectedCurrency = 'USD';
  String selectedPlan = 'Pro';
  int posTerminalCount = 2;
  double vatRate = 0.0;

  // Feature Toggles
  bool autoCreateDefaultMenu = true;
  bool enableTelegramAlerts = true;
  bool enableAutoReceiptPrint = true;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    storeNameCtrl.dispose();
    branchNameCtrl.dispose();
    ownerNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    pinCtrl.dispose();
    addressCtrl.dispose();
    customerPhoneCtrl.dispose();
    cashFloatCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (storeNameCtrl.text.trim().isEmpty ||
        ownerNameCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'err_fill_all'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    if (pinCtrl.text.trim().length != 4) {
      Get.snackbar(
        'warning'.tr,
        'err_invalid_pin'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    // Call AdministratorController if registered
    if (Get.isRegistered<AdministratorController>()) {
      final adminCtrl = Get.find<AdministratorController>();
      adminCtrl.addNewStore(
        name: storeNameCtrl.text.trim(),
        branch: branchNameCtrl.text.trim().isNotEmpty
            ? branchNameCtrl.text.trim()
            : '$selectedCity Branch',
        ownerName: ownerNameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        address: addressCtrl.text.trim().isNotEmpty
            ? addressCtrl.text.trim()
            : '$selectedCity, Cambodia',
        currency: selectedCurrency,
        plan: selectedPlan,
        adminPin: pinCtrl.text.trim(),
      );
    } else {
      Get.snackbar(
        'success'.tr,
        'store_created_success'.tr,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }

    Get.back();
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
          'add_new_store'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _submitForm,
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            label: Text(
              'save'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Card
              _buildHeroHeader(context),
              const SizedBox(height: 16),

              // Section 1: Store Identity
              _buildSectionCard(
                context: context,
                icon: Icons.storefront_rounded,
                title: 'store_identity'.tr,
                children: [
                  _buildTextField(
                    controller: storeNameCtrl,
                    label: 'store_name'.tr,
                    hint: 'store_name_hint'.tr,
                    icon: Icons.business_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: branchNameCtrl,
                    label: 'branch_name'.tr,
                    hint: 'branch_name_hint'.tr,
                    icon: Icons.location_city_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField<String>(
                    context: context,
                    label: 'business_type_label'.tr,
                    value: selectedBusinessType,
                    items: [
                      'Cafe & Coffee Shop',
                      'Bakery & Pastry',
                      'Restaurant & Eatery',
                      'Milk Tea & Beverages',
                      'Retail & Mart',
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedBusinessType = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 2: Store Owner & Master Account
              _buildSectionCard(
                context: context,
                icon: Icons.badge_rounded,
                title: 'store_owner_account'.tr,
                children: [
                  _buildTextField(
                    controller: ownerNameCtrl,
                    label: 'store_owner'.tr,
                    hint: 'store_owner_hint'.tr,
                    icon: Icons.person_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: phoneCtrl,
                    label: 'store_phone'.tr,
                    hint: 'store_phone_hint'.tr,
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: emailCtrl,
                    label: 'email_optional'.tr,
                    hint: 'e.g. manager@audicafe.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: passwordCtrl,
                          label: 'password'.tr,
                          hint: 'Min 6 characters',
                          icon: Icons.lock_outline_rounded,
                          obscureText: !isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() => isPasswordVisible = !isPasswordVisible);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: pinCtrl,
                          label: 'quick_pin'.tr,
                          hint: 'e.g. 1234',
                          icon: Icons.pin_rounded,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 3: Location & Address
              _buildSectionCard(
                context: context,
                icon: Icons.location_on_rounded,
                title: 'store_location'.tr,
                children: [
                  _buildDropdownField<String>(
                    context: context,
                    label: 'province_city_label'.tr,
                    value: selectedCity,
                    items: [
                      'Phnom Penh',
                      'Siem Reap',
                      'Preah Sihanouk',
                      'Battambang',
                      'Kampot',
                      'Kandal',
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCity = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: addressCtrl,
                    label: 'store_address'.tr,
                    hint: 'store_address_hint'.tr,
                    icon: Icons.map_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: customerPhoneCtrl,
                    label: 'hotline_label'.tr,
                    hint: 'e.g. 023 999 888',
                    icon: Icons.contact_phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 4: Operational Settings & Currency
              _buildSectionCard(
                context: context,
                icon: Icons.tune_rounded,
                title: 'pos_operations_title'.tr,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField<String>(
                          context: context,
                          label: 'store_currency'.tr,
                          value: selectedCurrency,
                          items: ['USD', 'KHR'],
                          onChanged: (val) {
                            if (val != null) setState(() => selectedCurrency = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: cashFloatCtrl,
                          label: 'cash_float_label'.tr,
                          hint: 'e.g. 50.00',
                          icon: Icons.account_balance_wallet_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField<int>(
                          context: context,
                          label: 'pos_terminals_count_label'.tr,
                          value: posTerminalCount,
                          items: [1, 2, 3, 5, 10],
                          itemLabel: (v) => '$v Terminals',
                          onChanged: (val) {
                            if (val != null) setState(() => posTerminalCount = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdownField<double>(
                          context: context,
                          label: 'vat_rate_label'.tr,
                          value: vatRate,
                          items: [0.0, 5.0, 10.0],
                          itemLabel: (v) => '${v.toStringAsFixed(0)}% VAT',
                          onChanged: (val) {
                            if (val != null) setState(() => vatRate = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 5: Subscription Plan Selection
              _buildSectionCard(
                context: context,
                icon: Icons.workspace_premium_rounded,
                title: 'store_plan'.tr,
                children: [
                  _buildPlanOption(
                    title: 'plan_enterprise'.tr,
                    price: '\$49/mo',
                    features: 'Unlimited POS Terminals • Real-time Cloud Sync • VIP Support',
                    planKey: 'Enterprise',
                    color: const Color(0xFF8E24AA),
                  ),
                  const SizedBox(height: 8),
                  _buildPlanOption(
                    title: 'plan_pro'.tr,
                    price: '\$29/mo',
                    features: 'Up to 3 Terminals • Multi-staff Accounts • Daily Cloud Backup',
                    planKey: 'Pro',
                    color: const Color(0xFF0288D1),
                  ),
                  const SizedBox(height: 8),
                  _buildPlanOption(
                    title: 'plan_standard'.tr,
                    price: '\$15/mo',
                    features: '1 POS Terminal • Local & Cloud Inventory • Basic Reports',
                    planKey: 'Standard',
                    color: primaryOrange,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 6: Quick Setup Options
              _buildSectionCard(
                context: context,
                icon: Icons.auto_awesome_rounded,
                title: 'initial_automation_title'.tr,
                children: [
                  _buildSwitchRow(
                    title: 'create_sample_menu_opt'.tr,
                    subtitle: 'store_setup_categories_desc'.tr,
                    value: autoCreateDefaultMenu,
                    onChanged: (v) => setState(() => autoCreateDefaultMenu = v),
                  ),
                  Divider(
                    height: 16,
                    color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                  ),
                  _buildSwitchRow(
                    title: 'enable_telegram_alerts_opt'.tr,
                    subtitle: 'store_setup_telegram_desc'.tr,
                    value: enableTelegramAlerts,
                    onChanged: (v) => setState(() => enableTelegramAlerts = v),
                  ),
                  Divider(
                    height: 16,
                    color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                  ),
                  _buildSwitchRow(
                    title: 'enable_autoprint_opt'.tr,
                    subtitle: 'store_setup_printer_desc'.tr,
                    value: enableAutoReceiptPrint,
                    onChanged: (v) => setState(() => enableAutoReceiptPrint = v),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _submitForm,
                  icon: const Icon(Icons.add_business_rounded, size: 20),
                  label: Text(
                    'create_activate_store_btn'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2C3E50), const Color(0xFF1A252F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_mall_directory_rounded,
              color: primaryOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SaaS Multi-Tenant Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'store_setup_subtitle'.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool required = false,
    int? maxLength,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required BuildContext context,
    required String label,
    required T value,
    required List<T> items,
    String Function(T)? itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : null);
    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel != null ? itemLabel(item) : item.toString(),
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPlanOption({
    required String title,
    required String price,
    required String features,
    required String planKey,
    required Color color,
  }) {
    final isSelected = selectedPlan == planKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => selectedPlan = planKey),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark ? AppThemes.darkSurface : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : (isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? color : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      features,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: primaryOrange,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
