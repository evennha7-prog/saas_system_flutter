import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../themes/themes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  late final ProfileController profileController;
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController telegramController;
  late final TextEditingController shiftController;

  String selectedRole = 'store_manager';
  int selectedAvatarIndex = 0;

  final List<IconData> avatarIcons = [
    Icons.person_rounded,
    Icons.account_circle_rounded,
    Icons.face_rounded,
    Icons.emoji_people_rounded,
    Icons.sentiment_very_satisfied_rounded,
  ];

  @override
  void initState() {
    super.initState();
    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    final currentUser = ApiService.to.currentUser.value;
    nameController = TextEditingController(
      text: currentUser?.fullName.isNotEmpty == true
          ? currentUser!.fullName
          : profileController.userName.value,
    );
    phoneController = TextEditingController(
      text: currentUser?.phoneNumber.isNotEmpty == true
          ? currentUser!.phoneNumber
          : profileController.phoneNumber.value,
    );
    emailController = TextEditingController(
      text: (currentUser?.email != null && currentUser!.email!.isNotEmpty)
          ? currentUser.email!
          : (profileController.userEmail.value.isNotEmpty
              ? profileController.userEmail.value
              : 'manager@audicafe.com'),
    );
    telegramController = TextEditingController(
      text: (currentUser?.telegramUsername != null && currentUser!.telegramUsername!.isNotEmpty)
          ? currentUser.telegramUsername!
          : (profileController.telegramUsername.value.isNotEmpty
              ? profileController.telegramUsername.value
              : '@audicafe_pos'),
    );
    shiftController = TextEditingController(
      text: currentUser?.shift ?? profileController.userShift.value,
    );
    selectedRole = currentUser?.role ?? profileController.userRole.value;
    selectedAvatarIndex = currentUser?.avatarIndex ?? profileController.avatarIndex.value;

    _fetchLatestUserProfile();
  }

  Future<void> _fetchLatestUserProfile() async {
    try {
      final res = await ApiService.to.getMe();
      if (res.isSuccess && res.data != null) {
        final u = res.data!;
        if (mounted) {
          setState(() {
            if (u.fullName.isNotEmpty) nameController.text = u.fullName;
            if (u.phoneNumber.isNotEmpty) phoneController.text = u.phoneNumber;
            if (u.email != null && u.email!.isNotEmpty) emailController.text = u.email!;
            if (u.telegramUsername != null && u.telegramUsername!.isNotEmpty) {
              telegramController.text = u.telegramUsername!;
            }
            if (u.shift != null && u.shift!.isNotEmpty) shiftController.text = u.shift!;
            selectedRole = u.role;
            selectedAvatarIndex = u.avatarIndex;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    telegramController.dispose();
    shiftController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final newName = nameController.text.trim();
    final newPhone = phoneController.text.trim();
    final newEmail = emailController.text.trim();
    final newTelegram = telegramController.text.trim();
    final newShift = shiftController.text.trim();

    if (newName.isEmpty || newPhone.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'err_fill_all'.tr,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return;
    }

    // Call live API to update profile
    await ApiService.to.updateProfile({
      'full_name': newName,
      'phone_number': newPhone,
      if (newEmail.isNotEmpty) 'email': newEmail,
      if (newTelegram.isNotEmpty) 'telegram_username': newTelegram,
      'role': selectedRole,
      'shift': newShift,
      'avatar_index': selectedAvatarIndex,
    });

    profileController.userName.value = newName;
    profileController.phoneNumber.value = newPhone;
    profileController.userEmail.value = newEmail;
    profileController.telegramUsername.value = newTelegram;
    profileController.userRole.value = selectedRole;
    profileController.userShift.value = newShift;
    profileController.avatarIndex.value = selectedAvatarIndex;


    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.cashierName.value = newName;
      homeController.phoneNumber.value = newPhone;
    }

    Get.back();
    Get.snackbar(
      'success'.tr,
      'updated_success'.tr,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }


  void _showAvatarPicker() {
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
                    'choose_icon'.tr,
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
                children: List.generate(avatarIcons.length, (index) {
                  final isSelected = selectedAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedAvatarIndex = index);
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
                        avatarIcons[index],
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? AppThemes.darkTextPrimary
                                  : Colors.black87),
                        size: 28,
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
          'edit_profile'.tr,
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
            // 1. Hero Avatar Selector Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
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
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF60A5FA), primaryBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryOrange.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          avatarIcons[selectedAvatarIndex],
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarPicker,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppThemes.darkSurface
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: primaryOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nameController.text.isNotEmpty
                        ? nameController.text
                        : 'Staff Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'tap_to_change_avatar'.tr,
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
            const SizedBox(height: 16),

            // 2. Personal Information Card
            _buildCardWrapper(
              title: 'account_profile'.tr,
              icon: Icons.person_outline_rounded,
              children: [
                _buildInputField(
                  label: 'full_name_label'.tr,
                  controller: nameController,
                  icon: Icons.badge_outlined,
                  hint: 'Prak Panha',
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'phone_number_label'.tr,
                  controller: phoneController,
                  icon: Icons.phone_outlined,
                  hint: '097 534 8338',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'email'.tr,
                  controller: emailController,
                  icon: Icons.mail_outline_rounded,
                  hint: 'panha@kitprak.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'telegram'.tr,
                  controller: telegramController,
                  icon: Icons.send_rounded,
                  hint: '@prak_panha',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Role & Shift Settings
            _buildCardWrapper(
              title: 'role'.tr,
              icon: Icons.work_outline_rounded,
              children: [
                Text(
                  'role_tier_label'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : const Color(0xFF4A5260),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        {'key': 'store_manager', 'label': 'Store Manager'},
                        {'key': 'cashier', 'label': 'Cashier'},
                        {'key': 'barista', 'label': 'Barista'},
                        {'key': 'inventory_staff', 'label': 'Inventory Staff'},
                      ].map((r) {
                        final isSelected = selectedRole == r['key'];
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(r['label']!),
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
                              setState(() => selectedRole = r['key']!),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'work_shift_label'.tr,
                  controller: shiftController,
                  icon: Icons.schedule_rounded,
                  hint: 'Morning Shift',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Save Profile CTA Button
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
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  'save_changes'.tr,
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
