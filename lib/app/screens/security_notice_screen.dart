import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/themes.dart';

class SecurityEventItem {
  final String title;
  final String description;
  final String timeAgo;
  final String timestamp;
  final String actor;
  final String ip;
  final String severity; // 'info', 'warning', 'critical', 'success'
  final IconData icon;

  SecurityEventItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.timestamp,
    required this.actor,
    required this.ip,
    required this.severity,
    required this.icon,
  });
}

class SecurityNoticeScreen extends StatefulWidget {
  const SecurityNoticeScreen({super.key});

  @override
  State<SecurityNoticeScreen> createState() => _SecurityNoticeScreenState();
}

class _SecurityNoticeScreenState extends State<SecurityNoticeScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String currentMasterPin = '9999';
  bool isIpWhitelistActive = true;
  bool isAutoLockoutEnabled = true;

  final List<SecurityEventItem> securityEvents = [
    SecurityEventItem(
      title: 'sec_event_super_admin_auth'.tr,
      description: 'sec_event_super_admin_auth_desc'.tr,
      timeAgo: '2 hours ago',
      timestamp: '24-Aug-2026 19:30:10',
      actor: 'Platform Owner (071 00 00 000)',
      ip: '192.168.1.104 (Master Terminal Node)',
      severity: 'success',
      icon: Icons.verified_user_rounded,
    ),
    SecurityEventItem(
      title: 'sec_event_mgr_pwd_updated'.tr,
      description: 'sec_event_mgr_pwd_updated_desc'.tr,
      timeAgo: '3 hours ago',
      timestamp: '24-Aug-2026 18:40:22',
      actor: 'Prak Panha (071 93 93 991)',
      ip: '192.168.1.104',
      severity: 'info',
      icon: Icons.lock_reset_rounded,
    ),
    SecurityEventItem(
      title: 'sec_event_failed_pin_warning'.tr,
      description: 'sec_event_failed_pin_warning_desc'.tr,
      timeAgo: 'Yesterday at 04:15 PM',
      timestamp: '23-Aug-2026 16:15:00',
      actor: 'POS-BKK-02 Terminal',
      ip: '192.168.1.185',
      severity: 'warning',
      icon: Icons.gpp_maybe_rounded,
    ),
    SecurityEventItem(
      title: 'sec_event_hardware_paired'.tr,
      description: 'sec_event_hardware_paired_desc'.tr,
      timeAgo: '2 days ago',
      timestamp: '22-Aug-2026 11:20:00',
      actor: 'Vicheka Keo (097 888 123)',
      ip: '192.168.1.140',
      severity: 'info',
      icon: Icons.devices_other_rounded,
    ),
    SecurityEventItem(
      title: 'sec_event_session_revoked'.tr,
      description: 'sec_event_session_revoked_desc'.tr,
      timeAgo: '3 days ago',
      timestamp: '21-Aug-2026 09:15:30',
      actor: 'Platform Owner (071 00 00 000)',
      ip: '192.168.1.104',
      severity: 'info',
      icon: Icons.phonelink_erase_rounded,
    ),
  ];

  void _showChangeMasterPinDialog() {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'change_master_pin_title'.tr,
      titleStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            TextField(
              controller: oldPinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'current_pin_label'.tr,
                hintText: 'hint_pin'.tr,
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'new_pin_label'.tr,
                hintText: 'hint_pin'.tr,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'save_new_pin'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: primaryOrange,
      onConfirm: () {
        if (newPinCtrl.text.trim().length == 4) {
          setState(() => currentMasterPin = newPinCtrl.text.trim());
          Get.back();
          Get.snackbar(
            'success'.tr,
            'pin_saved_success'.tr.isNotEmpty ? 'pin_saved_success'.tr : 'Super Admin Master PIN changed successfully.',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
        }
      },
    );
  }

  void _revokeAllSessions() {
    Get.defaultDialog(
      title: 'revoke_all_sessions_title'.tr,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'revoke_all_sessions_confirm'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
      ),
      textConfirm: 'revoke_all_sessions'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'sessions_revoked'.tr,
          'sessions_revoked_msg'.tr,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      },
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
          'security_notice_title'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Colors.white),
            tooltip: 'security_policies'.tr,
            onPressed: () {
              Get.snackbar(
                'security_shield_active'.tr,
                'security_shield_msg'.tr,
                backgroundColor: const Color(0xFF2E7D32),
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Status Hero Banner
            _buildSecurityHeroCard(context),
            const SizedBox(height: 16),

            // Master Security Policies Card
            _buildSecurityPoliciesCard(context),
            const SizedBox(height: 16),

            // Quick Security Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryOrange,
                      side: const BorderSide(color: primaryOrange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _showChangeMasterPinDialog,
                    icon: const Icon(Icons.pin_rounded, size: 18),
                    label: Text('change_master_pin_btn'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _revokeAllSessions,
                    icon: const Icon(Icons.lock_person_rounded, size: 18),
                    label: Text('revoke_all_sessions_title'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Security Events Audit Trail
            Row(
              children: [
                Icon(Icons.history_edu_rounded, color: primaryOrange, size: 18),
                SizedBox(width: 8),
                Text(
                  'recent_security_logs'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Events List
            ...securityEvents.map((e) => _buildSecurityEventCard(context, e)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeroCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2B1B0F), const Color(0xFF140D07)]
              : [const Color(0xFFE65100), const Color(0xFFBF360C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'SYSTEM INTEGRITY SECURE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '2 hours ago',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Security Notice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Super Admin credentials authenticated from authorized terminal',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'actor_label'.tr}: Super Admin', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('${'ip_label'.tr}: 192.168.1.104', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text('${'status_label'.tr}: SUCCESS', style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityPoliciesCard(BuildContext context) {
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
              Icon(Icons.policy_rounded, color: primaryOrange, size: 18),
              SizedBox(width: 8),
              Text(
                'security_policies_title'.tr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPolicyRow('Master Super Admin PIN', '•••• ($currentMasterPin)'),
          _buildPolicyRow('IP Whitelist Protection', '192.168.1.0/24 (Enabled)'),
          _buildPolicyRow('Max Failed PIN Lockout', '3 Attempts (5 Min Lock)'),
          _buildPolicyRow('Token Session Expiry', '30 Days Auto-Rotate'),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityEventCard(BuildContext context, SecurityEventItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getSeverityColor(item.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        item.timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Actor: ${item.actor} • ${item.ip}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'warning':
        return Colors.orange.shade800;
      case 'critical':
        return Colors.redAccent;
      case 'success':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF0288D1);
    }
  }
}
