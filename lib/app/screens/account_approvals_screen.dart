import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/services/api_service.dart';
import '../themes/themes.dart';

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

class ClientRegistrationApplication {
  final String id;
  final int? rawId;
  final int? storeId;
  final int? userId;
  final String storeName;
  final String branchName;
  final String ownerName;
  final String phone;
  final String email;
  final String businessType;
  final String address;
  final String plan;
  final String appliedDate;
  final String? telegramUsername;
  ApprovalStatus status;
  String? rejectionReason;
  DateTime? reviewedAt;

  ClientRegistrationApplication({
    required this.id,
    this.rawId,
    this.storeId,
    this.userId,
    required this.storeName,
    required this.branchName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.businessType,
    required this.address,
    required this.plan,
    required this.appliedDate,
    this.telegramUsername,
    this.status = ApprovalStatus.pending,
    this.rejectionReason,
    this.reviewedAt,
  });
}

class AccountApprovalsScreen extends StatefulWidget {
  const AccountApprovalsScreen({super.key});

  @override
  State<AccountApprovalsScreen> createState() => _AccountApprovalsScreenState();
}

class _AccountApprovalsScreenState extends State<AccountApprovalsScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String selectedFilter = 'pending'; // 'all', 'pending', 'approved', 'rejected'
  final searchController = TextEditingController();
  String searchQuery = '';
  bool isLoading = false;

  // Multi-selection state
  final Set<String> selectedAppIds = {};

  // Registration applications list
  final List<ClientRegistrationApplication> applications = [];

  @override
  void initState() {
    super.initState();
    fetchStoreOwnersFromApi();
  }

  Future<void> fetchStoreOwnersFromApi() async {
    try {
      setState(() => isLoading = true);
      final res = await ApiService.to.getStoreOwners();
      if (mounted) setState(() => isLoading = false);

      if (res.isSuccess && res.data != null) {
        if (mounted) {
          setState(() {
            applications.clear();
            for (var o in res.data!) {
              final idInt = o['id'] as int? ?? 0;
              final idStr = 'APP-OWNER-$idInt';
              final statusStr = (o['status'] as String?)?.toLowerCase() ?? 'pending';
              final status = statusStr == 'approved'
                  ? ApprovalStatus.approved
                  : (statusStr == 'rejected' ? ApprovalStatus.rejected : ApprovalStatus.pending);

              final app = ClientRegistrationApplication(
                id: idStr,
                rawId: idInt,
                storeId: o['store_id'] as int? ?? idInt,
                userId: o['user_id'] as int?,
                storeName: o['store_name'] ?? 'Store Tenant',
                branchName: o['store_branch'] ?? 'Main Branch',
                ownerName: o['owner_name'] ?? 'Store Owner',
                phone: o['owner_phone'] ?? 'N/A',
                email: o['owner_email'] ?? '',
                businessType: o['business_type'] ?? 'Cafe & Beverage Bar',
                address: o['address'] ?? 'Phnom Penh, Cambodia',
                plan: 'Pro Plan (\$35/mo)',
                appliedDate: o['created_at'] != null
                    ? o['created_at'].toString().split('T').first
                    : 'Recently',
                telegramUsername: o['owner_telegram'] ?? o['telegram_username'],
                status: status,
                rejectionReason: o['rejection_reason'],
              );
              applications.add(app);
            }
          });
        }
      } else if (!res.isSuccess && mounted) {
        Get.snackbar(
          'error'.tr,
          res.message ?? 'Failed to load store owner registrations',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        Get.snackbar(
          'error'.tr,
          'Error loading registrations: $e',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
        );
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ClientRegistrationApplication> get filteredApplications {
    return applications.where((app) {
      // Filter status
      if (selectedFilter == 'pending' && app.status != ApprovalStatus.pending) {
        return false;
      }
      if (selectedFilter == 'approved' && app.status != ApprovalStatus.approved) {
        return false;
      }
      if (selectedFilter == 'rejected' && app.status != ApprovalStatus.rejected) {
        return false;
      }

      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final match = app.storeName.toLowerCase().contains(q) ||
            app.branchName.toLowerCase().contains(q) ||
            app.ownerName.toLowerCase().contains(q) ||
            app.phone.contains(q) ||
            app.plan.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  int get pendingCount =>
      applications.where((a) => a.status == ApprovalStatus.pending).length;
  int get approvedCount =>
      applications.where((a) => a.status == ApprovalStatus.approved).length;
  int get rejectedCount =>
      applications.where((a) => a.status == ApprovalStatus.rejected).length;

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
    final filteredIds = filteredApplications.map((a) => a.id).toSet();
    setState(() {
      if (selectedAppIds.containsAll(filteredIds) && filteredIds.isNotEmpty) {
        selectedAppIds.removeAll(filteredIds);
      } else {
        selectedAppIds.addAll(filteredIds);
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _approveApplication(ClientRegistrationApplication app) {
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
                const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
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

        final targetId = app.storeId ?? app.rawId;
        if (targetId != null && targetId > 0) {
          Get.dialog(
            const Center(child: CircularProgressIndicator(color: primaryOrange)),
            barrierDismissible: false,
          );
          final res = await ApiService.to.approveStoreOwner(targetId);
          Get.back();

          if (!res.isSuccess) {
            Get.snackbar(
              'error'.tr,
              res.message ?? 'Approval failed',
              backgroundColor: Colors.red.shade700,
              colorText: Colors.white,
            );
            return;
          }
        }

        setState(() {
          app.status = ApprovalStatus.approved;
          app.reviewedAt = DateTime.now();
          selectedAppIds.remove(app.id);
        });

        await fetchStoreOwnersFromApi();

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
      },
    );
  }

  void _batchApproveSelected() {
    final selectedApps = applications.where((a) => selectedAppIds.contains(a.id)).toList();
    if (selectedApps.isEmpty) return;

    Get.defaultDialog(
      title: 'batch_approve_title'.tr,
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
                const Icon(Icons.playlist_add_check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${'batch_approve_confirm_msg'.tr} (${selectedApps.length})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'batch_approve_desc'.tr,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      textConfirm: '${'approve_all_btn'.tr} (${selectedApps.length})',
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2E7D32),
      cancelTextColor: Colors.grey.shade700,
      onConfirm: () async {
        Get.back();
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: primaryOrange)),
          barrierDismissible: false,
        );

        for (var app in selectedApps) {
          final targetId = app.storeId ?? app.rawId;
          if (targetId != null && targetId > 0) {
            await ApiService.to.approveStoreOwner(targetId);
          }
        }
        Get.back();

        selectedAppIds.clear();
        await fetchStoreOwnersFromApi();

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
    final selectedApps = applications.where((a) => selectedAppIds.contains(a.id)).toList();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'reject_batch_title'.tr} (${selectedApps.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent),
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
                  borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
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
                    const Center(child: CircularProgressIndicator(color: primaryOrange)),
                    barrierDismissible: false,
                  );

                  for (var app in selectedApps) {
                    final targetId = app.storeId ?? app.rawId;
                    if (targetId != null && targetId > 0) {
                      await ApiService.to.rejectStoreOwner(targetId, reason: reason);
                    }
                  }
                  Get.back();

                  selectedAppIds.clear();
                  await fetchStoreOwnersFromApi();

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
                child: Text(
                  '${'confirm_batch_reject_btn'.tr} (${selectedApps.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rejectApplication(ClientRegistrationApplication app) {
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
                Text('reject_application_title'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${'reject_application_prompt'.tr} "${app.storeName}"',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
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
                  borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
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

                  final targetId = app.storeId ?? app.rawId;
                  if (targetId != null && targetId > 0) {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator(color: primaryOrange)),
                      barrierDismissible: false,
                    );
                    final res = await ApiService.to.rejectStoreOwner(targetId, reason: reason);
                    Get.back();

                    if (!res.isSuccess) {
                      Get.snackbar(
                        'error'.tr,
                        res.message ?? 'Rejection failed',
                        backgroundColor: Colors.red.shade700,
                        colorText: Colors.white,
                      );
                      return;
                    }
                  }

                  setState(() {
                    app.status = ApprovalStatus.rejected;
                    app.rejectionReason = reason;
                    app.reviewedAt = DateTime.now();
                    selectedAppIds.remove(app.id);
                  });

                  await fetchStoreOwnersFromApi();

                  HapticFeedback.mediumImpact();
                  Get.snackbar(
                    'application_rejected_title'.tr,
                    '${app.storeName} ${'application_rejected_msg'.tr}',
                    backgroundColor: const Color(0xFFD32F2F),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 12,
                    icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                  );
                },
                child: Text('confirm_reject_btn'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDetailsModal(ClientRegistrationApplication app) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        Text(
                          app.branchName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(app.status),
                ],
              ),
              const SizedBox(height: 18),
              _buildDetailInfoTile(Icons.person_outline, 'store_owner'.tr, app.ownerName),
              _buildDetailInfoTile(Icons.phone_outlined, 'phone'.tr, app.phone),
              if (app.email.isNotEmpty)
                _buildDetailInfoTile(Icons.email_outlined, 'email'.tr, app.email),
              _buildDetailInfoTile(Icons.send_rounded, 'Telegram', app.telegramUsername?.isNotEmpty == true ? app.telegramUsername! : '@cpanha14'),
              _buildDetailInfoTile(Icons.storefront_outlined, 'business_type'.tr, app.businessType),
              _buildDetailInfoTile(Icons.location_on_outlined, 'address'.tr, app.address),
              _buildDetailInfoTile(Icons.card_membership_outlined, 'saas_plan'.tr, app.plan),
              _buildDetailInfoTile(Icons.access_time_rounded, 'applied_date'.tr, app.appliedDate),
              const SizedBox(height: 6),

              // Telegram Action Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0088CC),
                    side: const BorderSide(color: Color(0xFF0088CC), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final handle = app.telegramUsername?.isNotEmpty == true ? app.telegramUsername! : 'cpanha14';
                    final cleanHandle = handle.replaceAll('@', '').replaceAll('https://t.me/', '');
                    final tgUri = Uri.parse('tg://resolve?domain=$cleanHandle');
                    final webUri = Uri.parse('https://t.me/$cleanHandle');

                    HapticFeedback.mediumImpact();
                    Clipboard.setData(ClipboardData(text: 'https://t.me/$cleanHandle'));

                    try {
                      if (await canLaunchUrl(tgUri)) {
                        await launchUrl(tgUri, mode: LaunchMode.externalApplication);
                      } else if (await canLaunchUrl(webUri)) {
                        await launchUrl(webUri, mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(webUri, mode: LaunchMode.platformDefault);
                      }
                    } catch (_) {
                      Get.snackbar(
                        'Telegram',
                        '${'telegram_copied_msg'.tr}: @$cleanHandle',
                        backgroundColor: const Color(0xFF0088CC),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    '${'contact_telegram_btn'.tr} (${app.telegramUsername?.isNotEmpty == true ? app.telegramUsername : "@cpanha14"})',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                  ),
                ),
              ),

              if (app.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${'rejection_reason_prefix'.tr} ${app.rejectionReason}',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (app.status == ApprovalStatus.pending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD32F2F),
                          side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Get.back();
                          _rejectApplication(app);
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: Text('reject'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Get.back();
                          _approveApplication(app);
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text('approve'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailInfoTile(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFA000).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFA000)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top_rounded, color: Color(0xFFFFA000), size: 14),
              SizedBox(width: 4),
              Text(
                'pending'.tr,
                style: TextStyle(
                  color: Color(0xFFFFA000),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case ApprovalStatus.approved:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2E7D32)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 14),
              SizedBox(width: 4),
              Text(
                'approved'.tr,
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case ApprovalStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD32F2F)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_rounded, color: Color(0xFFD32F2F), size: 14),
              SizedBox(width: 4),
              Text(
                'rejected'.tr,
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = filteredApplications;
    final allFilteredSelected = filtered.isNotEmpty && filtered.every((a) => selectedAppIds.contains(a.id));

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
        title: Text('account_approvals_title'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'refresh_queue'.tr,
            onPressed: () => fetchStoreOwnersFromApi(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Summary Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemes.darkCard : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    '$pendingCount',
                    const Color(0xFFFFA000),
                    Icons.hourglass_top_rounded,
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.3)),
                Expanded(
                  child: _buildStatItem(
                    'Approved',
                    '$approvedCount',
                    const Color(0xFF2E7D32),
                    Icons.check_circle_rounded,
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.3)),
                Expanded(
                  child: _buildStatItem(
                    'Rejected',
                    '$rejectedCount',
                    const Color(0xFFD32F2F),
                    Icons.cancel_rounded,
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
                ),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => setState(() => searchQuery = val.trim()),
                style: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'search_approvals_hint'.tr,
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade500,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: primaryOrange, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Filter Segment Tabs + Select All Action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('pending', '${'pending'.tr} ($pendingCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('approved', '${'approved'.tr} ($approvedCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('rejected', '${'rejected'.tr} ($rejectedCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('all', '${'all'.tr} (${applications.length})'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _selectAllFiltered,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: allFilteredSelected
                          ? primaryOrange.withValues(alpha: 0.15)
                          : (isDark ? AppThemes.darkSurface : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: allFilteredSelected ? primaryOrange : Colors.transparent,
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
                          color: allFilteredSelected ? primaryOrange : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          allFilteredSelected ? 'deselect_all'.tr : 'select_all'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: allFilteredSelected ? primaryOrange : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Applications List with Pull-to-Refresh & Loading State
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 54,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'no_approvals_in_list'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: fetchStoreOwnersFromApi,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 4, 16, selectedAppIds.isNotEmpty ? 100 : 24),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final app = filtered[index];
                            final isSelected = selectedAppIds.contains(app.id);
                            return _buildApplicationCard(app, isSelected);
                          },
                        ),
                      ),
          ),
        ],
      ),

      // Bottom Batch Action Bar (Visible when 1 or more items are selected)
      bottomSheet: selectedAppIds.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: isDark
                    ? const Border(top: BorderSide(color: AppThemes.darkBorder))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${selectedAppIds.length} ${'items_selected'.tr}',
                        style: const TextStyle(
                          color: primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onPressed: _batchRejectSelected,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: Text('reject'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: _batchApproveSelected,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text('approve_all_btn'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = selectedFilter == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: primaryOrange,
      backgroundColor: isDark ? AppThemes.darkCard : Colors.white,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? AppThemes.darkTextPrimary : Colors.black87),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? primaryOrange
              : (isDark ? AppThemes.darkBorder : Colors.grey.shade300),
        ),
      ),
      onSelected: (_) => setState(() => selectedFilter = key),
    );
  }

  Widget _buildApplicationCard(ClientRegistrationApplication app, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF2C221D) : const Color(0xFFFFF3ED))
            : theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? primaryOrange
              : (isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryOrange.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleSelectApplication(app.id),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Selection Checkbox + Store Name & Status Badge
                Row(
                  children: [
                    // Interactive Checkbox icon
                    GestureDetector(
                      onTap: () => _toggleSelectApplication(app.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? primaryOrange
                              : (isDark ? AppThemes.darkSurface : Colors.grey.shade100),
                          border: Border.all(
                            color: isSelected ? primaryOrange : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Store Icon
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: primaryOrange,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Store Name & Branch
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.storeName,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            app.branchName,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildStatusBadge(app.status),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
                const SizedBox(height: 8),

                // Info Rows (Owner, Phone, Plan, Time)
                Row(
                  children: [
                    Icon(Icons.person_pin_circle_outlined, size: 15, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(
                      '${'store_owner'.tr}: ',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                    Text(
                      app.ownerName,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.phone_android_rounded, size: 15, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      app.phone,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: primaryOrange,
                      ),
                    ),
                  ],
                ),
                if (app.email.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.alternate_email_rounded, size: 14, color: primaryOrange),
                      const SizedBox(width: 5),
                      Text(
                        '${'email'.tr}: ',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                      Expanded(
                        child: Text(
                          app.email,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 15, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(
                      app.plan,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      app.appliedDate,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                // Action Buttons for Individual Pending Requests
                if (app.status == ApprovalStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // View Details button
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white70 : Colors.black87,
                              side: BorderSide(
                                color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => _showApplicationDetailsModal(app),
                            child: Text('view_info'.tr,
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Reject button
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD32F2F),
                              side: const BorderSide(color: Color(0xFFD32F2F)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => _rejectApplication(app),
                            icon: const Icon(Icons.close_rounded, size: 15),
                            label: Text('reject'.tr,
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Approve button
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            onPressed: () => _approveApplication(app),
                            icon: const Icon(Icons.check_rounded, size: 15),
                            label: Text('approve'.tr,
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
