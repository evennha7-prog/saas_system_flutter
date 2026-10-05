import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/themes.dart';
import 'cloud_backup_screen.dart';
import 'new_store_registered_screen.dart';
import 'pos_terminals_screen.dart';
import 'security_notice_screen.dart';

class AuditLogItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String timestamp;
  final String actor;
  final String ipAddress;
  final String category; // 'backup', 'store', 'security', 'pos', 'staff'
  final IconData icon;
  final Color color;
  final Map<String, dynamic> metadata;

  AuditLogItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.timestamp,
    required this.actor,
    required this.ipAddress,
    required this.category,
    required this.icon,
    required this.color,
    required this.metadata,
  });
}

class SystemAuditLogsScreen extends StatefulWidget {
  const SystemAuditLogsScreen({super.key});

  @override
  State<SystemAuditLogsScreen> createState() => _SystemAuditLogsScreenState();
}

class _SystemAuditLogsScreenState extends State<SystemAuditLogsScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String searchQuery = '';
  String selectedCategory = 'all'; // 'all', 'backup', 'store', 'security', 'pos', 'staff'
  String selectedPeriod = 'all'; // 'all', 'today', 'this_week', 'this_month'

  final List<AuditLogItem> auditLogs = [
    AuditLogItem(
      id: 'AUD-9001',
      title: 'Manual Cloud Backup Triggered',
      description: 'Complete PostgreSQL & media asset archive created successfully',
      timeAgo: 'Just now',
      timestamp: '24-Aug-2026 21:30:15',
      actor: 'Super Admin (071 00 00 000)',
      ipAddress: '192.168.1.104 (Local POS Master)',
      category: 'backup',
      icon: Icons.cloud_upload_rounded,
      color: const Color(0xFF8E24AA),
      metadata: {
        'archive_size': '24.8 MB',
        'storage_bucket': 'gs://kitluy-pos-backups-asia/prod-snapshot-20260824.enc',
        'encryption': 'AES-256-GCM',
        'status': 'SUCCESS_VERIFIED',
      },
    ),
    AuditLogItem(
      id: 'AUD-9002',
      title: 'Store Activated',
      description: 'AudiCafe BKK1 Branch status changed to Activated',
      timeAgo: 'Just now',
      timestamp: '24-Aug-2026 21:28:40',
      actor: 'Super Admin (071 00 00 000)',
      ipAddress: '192.168.1.104',
      category: 'store',
      icon: Icons.check_circle_outline_rounded,
      color: const Color(0xFF2E7D32),
      metadata: {
        'store_id': 2,
        'store_name': 'AudiCafe BKK1 Branch (BKK02)',
        'previous_status': 'SUSPENDED',
        'new_status': 'ACTIVE',
      },
    ),
    AuditLogItem(
      id: 'AUD-9003',
      title: 'Store Suspended',
      description: 'AudiCafe BKK1 Branch status changed to Suspended',
      timeAgo: 'Just now',
      timestamp: '24-Aug-2026 21:25:12',
      actor: 'Super Admin (071 00 00 000)',
      ipAddress: '192.168.1.104',
      category: 'store',
      icon: Icons.pause_circle_outline_rounded,
      color: Colors.orange.shade800,
      metadata: {
        'store_id': 2,
        'store_name': 'AudiCafe BKK1 Branch (BKK02)',
        'reason': 'Scheduled network maintenance and cash drawer audit',
      },
    ),
    AuditLogItem(
      id: 'AUD-9004',
      title: 'New Store Registered',
      description: 'AudiCafe Express Sihanoukville tenant initialized on Standard Plan',
      timeAgo: '10 min ago',
      timestamp: '24-Aug-2026 21:20:00',
      actor: 'System SaaS Auto-Provisioner',
      ipAddress: '127.0.0.1 (FastAPI Core)',
      category: 'store',
      icon: Icons.storefront_rounded,
      color: const Color(0xFF43A047),
      metadata: {
        'store_id': 4,
        'store_name': 'AudiCafe Express Sihanoukville (SHV04)',
        'owner_name': 'Vicheka Keo',
        'phone': '097 888 123',
        'plan': 'Standard (\$15/mo)',
      },
    ),
    AuditLogItem(
      id: 'AUD-9005',
      title: 'POS Terminal Online',
      description: 'BKK1 Branch Counter 01 connected to WebSocket sync node',
      timeAgo: '25 min ago',
      timestamp: '24-Aug-2026 21:05:33',
      actor: 'Cashier Sophea (012 888 999)',
      ipAddress: '192.168.1.182 (Sunmi V2 POS)',
      category: 'pos',
      icon: Icons.point_of_sale_rounded,
      color: const Color(0xFF0288D1),
      metadata: {
        'terminal_id': 'POS-TK-01',
        'device_model': 'Android POS 80mm Terminal',
        'sync_protocol': 'WSS Secure Realtime',
        'queue_pending': 0,
      },
    ),
    AuditLogItem(
      id: 'AUD-9006',
      title: 'Daily Cloud Backup Complete',
      description: 'Encrypted snapshot saved to Cloud Storage (24.8 MB)',
      timeAgo: '1 hour ago',
      timestamp: '24-Aug-2026 20:30:00',
      actor: 'Cron Daemon (Automated Scheduler)',
      ipAddress: '127.0.0.1',
      category: 'backup',
      icon: Icons.cloud_done_rounded,
      color: const Color(0xFF8E24AA),
      metadata: {
        'duration': '3.42s',
        'table_count': 18,
        'records_backed_up': 4280,
      },
    ),
    AuditLogItem(
      id: 'AUD-9007',
      title: 'Security Notice',
      description: 'Super Admin credentials authenticated from authorized terminal',
      timeAgo: '2 hours ago',
      timestamp: '24-Aug-2026 19:30:10',
      actor: 'Super Admin (071 00 00 000)',
      ipAddress: '192.168.1.104',
      category: 'security',
      icon: Icons.security_rounded,
      color: primaryOrange,
      metadata: {
        'auth_method': 'Master PIN Authentication',
        'session_token': 'Bearer eyJhbGciOiJIUzI1Ni...',
        'device_fingerprint': 'POS_MASTER_KEY_001',
      },
    ),
    AuditLogItem(
      id: 'AUD-9008',
      title: 'Staff Role Updated',
      description: 'Kosal Rin permission elevated to Stock Admin for BKK1 Outlet',
      timeAgo: '5 hours ago',
      timestamp: '24-Aug-2026 16:15:00',
      actor: 'Store Admin Rithy (078 111 222)',
      ipAddress: '192.168.1.115',
      category: 'staff',
      icon: Icons.manage_accounts_rounded,
      color: const Color(0xFFF57C00),
      metadata: {
        'target_user': 'Kosal Rin',
        'role': 'stock_admin',
        'granted_permissions': ['stock_edit', 'view_reports', 'purchases'],
      },
    ),
  ];

  List<AuditLogItem> get filteredLogs {
    final q = searchQuery.trim().toLowerCase();
    return auditLogs.where((log) {
      final matchesQuery = q.isEmpty ||
          log.title.toLowerCase().contains(q) ||
          log.description.toLowerCase().contains(q) ||
          log.actor.toLowerCase().contains(q) ||
          log.ipAddress.contains(q);

      if (!matchesQuery) return false;

      if (selectedCategory != 'all' && log.category != selectedCategory) {
        return false;
      }

      return true;
    }).toList();
  }

  void _exportLogs(String format) {
    Get.snackbar(
      'export_success_title'.tr,
      '${'export_success_msg'.tr} ($format)',
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.file_download_done_rounded, color: Colors.white),
    );
  }

  void _showLogDetail(AuditLogItem log) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: log.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(log.icon, color: log.color, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Log ID: ${log.id}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('audit_date_time'.tr, log.timestamp),
              _buildDetailRow('audit_time'.tr, log.timeAgo),
              _buildDetailRow('audit_actor'.tr, log.actor),
              _buildDetailRow('audit_device_ip'.tr, log.ipAddress),
              _buildDetailRow('audit_category'.tr, log.category.toUpperCase()),
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
              const SizedBox(height: 12),
              Text(
                'audit_payload_title'.tr,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.metadata.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.key}: ',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryOrange,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value.toString(),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: log.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    if (log.category == 'backup') {
                      Get.to(() => const CloudBackupScreen());
                    } else if (log.category == 'store') {
                      Get.to(() => const NewStoreRegisteredScreen());
                    } else if (log.category == 'pos') {
                      Get.to(() => const PosTerminalsScreen());
                    } else if (log.category == 'security') {
                      Get.to(() => const SecurityNoticeScreen());
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(
                    'open_management_screen'.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          'audit_logs_title'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            tooltip: 'export_logs'.tr,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _exportLogs,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Excel (.xlsx)',
                child: Row(
                  children: [
                    const Icon(Icons.table_chart_rounded, size: 18, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 10),
                    Text('export_excel'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'PDF Document (.pdf)',
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Text('export_pdf'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'JSON Telemetry (.json)',
                child: Row(
                  children: [
                    const Icon(Icons.code_rounded, size: 18, color: Color(0xFF0288D1)),
                    const SizedBox(width: 10),
                    Text('export_json'.tr),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'search_audit_logs_hint'.tr,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => searchQuery = ''),
                          )
                        : null,
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

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'all_events_filter'.tr),
                      const SizedBox(width: 8),
                      _buildFilterChip('backup', 'Cloud Backups'),
                      const SizedBox(width: 8),
                      _buildFilterChip('store', 'Store Operations'),
                      const SizedBox(width: 8),
                      _buildFilterChip('security', 'Security Auth'),
                      const SizedBox(width: 8),
                      _buildFilterChip('pos', 'POS Terminals'),
                      const SizedBox(width: 8),
                      _buildFilterChip('staff', 'Staff Roles'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Export Quick Actions Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    label: 'export_excel'.tr,
                    icon: Icons.table_chart_rounded,
                    color: const Color(0xFF2E7D32),
                    onTap: () => _exportLogs('export_excel'.tr),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExportButton(
                    label: 'export_pdf'.tr,
                    icon: Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent,
                    onTap: () => _exportLogs('export_pdf'.tr),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExportButton(
                    label: 'export_json'.tr,
                    icon: Icons.code_rounded,
                    color: const Color(0xFF0288D1),
                    onTap: () => _exportLogs('export_json'.tr),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Audit Logs List
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.shade400),
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
                  )
                : Container(
                    margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                      ),
                    ),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredLogs.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
                      ),
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showLogDetail(log),
                            borderRadius: index == 0
                                ? const BorderRadius.vertical(top: Radius.circular(18))
                                : (index == filteredLogs.length - 1
                                    ? const BorderRadius.vertical(bottom: Radius.circular(18))
                                    : BorderRadius.zero),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: log.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(log.icon, color: log.color, size: 20),
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
                                                log.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              log.timeAgo,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? AppThemes.darkTextSecondary
                                                    : AppThemes.lightTextSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          log.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppThemes.darkTextSecondary
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Actor: ${log.actor}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            fontFamily: 'monospace',
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
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = selectedCategory == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => selectedCategory = key),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryOrange
                : (isDark ? AppThemes.darkSurface : const Color(0xFFEEF2F6)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primaryOrange : (isDark ? AppThemes.darkBorder : Colors.transparent),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppThemes.darkTextSecondary : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
