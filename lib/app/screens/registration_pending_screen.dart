import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/services/api_service.dart';
import '../routes/app_pages.dart';
import '../themes/themes.dart';

class RegistrationPendingScreen extends StatefulWidget {
  final String storeName;
  final String ownerName;
  final String phone;
  final String email;
  final String businessType;
  final String branch;
  final String address;
  final String submittedAt;

  const RegistrationPendingScreen({
    super.key,
    required this.storeName,
    required this.ownerName,
    required this.phone,
    this.email = '',
    this.businessType = 'Cafe & Beverage',
    this.branch = 'Main Branch',
    this.address = 'Phnom Penh, Cambodia',
    this.submittedAt = 'Just now',
  });

  @override
  State<RegistrationPendingScreen> createState() =>
      _RegistrationPendingScreenState();
}

class _RegistrationPendingScreenState extends State<RegistrationPendingScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color pendingAmber = Color(0xFFFFA000);
  static const Color approvedGreen = Color(0xFF2E7D32);
  static const Color rejectedRed = Color(0xFFD32F2F);

  String currentStatus = 'pending'; // 'pending', 'approved', 'rejected'
  String? rejectionReason;
  bool isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _checkLiveStatus(silent: true);
  }

  Future<void> _checkLiveStatus({bool silent = false}) async {
    if (!silent) {
      setState(() => isCheckingStatus = true);
    }

    try {
      final res = await ApiService.to.checkRegistrationStatus(widget.phone);
      if (res.isSuccess && res.data != null) {
        final status = (res.data!['status'] as String?)?.toLowerCase() ?? 'pending';
        final reason = res.data!['rejection_reason'] as String?;
        setState(() {
          currentStatus = status;
          rejectionReason = reason;
        });

        if (!silent) {
          HapticFeedback.lightImpact();
          if (status == 'approved') {
            Get.snackbar(
              'status_approved_label'.tr,
              'registration_pending_notice'.tr,
              backgroundColor: approvedGreen,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
            );
          } else if (status == 'rejected') {
            Get.snackbar(
              'status_rejected_label'.tr,
              reason ?? 'status_rejected_label'.tr,
              backgroundColor: rejectedRed,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              icon: const Icon(Icons.cancel_rounded, color: Colors.white),
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
            );
          } else {
            Get.snackbar(
              'status_pending_label'.tr,
              'registration_pending_subtitle'.tr,
              backgroundColor: pendingAmber,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              icon: const Icon(Icons.hourglass_top_rounded, color: Colors.white),
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
            );
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted && !silent) {
        setState(() => isCheckingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Get.offAllNamed(Routes.LOGIN),
        ),
        title: Text(
          'registration_pending_title'.tr,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // Status Hero Card
                  _buildStatusHeroCard(context, isDark),
                  const SizedBox(height: 16),

                  // Telegram Admin Contact Card
                  _buildTelegramAdminCard(context, isDark),
                  const SizedBox(height: 16),

                  // Notice Card
                  _buildNoticeCard(context, isDark),
                  const SizedBox(height: 16),

                  // Application Receipt Details
                  _buildApplicationReceipt(context, isDark),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeroCard(BuildContext context, bool isDark) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    if (currentStatus == 'approved') {
      statusColor = approvedGreen;
      statusIcon = Icons.verified_rounded;
      statusTitle = 'status_approved_label'.tr;
      statusSubtitle = 'registration_pending_notice'.tr;
    } else if (currentStatus == 'rejected') {
      statusColor = rejectedRed;
      statusIcon = Icons.cancel_rounded;
      statusTitle = 'status_rejected_label'.tr;
      statusSubtitle = 'status_rejected_label'.tr;
    } else {
      statusColor = pendingAmber;
      statusIcon = Icons.hourglass_top_rounded;
      statusTitle = 'status_pending_label'.tr;
      statusSubtitle = 'registration_pending_subtitle'.tr;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.14),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(statusIcon, color: statusColor, size: 38),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              statusTitle,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.storeName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            statusSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
            ),
          ),
          if (rejectionReason != null && currentStatus == 'rejected') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rejectedRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rejectedRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: rejectedRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'rejection_reason_label'.tr}: $rejectionReason',
                      style: const TextStyle(
                        color: rejectedRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelegramAdminCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0088CC).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0088CC).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  color: Color(0xFF0088CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'contact_admin'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Telegram: @cpanha14',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0088CC),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${'fast_approval_telegram_hint'.tr} (${widget.phone} • ${widget.storeName})',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: isDark ? AppThemes.darkTextSecondary : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0088CC),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFF0088CC).withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _openTelegram('cpanha14'),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                'contact_admin'.tr,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTelegram(String username) async {
    final cleanHandle = username.replaceAll('@', '').replaceAll('https://t.me/', '');
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
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
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
    }
  }

  Widget _buildNoticeCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: primaryOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'registration_pending_notice'.tr,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationReceipt(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded,
                  color: primaryOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                'application_id'.tr,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
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
          _buildInfoRow('store_name_field'.tr, widget.storeName, context, isDark),
          _buildInfoRow('full_name'.tr, widget.ownerName, context, isDark),
          _buildInfoRow('phone_number'.tr, widget.phone, context, isDark),
          if (widget.email.isNotEmpty)
            _buildInfoRow('email_optional'.tr, widget.email, context, isDark),
          _buildInfoRow('business_type_label'.tr, widget.businessType, context, isDark),
          _buildInfoRow('store_branch_label'.tr, widget.branch, context, isDark),
          _buildInfoRow('applied_date'.tr, widget.submittedAt, context, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    BuildContext context,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (currentStatus == 'approved') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: approvedGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              onPressed: () => Get.offAllNamed(Routes.LOGIN),
              icon: const Icon(Icons.login_rounded, size: 20),
              label: Text(
                'login_now'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Live Check Status Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
            onPressed: isCheckingStatus ? null : () => _checkLiveStatus(),
            icon: isCheckingStatus
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              'check_status_btn'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back to Login Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryOrange,
              side: const BorderSide(color: primaryOrange, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Get.offAllNamed(Routes.LOGIN),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(
              'back_to_login_btn'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
        ),
      ],
    );
  }
}
