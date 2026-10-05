import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../screens/account_approvals_screen.dart';
import '../../../themes/themes.dart';
import '../controllers/administrator_controller.dart';
import 'admin_theme_helper.dart';

class ApprovalsManagementTab extends StatefulWidget {
  final AdministratorController controller;
  const ApprovalsManagementTab({super.key, required this.controller});

  @override
  State<ApprovalsManagementTab> createState() => _ApprovalsManagementTabState();
}

class _ApprovalsManagementTabState extends State<ApprovalsManagementTab> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  final Set<String> selectedAppIds = {};

  AdministratorController get controller => widget.controller;

  void _toggleSelectApplication(String id) {
    setState(() {
      if (selectedAppIds.contains(id)) {
        selectedAppIds.remove(id);
      } else {
        selectedAppIds.add(id);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _selectAllFiltered() {
    final filtered = controller.filteredApplications;
    final filteredIds = filtered.map((a) => a.id).toSet();
    setState(() {
      if (selectedAppIds.containsAll(filteredIds) && filteredIds.isNotEmpty) {
        selectedAppIds.removeAll(filteredIds);
      } else {
        selectedAppIds.addAll(filteredIds);
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final filtered = controller.filteredApplications;
      final allFilteredSelected =
          filtered.isNotEmpty && filtered.every((a) => selectedAppIds.contains(a.id));

      return Stack(
        children: [
          Column(
            children: [
              // Search & Filter Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: theme.scaffoldBackgroundColor,
                child: Column(
                  children: [
                    // Search Field
                    TextField(
                      onChanged: controller.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'search_approvals_hint'.tr,
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => controller.setSearchQuery(''),
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppThemes.darkSurface : Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Chips Bar + Select All
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                AdminTheme.buildFilterChip(
                                  context: context,
                                  label: '${'pending'.tr} (${controller.pendingApprovalsCount})',
                                  isSelected:
                                      controller.selectedApprovalFilter.value == 'pending',
                                  onTap: () => controller.setApprovalFilter('pending'),
                                ),
                                const SizedBox(width: 8),
                                AdminTheme.buildFilterChip(
                                  context: context,
                                  label: '${'approved'.tr} (${controller.approvedApprovalsCount})',
                                  isSelected:
                                      controller.selectedApprovalFilter.value == 'approved',
                                  onTap: () => controller.setApprovalFilter('approved'),
                                ),
                                const SizedBox(width: 8),
                                AdminTheme.buildFilterChip(
                                  context: context,
                                  label: '${'rejected'.tr} (${controller.rejectedApprovalsCount})',
                                  isSelected:
                                      controller.selectedApprovalFilter.value == 'rejected',
                                  onTap: () => controller.setApprovalFilter('rejected'),
                                ),
                                const SizedBox(width: 8),
                                AdminTheme.buildFilterChip(
                                  context: context,
                                  label: '${'all'.tr} (${controller.totalApprovalsCount})',
                                  isSelected:
                                      controller.selectedApprovalFilter.value == 'all',
                                  onTap: () => controller.setApprovalFilter('all'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (filtered.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _selectAllFiltered,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: allFilteredSelected
                                    ? primaryBlue.withValues(alpha: 0.15)
                                    : (isDark
                                        ? AppThemes.darkSurface
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: allFilteredSelected
                                      ? primaryBlue
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    allFilteredSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 16,
                                    color: allFilteredSelected
                                        ? primaryBlue
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    allFilteredSelected ? 'deselect_all'.tr : 'select_all'.tr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: allFilteredSelected
                                          ? primaryBlue
                                          : (isDark ? Colors.white70 : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Applications List
              Expanded(
                child: controller.isRefreshing.value && controller.applications.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'no_approvals_in_list'.tr,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'new_approvals_auto_appear'.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: controller.refreshDashboardData,
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: Text('reload_data'.tr),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryBlue,
                                    side: const BorderSide(color: primaryBlue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: primaryBlue,
                            onRefresh: controller.refreshDashboardData,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              padding: EdgeInsets.fromLTRB(
                                  16, 8, 16, selectedAppIds.isNotEmpty ? 90 : 80),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final app = filtered[index];
                                final isSelected = selectedAppIds.contains(app.id);
                                return _buildApplicationCard(context, app, isSelected);
                              },
                            ),
                          ),
              ),
            ],
          ),

          // Floating Batch Actions Bar
          if (selectedAppIds.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${selectedAppIds.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'selected_count'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _batchRejectSelected,
                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                      label: Text('reject'.tr,
                          style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: _batchApproveSelected,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text('approve'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildApplicationCard(
      BuildContext context, ClientRegistrationApplication app, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (app.status) {
      case ApprovalStatus.approved:
        badgeColor = const Color(0xFF2E7D32);
        badgeText = 'approved'.tr;
        badgeIcon = Icons.check_circle_rounded;
        break;
      case ApprovalStatus.rejected:
        badgeColor = const Color(0xFFD32F2F);
        badgeText = 'rejected'.tr;
        badgeIcon = Icons.cancel_rounded;
        break;
      case ApprovalStatus.pending:
        badgeColor = const Color(0xFFFFA000);
        badgeText = 'pending'.tr;
        badgeIcon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? primaryBlue
              : (isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showApplicationDetailsModal(context, app),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Checkbox, Store Name & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleSelectApplication(app.id),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? primaryBlue
                              : (isDark ? AppThemes.darkSurface : Colors.grey.shade200),
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.circle_outlined,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.storeName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${app.branchName} • ${app.businessType}',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 12, color: badgeColor),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ],
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

                // Details: Owner Name, Phone, Email, Applied Date
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 15, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      app.ownerName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      app.phone,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (app.email.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.alternate_email_rounded,
                        size: 14,
                        color: isDark ? Colors.blue.shade300 : primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          app.email,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.blue.shade200 : primaryBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'Applied: ${app.appliedDate}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                    if (app.telegramUsername != null &&
                        app.telegramUsername!.isNotEmpty) ...[
                      const Spacer(),
                      Icon(Icons.send_rounded, size: 13, color: const Color(0xFF0288D1)),
                      const SizedBox(width: 4),
                      Text(
                        app.telegramUsername!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF0288D1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),

                // Action Buttons for Pending items
                if (app.status == ApprovalStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(app),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: Text('reject'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD32F2F),
                            side: const BorderSide(color: Color(0xFFD32F2F)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showApproveDialog(app),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text('approve'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Action links for View Info, Call & Telegram
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showApplicationDetailsModal(context, app),
                      icon: const Icon(Icons.visibility_outlined, size: 14),
                      label: Text('view_info'.tr,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    const Spacer(),
                    if (app.phone.isNotEmpty && app.phone != 'N/A')
                      TextButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse('tel:${app.phone.replaceAll(' ', '')}');
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        },
                        icon: const Icon(Icons.call_rounded, size: 14),
                        label: Text('call'.tr, style: const TextStyle(fontSize: 11.5)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    if (app.telegramUsername != null && app.telegramUsername!.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          final userClean =
                              app.telegramUsername!.replaceAll('@', '').trim();
                          final uri = Uri.parse('https://t.me/$userClean');
                          if (await canLaunchUrl(uri)) {
                            launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: Text('telegram'.tr, style: const TextStyle(fontSize: 11.5)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0288D1),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
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

  void _showApplicationDetailsModal(BuildContext context, ClientRegistrationApplication app) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (app.status) {
      case ApprovalStatus.approved:
        badgeColor = const Color(0xFF2E7D32);
        badgeText = 'approved'.tr;
        badgeIcon = Icons.check_circle_rounded;
        break;
      case ApprovalStatus.rejected:
        badgeColor = const Color(0xFFD32F2F);
        badgeText = 'rejected'.tr;
        badgeIcon = Icons.cancel_rounded;
        break;
      case ApprovalStatus.pending:
        badgeColor = const Color(0xFFFFA000);
        badgeText = 'pending'.tr;
        badgeIcon = Icons.hourglass_top_rounded;
        break;
    }

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: primaryBlue, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.storeName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        app.branchName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 13, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemes.darkSurface : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (app.phone.isNotEmpty && app.phone != 'N/A')
                            TextButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse('tel:${app.phone.replaceAll(' ', '')}');
                                if (await canLaunchUrl(uri)) launchUrl(uri);
                              },
                              icon: const Icon(Icons.call_rounded, size: 16, color: Color(0xFF2E7D32)),
                              label: Text('call'.tr, style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                            ),
                          if (app.telegramUsername != null && app.telegramUsername!.isNotEmpty)
                            TextButton.icon(
                              onPressed: () async {
                                final clean = app.telegramUsername!.replaceAll('@', '').trim();
                                final uri = Uri.parse('https://t.me/$clean');
                                if (await canLaunchUrl(uri)) {
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.send_rounded, size: 15, color: Color(0xFF0288D1)),
                              label: Text('telegram'.tr, style: const TextStyle(color: Color(0xFF0288D1), fontWeight: FontWeight.bold)),
                            ),
                          if (app.email.isNotEmpty)
                            TextButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse('mailto:${app.email}');
                                if (await canLaunchUrl(uri)) launchUrl(uri);
                              },
                              icon: const Icon(Icons.email_outlined, size: 16, color: primaryBlue),
                              label: Text('email'.tr, style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'store_owner_account'.tr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, Icons.person_outline_rounded, 'store_owner'.tr, app.ownerName),
                    _buildDetailRow(context, Icons.phone_outlined, 'phone'.tr, app.phone),
                    if (app.email.isNotEmpty)
                      _buildDetailRow(context, Icons.alternate_email_rounded, 'email'.tr, app.email),
                    if (app.telegramUsername != null && app.telegramUsername!.isNotEmpty)
                      _buildDetailRow(context, Icons.send_rounded, 'Telegram', app.telegramUsername!),
                    const SizedBox(height: 14),
                    Text(
                      'store_identity'.tr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, Icons.storefront_outlined, 'store_name'.tr, app.storeName),
                    _buildDetailRow(context, Icons.location_city_outlined, 'branch_name'.tr, app.branchName),
                    _buildDetailRow(context, Icons.category_outlined, 'business_type'.tr, app.businessType),
                    _buildDetailRow(context, Icons.place_outlined, 'store_address'.tr, app.address),
                    _buildDetailRow(context, Icons.card_membership_outlined, 'store_plan'.tr, app.plan),
                    _buildDetailRow(context, Icons.calendar_today_outlined, 'applied_date'.tr, app.appliedDate),
                    if (app.storeId != null || app.rawId != null)
                      _buildDetailRow(context, Icons.tag_rounded, 'application_id'.tr, 'STORE-${app.storeId ?? app.rawId}'),
                    if (app.rejectionReason != null && app.rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'rejection_reason_label'.tr,
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(app.rejectionReason!, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (app.status == ApprovalStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showRejectDialog(app);
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text('reject'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(color: Color(0xFFD32F2F), width: 1.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showApproveDialog(app);
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text('approve'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('close'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: primaryBlue),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(ClientRegistrationApplication app) {
    Get.defaultDialog(
      title: 'confirm_client_approval'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${'confirm_client_approval_msg'.tr} "${app.storeName}"?',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'approve_client_auto_desc'.tr,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      textConfirm: 'confirm_approve'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2E7D32),
      cancelTextColor: Colors.grey.shade700,
      onConfirm: () async {
        Get.back();
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: primaryBlue)),
          barrierDismissible: false,
        );

        final success = await controller.approveApplication(app);
        Get.back();

        if (success) {
          selectedAppIds.remove(app.id);
          HapticFeedback.mediumImpact();
          Get.snackbar(
            'approved_success'.tr,
            '${app.storeName} ${'store_activated_success_msg'.tr}',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            icon: const Icon(Icons.verified_rounded, color: Colors.white),
          );
        }
      },
    );
  }

  void _showRejectDialog(ClientRegistrationApplication app) {
    final reasonController = TextEditingController(
      text: 'reject_reason_incomplete_doc'.tr,
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'reject_application_title'.tr}: "${app.storeName}"',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'rejection_reason_label'.tr,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppThemes.darkSurface
                    : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final reason = reasonController.text.trim();
                  Get.back();
                  Get.dialog(
                    const Center(child: CircularProgressIndicator(color: primaryBlue)),
                    barrierDismissible: false,
                  );

                  final success = await controller.rejectApplication(app, reason);
                  Get.back();

                  if (success) {
                    selectedAppIds.remove(app.id);
                    HapticFeedback.mediumImpact();
                    Get.snackbar(
                      'rejected'.tr,
                      '${app.storeName} ${'application_rejected_msg'.tr}',
                      backgroundColor: const Color(0xFFD32F2F),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      margin: const EdgeInsets.all(12),
                      borderRadius: 12,
                      icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                    );
                  }
                },
                child: Text('confirm_reject_btn'.tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _batchApproveSelected() {
    final selectedApps = controller.applications
        .where((a) => selectedAppIds.contains(a.id))
        .toList();
    if (selectedApps.isEmpty) return;

    Get.defaultDialog(
      title: 'batch_approve_title'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: Text(
        '${'batch_approve_confirm_msg'.tr} (${selectedApps.length})',
        style: const TextStyle(fontSize: 13),
      ),
      textConfirm: '${'approve_all_btn'.tr} (${selectedApps.length})',
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2E7D32),
      cancelTextColor: Colors.grey.shade700,
      onConfirm: () async {
        Get.back();
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: primaryBlue)),
          barrierDismissible: false,
        );

        await controller.batchApproveApplications(selectedApps);
        Get.back();
        selectedAppIds.clear();

        HapticFeedback.heavyImpact();
        Get.snackbar(
          'success'.tr,
          '${selectedApps.length} ${'batch_approved_success'.tr}',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
      },
    );
  }

  void _batchRejectSelected() {
    final selectedApps = controller.applications
        .where((a) => selectedAppIds.contains(a.id))
        .toList();
    if (selectedApps.isEmpty) return;

    final reasonController = TextEditingController(
      text: 'reject_reason_incomplete_doc'.tr,
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'reject_batch_title'.tr} (${selectedApps.length})',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'rejection_reason_label'.tr,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppThemes.darkSurface
                    : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final reason = reasonController.text.trim();
                  Get.back();
                  Get.dialog(
                    const Center(child: CircularProgressIndicator(color: primaryBlue)),
                    barrierDismissible: false,
                  );

                  await controller.batchRejectApplications(selectedApps, reason);
                  Get.back();
                  selectedAppIds.clear();

                  HapticFeedback.mediumImpact();
                  Get.snackbar(
                    'rejected'.tr,
                    '${selectedApps.length} ${'batch_rejected_success'.tr}',
                    backgroundColor: const Color(0xFFD32F2F),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 12,
                    icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                  );
                },
                child: Text('${'confirm_batch_reject_btn'.tr} (${selectedApps.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
