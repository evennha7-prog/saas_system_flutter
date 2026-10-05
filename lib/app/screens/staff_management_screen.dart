import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class StaffMember {
  final String id;
  String name;
  String phone;
  String role;
  String pin;
  bool isActive;
  List<String> permissions;

  StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.pin,
    this.isActive = true,
    required this.permissions,
  });
}

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  String searchQuery = '';
  final searchController = TextEditingController();
  bool isLoading = false;

  final List<StaffMember> staffList = [];

  List<StaffMember> get filteredStaffList {
    if (searchQuery.isEmpty) return staffList;
    final q = searchQuery.toLowerCase();
    return staffList.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.phone.contains(q) ||
          s.role.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchStaffFromApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchStaffFromApi() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getStaff();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          staffList.clear();
          for (var s in res.data!) {
            staffList.add(StaffMember(
              id: s.id.toString(),
              name: s.fullName,
              phone: s.phoneNumber,
              role: s.role == 'store_admin'
                  ? 'Store Manager'
                  : (s.role == 'cashier' ? 'Cashier' : s.role),
              pin: s.pinCode ?? '1234',
              isActive: s.isActive,
              permissions: s.role == 'store_admin'
                  ? ['pos_sales', 'discount', 'reports', 'refunds', 'stock_edit']
                  : ['pos_sales', 'discount'],
            ));
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showAddOrEditStaffDialog({StaffMember? existing}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final pinCtrl = TextEditingController(text: existing?.pin ?? '');
    String selectedRole = existing?.role ?? 'Cashier';

    final List<Map<String, String>> availablePermissions = [
      {'key': 'pos_sales', 'title': 'perm_pos_sales'.tr},
      {'key': 'discount', 'title': 'perm_discounts'.tr},
      {'key': 'reports', 'title': 'perm_reports'.tr},
      {'key': 'refunds', 'title': 'refunds_permission'.tr},
      {'key': 'stock_edit', 'title': 'perm_inventory'.tr},
    ];

    List<String> selectedPermissions = existing != null
        ? List<String>.from(existing.permissions)
        : ['pos_sales', 'discount'];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                        existing == null
                            ? 'add_staff'.tr
                            : '${'edit'.tr} ${'staff'.tr}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : Colors.grey,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name Field
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'full_name_label'.tr,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: primaryOrange,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone & PIN
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'phone'.tr,
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              color: primaryOrange,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppThemes.darkSurface
                                : const Color(0xFFF9FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: pinCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'pin_four_digits'.tr,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: primaryOrange,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppThemes.darkSurface
                                : const Color(0xFFF9FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Role Selector Chips
                  Text(
                    'role_colon'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'Store Manager',
                          'Cashier',
                          'Barista',
                          'Inventory',
                        ].map((r) {
                          final isSelected = selectedRole == r;
                          return ChoiceChip(
                            selected: isSelected,
                            label: Text(r),
                            selectedColor: primaryOrange,
                            backgroundColor: isDark
                                ? AppThemes.darkSurface
                                : Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? AppThemes.darkTextPrimary
                                        : Colors.black87),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) =>
                                setSheetState(() => selectedRole = r),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Permissions
                  Text(
                    'permissions_colon'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...availablePermissions.map((perm) {
                    final key = perm['key']!;
                    final isChecked = selectedPermissions.contains(key);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        perm['title']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      value: isChecked,
                      activeColor: primaryOrange,
                      onChanged: (val) {
                        setSheetState(() {
                          if (val == true) {
                            selectedPermissions.add(key);
                          } else {
                            selectedPermissions.remove(key);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),

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
                      ),
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final enteredName = nameCtrl.text.trim();
                        final enteredPhone = phoneCtrl.text.trim();
                        final enteredPin = pinCtrl.text.trim().isNotEmpty ? pinCtrl.text.trim() : '0000';

                        setState(() {
                          if (existing == null) {
                            staffList.add(
                              StaffMember(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: enteredName,
                                phone: enteredPhone,
                                role: selectedRole,
                                pin: enteredPin,
                                permissions: selectedPermissions,
                              ),
                            );
                          } else {
                            existing.name = enteredName;
                            existing.phone = enteredPhone;
                            existing.role = selectedRole;
                            existing.pin = enteredPin;
                            existing.permissions = selectedPermissions;
                          }
                        });
                        Get.back();

                        // Asynchronously persist to API
                        try {
                          if (existing == null) {
                            await ApiService.to.createStaff({
                              'full_name': enteredName,
                              'phone_number': enteredPhone,
                              'password': 'password123',
                              'pin_code': enteredPin,
                              'role': selectedRole.toLowerCase().contains('manager')
                                  ? 'store_admin'
                                  : (selectedRole.toLowerCase().contains('barista') ? 'barista' : 'cashier'),
                              'role_title': selectedRole,
                              'permissions': jsonEncode(selectedPermissions),
                            });
                          }
                        } catch (_) {}

                        Get.snackbar(
                          'success'.tr,
                          'staff_saved_msg'.tr,
                          backgroundColor: const Color(0xFF1B5E20),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      },
                      child: Text(
                        existing == null
                            ? 'save_staff'.tr
                            : 'save_changes'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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

  void _deleteStaff(StaffMember member) {
    Get.defaultDialog(
      title: 'delete'.tr,
      middleText: '${'delete_staff_confirm'.tr} (${member.name})',
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        setState(() => staffList.removeWhere((s) => s.id == member.id));
        Get.back();
        Get.snackbar('deleted_title'.tr, '${'staff_removed_msg'.tr}: ${member.name}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          'staff_management'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomSearchDock(
        controller: searchController,
        hintText: 'search_staff_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.person_add_rounded,
        actionTooltip: 'add_staff'.tr,
        onActionTap: () => _showAddOrEditStaffDialog(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            // Summary Card
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
                  _buildStatItem(
                    context,
                    'total_staff'.tr,
                    '${staffList.length}',
                    Icons.badge_outlined,
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                  ),
                  _buildStatItem(
                    context,
                    'on_duty'.tr,
                    '${staffList.where((s) => s.isActive).length}',
                    Icons.check_circle_outline,
                    color: const Color(0xFF4CAF50),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: isDark ? AppThemes.darkBorder : Colors.grey.shade200,
                  ),
                  _buildStatItem(
                    context,
                    'role'.tr,
                    '4 Roles',
                    Icons.work_outline_rounded,
                    color: primaryOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Staff Cards List
            if (filteredStaffList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'no_data'.tr,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredStaffList.map((staff) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
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
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: primaryOrange.withValues(
                            alpha: 0.12,
                          ),
                          child: Text(
                            staff.name.isNotEmpty
                                ? staff.name[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      staff.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: staff.isActive
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      staff.isActive ? 'Active' : 'Off-duty',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: staff.isActive
                                            ? const Color(0xFF2E7D32)
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${staff.role} • 📱 ${staff.phone}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppThemes.darkTextSecondary
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: staff.isActive,
                          activeThumbColor: primaryOrange,
                          onChanged: (val) =>
                              setState(() => staff.isActive = val),
                        ),
                      ],
                    ),
                    Divider(
                      height: 18,
                      color: isDark
                          ? AppThemes.darkBorder
                          : AppThemes.lightBorder,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🔐 PIN: ••••  (${staff.permissions.length} Permissions)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: isDark
                                    ? AppThemes.darkTextSecondary
                                    : Colors.blueGrey,
                              ),
                              onPressed: () =>
                                  _showAddOrEditStaffDialog(existing: staff),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteStaff(staff),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ],
),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: color ?? primaryOrange, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
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
