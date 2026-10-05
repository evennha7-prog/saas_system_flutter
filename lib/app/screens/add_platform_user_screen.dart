import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class AddPlatformUserScreen extends StatefulWidget {
  const AddPlatformUserScreen({super.key});

  @override
  State<AddPlatformUserScreen> createState() => _AddPlatformUserScreenState();
}

class _AddPlatformUserScreenState extends State<AddPlatformUserScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(text: '123456');
  final pinCtrl = TextEditingController(text: '1234');

  String selectedRole = 'cashier';
  int selectedStoreId = 1;
  String selectedShift = 'full_time_shift'.tr;
  bool isPasswordVisible = false;
  bool isAccountActive = true;

  // Granular Permissions
  final Map<String, bool> permissions = {
    'pos_sales': true,
    'discount': true,
    'refunds': false,
    'stock_edit': false,
    'view_reports': false,
    'price_override': false,
  };

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AdministratorController>()) {
      final adminCtrl = Get.find<AdministratorController>();
      if (adminCtrl.stores.isNotEmpty) {
        selectedStoreId = adminCtrl.stores.first.id;
      }
    }
    _applyRoleDefaults(selectedRole);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    pinCtrl.dispose();
    super.dispose();
  }

  void _applyRoleDefaults(String role) {
    setState(() {
      selectedRole = role;
      switch (role) {
        case 'super_admin':
        case 'store_admin':
          permissions['pos_sales'] = true;
          permissions['discount'] = true;
          permissions['refunds'] = true;
          permissions['stock_edit'] = true;
          permissions['view_reports'] = true;
          permissions['price_override'] = true;
          break;
        case 'cashier':
          permissions['pos_sales'] = true;
          permissions['discount'] = true;
          permissions['refunds'] = false;
          permissions['stock_edit'] = false;
          permissions['view_reports'] = false;
          permissions['price_override'] = false;
          break;
        case 'barista':
          permissions['pos_sales'] = true;
          permissions['discount'] = false;
          permissions['refunds'] = false;
          permissions['stock_edit'] = false;
          permissions['view_reports'] = false;
          permissions['price_override'] = false;
          break;
        case 'stock_admin':
          permissions['pos_sales'] = false;
          permissions['discount'] = false;
          permissions['refunds'] = false;
          permissions['stock_edit'] = true;
          permissions['view_reports'] = true;
          permissions['price_override'] = false;
          break;
      }
    });
  }

  void _submitForm() {
    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'err_fill_all'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
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
        icon: const Icon(Icons.pin_rounded, color: Colors.white),
      );
      return;
    }

    if (Get.isRegistered<AdministratorController>()) {
      final adminCtrl = Get.find<AdministratorController>();
      adminCtrl.addNewUser(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        role: selectedRole,
        storeId: selectedRole == 'super_admin' ? 0 : selectedStoreId,
        pin: pinCtrl.text.trim(),
      );
    } else {
      Get.snackbar(
        'success'.tr,
        'staff_created_success'.tr,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
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
          'add_new_user'.tr,
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
              // Avatar Preview Hero
              _buildAvatarCard(context),
              const SizedBox(height: 16),

              // Section 1: Personal Identity
              _buildSectionCard(
                context: context,
                icon: Icons.person_rounded,
                title: 'account_profile'.tr,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: '${'full_name'.tr} *',
                      hintText: 'full_name_hint'.tr,
                      prefixIcon: const Icon(Icons.badge_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: '${'phone_number'.tr} *',
                      hintText: 'phone_number_hint'.tr,
                      prefixIcon: const Icon(Icons.phone_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'email_optional'.tr,
                      hintText: 'hint_email'.tr,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 2: Store Outlet & Role Hierarchy (Overflow Fixed!)
              _buildSectionCard(
                context: context,
                icon: Icons.storefront_rounded,
                title: 'store_and_role_selection'.tr,
                children: [
                  // Store Dropdown with full width constraint & ellipsis
                  GetBuilder<AdministratorController>(
                    init: Get.isRegistered<AdministratorController>()
                        ? Get.find<AdministratorController>()
                        : null,
                    builder: (adminCtrl) {
                      final Map<int, String> storeMap = {
                        0: 'platform_master_all'.tr,
                      };
                      if (adminCtrl.stores.isNotEmpty) {
                        for (final s in adminCtrl.stores) {
                          storeMap[s.id] = '${s.name} (${s.branch})';
                        }
                      }

                      final currentVal = storeMap.containsKey(selectedStoreId)
                          ? selectedStoreId
                          : (storeMap.keys.isNotEmpty ? storeMap.keys.first : 0);

                      return DropdownButtonFormField<int>(
                        initialValue: currentVal,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'store_name'.tr,
                          prefixIcon: const Icon(Icons.store_rounded),
                        ),
                        items: storeMap.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedStoreId = val);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'role_tier_label'.tr,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  _buildRoleCard(
                    roleKey: 'super_admin',
                    title: 'role_super_admin'.tr,
                    subtitle: 'role_super_admin_desc'.tr,
                    color: const Color(0xFF8E24AA),
                    icon: Icons.shield_rounded,
                  ),
                  const SizedBox(height: 8),
                  _buildRoleCard(
                    roleKey: 'store_admin',
                    title: 'role_store_admin'.tr,
                    subtitle: 'role_store_admin_desc'.tr,
                    color: primaryOrange,
                    icon: Icons.storefront_rounded,
                  ),
                  const SizedBox(height: 8),
                  _buildRoleCard(
                    roleKey: 'cashier',
                    title: 'role_cashier_user'.tr,
                    subtitle: 'role_cashier_desc'.tr,
                    color: const Color(0xFF0288D1),
                    icon: Icons.point_of_sale_rounded,
                  ),
                  const SizedBox(height: 8),
                  _buildRoleCard(
                    roleKey: 'barista',
                    title: 'role_barista_user'.tr,
                    subtitle: 'role_barista_desc'.tr,
                    color: const Color(0xFF2E7D32),
                    icon: Icons.coffee_rounded,
                  ),
                  const SizedBox(height: 8),
                  _buildRoleCard(
                    roleKey: 'stock_admin',
                    title: 'role_stock_admin_user'.tr,
                    subtitle: 'role_stock_admin_desc'.tr,
                    color: const Color(0xFF7B1FA2),
                    icon: Icons.inventory_2_rounded,
                  ),

                ],
              ),
              const SizedBox(height: 16),

              // Section 3: Credentials & Access PIN
              _buildSectionCard(
                context: context,
                icon: Icons.lock_outline_rounded,
                title: 'security_access_pin'.tr,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: passwordCtrl,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'password'.tr,
                            hintText: 'hint_min_6_chars'.tr,
                            prefixIcon: const Icon(Icons.password_rounded),
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
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: pinCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            labelText: 'four_digit_pin_label'.tr,
                            hintText: 'hint_pin'.tr,
                            prefixIcon: Icon(Icons.pin_rounded),
                            counterText: '',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final shifts = [
                        'full_time_shift'.tr,
                        'Morning Shift (06:00 AM - 02:00 PM)',
                        'Evening Shift (02:00 PM - 10:00 PM)',
                        'weekend_shift'.tr,
                      ];
                      final safeShift = shifts.contains(selectedShift) ? selectedShift : shifts.first;

                      return DropdownButtonFormField<String>(
                        initialValue: safeShift,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'work_shift_label'.tr,
                          prefixIcon: Icon(Icons.schedule_rounded),
                        ),
                        items: shifts
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedShift = val);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'account_status_label'.tr,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAccountActive ? 'active_status_desc'.tr : 'suspended_status_desc'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isAccountActive ? const Color(0xFF2E7D32) : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: isAccountActive,
                        activeTrackColor: primaryOrange,
                        onChanged: (val) => setState(() => isAccountActive = val),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 4: Granular Permissions Checklist
              _buildSectionCard(
                context: context,
                icon: Icons.verified_user_rounded,
                title: 'granular_permissions'.tr,
                children: [

                  _buildPermissionCheckbox(
                    keyName: 'pos_sales',
                    title: 'perm_pos_sales'.tr,
                    subtitle: 'perm_pos_sales_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'discount',
                    title: 'perm_discounts'.tr,
                    subtitle: 'perm_discounts_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'refunds',
                    title: 'perm_void_refund'.tr,
                    subtitle: 'perm_void_refund_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'stock_edit',
                    title: 'perm_stock_adjust'.tr,
                    subtitle: 'perm_stock_adjust_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'view_reports',
                    title: 'perm_analytics'.tr,
                    subtitle: 'perm_analytics_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'price_override',
                    title: 'perm_price_override'.tr,
                    subtitle: 'perm_price_override_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'add_new_staff',
                    title: 'perm_add_staff'.tr,
                    subtitle: 'perm_add_staff_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'edit_user_info',
                    title: 'perm_edit_staff_info'.tr,
                    subtitle: 'perm_edit_staff_info_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'edit_user_role',
                    title: 'perm_edit_staff_role'.tr,
                    subtitle: 'perm_edit_staff_role_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'edit_user_status',
                    title: 'perm_edit_staff_status'.tr,
                    subtitle: 'perm_edit_staff_status_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'edit_user_shift',
                    title: 'perm_edit_staff_shift'.tr,
                    subtitle: 'perm_edit_staff_shift_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'edit_user_phone',
                    title: 'perm_edit_staff_phone'.tr,
                    subtitle: 'perm_edit_staff_phone_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'edit_user_username',
                    title: 'perm_edit_staff_username'.tr,
                    subtitle: 'perm_edit_staff_username_desc'.tr,
                  ),
                  _buildPermissionCheckbox(
                    keyName: 'edit_user_password',
                    title: 'perm_edit_staff_password'.tr,
                    subtitle: 'perm_edit_staff_password_desc'.tr,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit Action Button
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
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  label: Text(
                    'create_account_btn'.tr,
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

  Widget _buildAvatarCard(BuildContext context) {
    final roleColor = _getRoleColor(selectedRole);

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: roleColor.withValues(alpha: 0.15),
              child: Icon(
                selectedRole == 'super_admin' ? Icons.shield_rounded : Icons.person_rounded,
                color: roleColor,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nameCtrl.text.isNotEmpty ? nameCtrl.text : 'New Platform User',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getRoleLabel(selectedRole),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: roleColor,
                letterSpacing: 0.5,
              ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryOrange, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
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

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = selectedRole == roleKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _applyRoleDefaults(roleKey),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
                color: isSelected ? color : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCheckbox({
    required String keyName,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChecked = permissions[keyName] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: CheckboxListTile(
        value: isChecked,
        activeColor: primaryOrange,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
          ),
        ),
        onChanged: (val) {
          setState(() {
            permissions[keyName] = val ?? false;
          });
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return const Color(0xFF8E24AA);
      case 'store_admin':
        return primaryOrange;
      case 'cashier':
        return const Color(0xFF0288D1);
      case 'barista':
        return const Color(0xFF2E7D32);
      case 'stock_admin':
        return const Color(0xFFF57C00);
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'super_admin':
        return 'SUPER ADMIN';
      case 'store_admin':
        return 'STORE MANAGER';
      case 'cashier':
        return 'CASHIER';
      case 'barista':
        return 'BARISTA';
      case 'stock_admin':
        return 'STOCK ADMIN';
      default:
        return role.toUpperCase();
    }
  }
}
