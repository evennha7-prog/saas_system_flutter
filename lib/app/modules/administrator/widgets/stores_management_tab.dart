import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screens/new_store_registered_screen.dart';
import '../../../themes/themes.dart';
import '../controllers/administrator_controller.dart';
import 'admin_theme_helper.dart';

class StoresManagementTab extends StatelessWidget {
  final AdministratorController controller;
  const StoresManagementTab({super.key, required this.controller});

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
                  hintText: 'search_stores_hint'.tr,
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
                        label: 'filter_all_stores'.tr,
                        isSelected: controller.selectedStoreFilter.value == 'all',
                        onTap: () => controller.setStoreFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'filter_active'.tr,
                        isSelected: controller.selectedStoreFilter.value == 'active',
                        onTap: () => controller.setStoreFilter('active'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'filter_inactive'.tr,
                        isSelected: controller.selectedStoreFilter.value == 'inactive',
                        onTap: () => controller.setStoreFilter('inactive'),
                      ),
                      const SizedBox(width: 8),
                      AdminTheme.buildFilterChip(
                        context: context,
                        label: 'filter_high_revenue'.tr,
                        isSelected: controller.selectedStoreFilter.value == 'high_revenue',
                        onTap: () => controller.setStoreFilter('high_revenue'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stores List
        Expanded(
          child: Obx(() {
            final list = controller.filteredStores;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey.shade400),
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
                final store = list[index];
                return _buildStoreTenantCard(context, store);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStoreTenantCard(BuildContext context, StoreTenant store) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: store.isActive
              ? (isDark ? AppThemes.darkBorder : AppThemes.lightBorder)
              : Colors.redAccent.withValues(alpha: 0.4),
          width: store.isActive ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => Get.to(() => NewStoreRegisteredScreen(storeId: store.id)),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: store.isActive
                            ? AdminTheme.primaryBlue.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        color: store.isActive ? AdminTheme.primaryBlue : Colors.grey,
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
                                  store.name,
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
                                  color: AdminTheme.getPlanColor(store.plan).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  store.plan.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AdminTheme.getPlanColor(store.plan),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            store.branch,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: isDark ? AppThemes.darkTextSecondary : Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (val) {
                        if (val == 'details') {
                          Get.to(() => NewStoreRegisteredScreen(storeId: store.id));
                        } else if (val == 'toggle') {
                          controller.toggleStoreStatus(store.id);
                        } else if (val == 'delete') {
                          _showDeleteConfirmDialog(
                            context: context,
                            title: 'delete_store'.tr,
                            message: 'delete_store_confirm'.tr,
                            onConfirm: () => controller.deleteStore(store.id),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 18),
                              const SizedBox(width: 10),
                              Text('store_details'.tr),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                store.isActive
                                    ? Icons.pause_circle_outline_rounded
                                    : Icons.play_circle_outline_rounded,
                                size: 18,
                                color: store.isActive ? Colors.orange : Colors.green,
                              ),
                              const SizedBox(width: 10),
                              Text(store.isActive ? 'deactivate_store'.tr : 'activate_store'.tr),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                              const SizedBox(width: 10),
                              Text('delete'.tr, style: const TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${store.ownerName} (${store.phone})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        store.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AdminTheme.buildBadge(
                          label: '\$${store.totalRevenue.toStringAsFixed(2)}',
                          icon: Icons.payments_outlined,
                          color: const Color(0xFF2E7D32),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        AdminTheme.buildBadge(
                          label: '${store.staffCount} ${'persons'.tr}',
                          icon: Icons.badge_outlined,
                          color: const Color(0xFF0288D1),
                          isDark: isDark,
                        ),

                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          store.isActive ? 'Active' : 'Suspended',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: store.isActive ? const Color(0xFF4CAF50) : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Switch.adaptive(
                          value: store.isActive,
                          activeTrackColor: AdminTheme.primaryBlue,
                          onChanged: (val) => controller.toggleStoreStatus(store.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
      middleText: message,
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}
