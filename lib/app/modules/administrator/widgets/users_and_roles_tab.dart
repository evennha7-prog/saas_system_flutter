import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/themes.dart';
import '../controllers/administrator_controller.dart';
import 'admin_theme_helper.dart';

class UsersAndRolesTab extends StatelessWidget {
  final AdministratorController controller;
  const UsersAndRolesTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              TextField(
                onChanged: controller.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'search_users_hint'.tr,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => controller.setSearchQuery(''),
                          )
                        : const SizedBox.shrink(),
                  ),
                  filled: true,
                  fillColor: isDark ? AppThemes.darkSurface : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Obx(
                  () => Row(
                    children: [
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'all'.tr,
                        isSelected: controller.selectedUserRoleFilter.value == 'all',
                        onTap: () => controller.setUserRoleFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'role_super_admin'.tr,
                        isSelected: controller.selectedUserRoleFilter.value == 'super_admin',
                        onTap: () => controller.setUserRoleFilter('super_admin'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'role_store_admin'.tr,
                        isSelected: controller.selectedUserRoleFilter.value == 'store_admin',
                        onTap: () => controller.setUserRoleFilter('store_admin'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'role_cashier'.tr,
                        isSelected: controller.selectedUserRoleFilter.value == 'cashier',
                        onTap: () => controller.setUserRoleFilter('cashier'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'role_barista'.tr,
                        isSelected: controller.selectedUserRoleFilter.value == 'barista',
                        onTap: () => controller.setUserRoleFilter('barista'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'role_stock_admin'.tr,
                        isSelected: controller.selectedUserRoleFilter.value == 'stock_admin',
                        onTap: () => controller.setUserRoleFilter('stock_admin'),
                      ),
                    ],
                  ),

                ),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: Obx(() {
            final list = controller.filteredUsers;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'no_data'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final user = list[index];
                return _buildPlatformUserCard(context, user);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPlatformUserCard(BuildContext context, PlatformStaffUser user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final roleColor = AdminTheme.getRoleColor(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: roleColor.withValues(alpha: 0.15),
              child: Icon(
                user.role == 'super_admin' ? Icons.shield_rounded : Icons.person_rounded,
                color: roleColor,
                size: 24,
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
                          user.name,
                          style: TextStyle(
                            fontSize: 14,
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
                          color: roleColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AdminTheme.getRoleLabel(user.role),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.phone} • ${user.storeName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : AppThemes.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PIN: ${user.pin}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: user.isActive,
              activeTrackColor: AdminTheme.primaryBlue,
              onChanged: (val) => controller.toggleUserStatus(user.id),
            ),
          ],
        ),
      ),
    );
  }
}
