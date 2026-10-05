import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class CloudBackupSnapshot {
  final String fileName;
  final String date;
  final String timeAgo;
  final String size;
  final String type; // 'Automated Cron', 'Manual Admin'
  final String checksum;
  final int recordCount;
  final bool isVerified;

  CloudBackupSnapshot({
    required this.fileName,
    required this.date,
    required this.timeAgo,
    required this.size,
    required this.type,
    required this.checksum,
    required this.recordCount,
    this.isVerified = true,
  });
}

class CloudBackupScreen extends StatefulWidget {
  const CloudBackupScreen({super.key});

  @override
  State<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends State<CloudBackupScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color backupPurple = Color(0xFF8E24AA);

  bool isBackingUp = false;
  bool isAutoBackupEnabled = true;

  final List<CloudBackupSnapshot> snapshots = [
    CloudBackupSnapshot(
      fileName: 'prod-snapshot-20260824-203000.enc',
      date: '24-Aug-2026 20:30:00',
      timeAgo: '1 hour ago',
      size: '24.8 MB',
      type: 'Automated Cron (Daily)',
      checksum: 'sha256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1f...',
      recordCount: 4280,
    ),
    CloudBackupSnapshot(
      fileName: 'prod-snapshot-20260823-233000.enc',
      date: '23-Aug-2026 23:30:00',
      timeAgo: '1 day ago',
      size: '24.1 MB',
      type: 'Automated Cron (Daily)',
      checksum: 'sha256:3a4b91802e9cf51249b6d8194a28f84cb9124a1b...',
      recordCount: 4195,
    ),
    CloudBackupSnapshot(
      fileName: 'prod-snapshot-20260822-233000.enc',
      date: '22-Aug-2026 23:30:00',
      timeAgo: '2 days ago',
      size: '23.6 MB',
      type: 'Automated Cron (Daily)',
      checksum: 'sha256:9128fba1029cba41829e81b672a9128d8419208a...',
      recordCount: 4050,
    ),
    CloudBackupSnapshot(
      fileName: 'manual-snapshot-20260821-142010.enc',
      date: '21-Aug-2026 14:20:10',
      timeAgo: '3 days ago',
      size: '22.9 MB',
      type: 'Manual Super Admin',
      checksum: 'sha256:102948bcba918239019283746192837461928374...',
      recordCount: 3920,
    ),
  ];

  Future<void> _triggerBackup() async {
    setState(() => isBackingUp = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isBackingUp = false;
      snapshots.insert(
        0,
        CloudBackupSnapshot(
          fileName: 'manual-snapshot-${DateTime.now().millisecondsSinceEpoch}.enc',
          date: '24-Aug-2026 21:40:00',
          timeAgo: 'Just now',
          size: '24.9 MB',
          type: 'Manual Super Admin',
          checksum: 'sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4...',
          recordCount: 4295,
        ),
      );
    });

    if (Get.isRegistered<AdministratorController>()) {
      Get.find<AdministratorController>().triggerManualBackup();
    }

    Get.snackbar(
      'backup_completed'.tr,
      'backup_completed_msg'.tr,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.cloud_done_rounded, color: Colors.white),
    );
  }

  void _restoreSnapshot(CloudBackupSnapshot snapshot) {
    Get.defaultDialog(
      title: 'restore_data_btn'.tr,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 42, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              '${'restore_snapshot_confirm'.tr} (${snapshot.date})',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
      textConfirm: 'restore_now'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'db_restored'.tr,
          '${'db_restored_msg'.tr} (${snapshot.fileName})',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.restore_page_rounded, color: Colors.white),
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
          'cloud_backup_title'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: isBackingUp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
            tooltip: 'run_backup_now'.tr,
            onPressed: isBackingUp ? null : _triggerBackup,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Hero Card
            _buildBackupHeroCard(context),
            const SizedBox(height: 16),

            // Automated Scheduler Card
            _buildSchedulerCard(context),
            const SizedBox(height: 16),

            // Trigger Manual Backup Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: backupPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                onPressed: isBackingUp ? null : _triggerBackup,
                icon: isBackingUp
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload_rounded, size: 22),
                label: Text(
                  isBackingUp ? 'creating_snapshot'.tr : 'backup_now_btn'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Snapshot History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_rounded, color: primaryOrange, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'snapshot_list_title'.tr,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '${snapshots.length} Snapshots',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Snapshots List
            ...snapshots.map((s) => _buildSnapshotCard(context, s)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupHeroCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2E1236), const Color(0xFF160A1C)]
              : [const Color(0xFF512DA8), const Color(0xFF311B92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backupPurple.withValues(alpha: 0.2),
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
                    Icon(Icons.cloud_done_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'DAILY BACKUP COMPLETE',
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
                '1 hour ago',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Daily Cloud Backup Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Encrypted snapshot saved to Cloud Storage (24.8 MB)',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat('Database Tables', '18 Tables OK'),
              _buildHeroStat('Database Records', '4,280 Rows'),
              _buildHeroStat('Encryption', 'AES-256-GCM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulerCard(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_rounded, color: primaryOrange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'auto_schedule_title'.tr,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Switch.adaptive(
                value: isAutoBackupEnabled,
                activeTrackColor: primaryOrange,
                onChanged: (v) => setState(() => isAutoBackupEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('backup_schedule_time_label'.tr, 'backup_schedule_time'.tr),
          _buildInfoRow('backup_location_label'.tr, 'Google Cloud Storage (Asia-Southeast 1)'),
          _buildInfoRow('backup_retention_label'.tr, 'backup_retention'.tr),
        ],
      ),
    );
  }

  Widget _buildSnapshotCard(BuildContext context, CloudBackupSnapshot item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backupPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cloud_done_rounded, color: backupPurple, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fileName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.date} (${item.timeAgo})',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.size,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Type: ${item.type} • ${item.recordCount} Records • AES-256',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'download_archive'.tr,
                      '${'download_archive_msg'.tr} (${item.fileName})',
                      backgroundColor: const Color(0xFF0288D1),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      margin: const EdgeInsets.all(12),
                      borderRadius: 12,
                      icon: const Icon(Icons.download_rounded, color: Colors.white),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: Text('download'.tr, style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () => _restoreSnapshot(item),
                  icon: const Icon(Icons.restore_rounded, size: 14),
                  label: Text('restore_data_btn'.tr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
