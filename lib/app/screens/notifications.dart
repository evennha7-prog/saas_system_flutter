import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/themes.dart';
import 'cloud_backup_screen.dart';
import 'pos_terminals_screen.dart';
import 'security_notice_screen.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final DateTime timestamp;
  final String category; // 'sales', 'stock', 'system', 'broadcast'
  final IconData icon;
  final Color color;
  bool isRead;
  final String? routeTarget;
  final Map<String, dynamic>? metadata;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.timestamp,
    required this.category,
    required this.icon,
    required this.color,
    this.isRead = false,
    this.routeTarget,
    this.metadata,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String selectedCategory = 'all';

  final List<AppNotificationItem> notifications = [
    AppNotificationItem(
      id: 'NOTIF-01',
      title: 'ការទូទាត់ជោគជ័យ (KHQR Payment)',
      message: 'ទទួលបានការទូទាត់ \$12.50 (51,250 ៛) ពីតុ Table #04 តាមរយៈ Bakong KHQR។',
      timeAgo: '2 នាទីមុន',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      category: 'sales',
      icon: Icons.qr_code_2_rounded,
      color: const Color(0xFF2E7D32),
      isRead: false,
      metadata: {'Order': '#1048', 'Amount': '\$12.50', 'Method': 'KHQR Bakong'},
    ),
    AppNotificationItem(
      id: 'NOTIF-02',
      title: 'ការជូនដំណឹងស្តុកទាប (Low Stock Alert)',
      message: 'Coffee Beans (Arabica Dark Roast) នៅសល់ត្រឹម 2.5 kg (កម្រិតកំណត់បញ្ជាទិញ: 5.0 kg)។',
      timeAgo: '15 នាទីមុន',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      category: 'stock',
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFFF57C00),
      isRead: false,
      metadata: {'Item': 'Arabica Dark Roast', 'Remaining': '2.5 kg', 'Min': '5.0 kg'},
    ),
    AppNotificationItem(
      id: 'NOTIF-03',
      title: 'បម្រុងទុកទិន្នន័យជោគជ័យ (Cloud Backup)',
      message: 'ឯកសារបម្រុងទុកប្រចាំថ្ងៃ prod-snapshot-20260824.enc ត្រូវបានរក្សាទុកក្នុង Cloud Storage (24.8 MB)។',
      timeAgo: '1 ម៉ោងមុន',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      category: 'system',
      icon: Icons.cloud_done_rounded,
      color: const Color(0xFF8E24AA),
      isRead: false,
      routeTarget: 'backup',
      metadata: {'Archive': 'prod-snapshot-20260824.enc', 'Size': '24.8 MB'},
    ),
    AppNotificationItem(
      id: 'NOTIF-04',
      title: 'ស្ថានីយ POS បានភ្ជាប់ (POS Online)',
      message: 'BKK1 Branch Counter 01 (Sunmi V2 POS) បានតភ្ជាប់ជាមួយ WebSocket Sync Engine រួចរាល់។',
      timeAgo: '2 ម៉ោងមុន',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'system',
      icon: Icons.point_of_sale_rounded,
      color: const Color(0xFF0288D1),
      isRead: true,
      routeTarget: 'pos',
      metadata: {'Terminal': 'POS-BKK-01', 'Cashier': 'Bopha Meas'},
    ),
    AppNotificationItem(
      id: 'NOTIF-05',
      title: 'សេចក្តីប្រកាសប្រព័ន្ធ (Broadcast Notice)',
      message: 'ប្រព័ន្ធ KITLUY SaaS POS Engine ជំនាន់ v2.4 បានដាក់ឱ្យប្រើប្រាស់ជាមួយនឹងល្បឿនទូទាត់រហ័សជាងមុន។',
      timeAgo: '5 ម៉ោងមុន',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: 'broadcast',
      icon: Icons.campaign_rounded,
      color: primaryOrange,
      isRead: true,
      metadata: {'Version': 'v2.4.0', 'Priority': 'General Info'},
    ),
    AppNotificationItem(
      id: 'NOTIF-06',
      title: 'ការបិទវេនគិតលុយ (Shift Closed)',
      message: 'អ្នកគិតលុយ Prak Panha បានបិទវេនព្រឹកដោយជោគជ័យ (ចំណូលសរុប: \$342.00, សាច់ប្រាក់ជាក់ស្តែងត្រឹមត្រូវ)។',
      timeAgo: '8 ម៉ោងមុន',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      category: 'sales',
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFF2E7D32),
      isRead: true,
      metadata: {'Shift': 'Morning Shift', 'TotalSales': '\$342.00', 'Cashier': 'Prak Panha'},
    ),
    AppNotificationItem(
      id: 'NOTIF-07',
      title: 'ការផ្ទៀងផ្ទាត់សុវត្ថិភាព (Security Notice)',
      message: 'Super Admin credentials authenticated from authorized master node (192.168.1.104)។',
      timeAgo: '1 ថ្ងៃមុន',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: 'system',
      icon: Icons.verified_user_rounded,
      color: const Color(0xFFE65100),
      isRead: true,
      routeTarget: 'security',
      metadata: {'Actor': 'Super Admin', 'IP': '192.168.1.104'},
    ),
  ];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<AppNotificationItem> get filteredNotifications {
    if (selectedCategory == 'all') return notifications;
    return notifications.where((n) => n.category == selectedCategory).toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in notifications) {
        n.isRead = true;
      }
    });
    Get.snackbar(
      'success'.tr,
      'all_notifications_marked_read'.tr,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.done_all_rounded, color: Colors.white),
    );
  }

  void _clearAllNotifications() {
    Get.defaultDialog(
      title: 'delete_all_notifications_title'.tr,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
      middleText: 'delete_all_notifications_msg'.tr,
      textConfirm: 'delete_all_btn'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        setState(() {
          notifications.clear();
        });
        Get.back();
      },
    );
  }

  void _showNotificationDetail(AppNotificationItem item) {
    setState(() {
      item.isRead = true;
    });

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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
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
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (item.metadata != null && item.metadata!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.metadata!.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '${e.key}: ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                            ),
                            Text(
                              e.value.toString(),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (item.routeTarget != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      if (item.routeTarget == 'backup') {
                        Get.to(() => const CloudBackupScreen());
                      } else if (item.routeTarget == 'pos') {
                        Get.to(() => const PosTerminalsScreen());
                      } else if (item.routeTarget == 'security') {
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
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showNotificationSettings() {
    final theme = Theme.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: primaryOrange),
                    const SizedBox(width: 10),
                    Text(
                      'notification_settings_title'.tr,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
            _buildSettingSwitch('notif_sound_alert'.tr, 'notif_sound_alert_sub'.tr, true),
            _buildSettingSwitch('notif_low_stock_alert'.tr, 'notif_low_stock_alert_sub'.tr, true),
            _buildSettingSwitch('notif_system_cloud_alert'.tr, 'notif_system_cloud_alert_sub'.tr, true),
            _buildSettingSwitch('notif_telegram_bot_alert'.tr, 'notif_telegram_bot_alert_sub'.tr, true),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(String title, String subtitle, bool initialVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch.adaptive(
            value: initialVal,
            activeTrackColor: primaryOrange,
            onChanged: (v) {},
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'notifications'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: primaryOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              tooltip: 'mark_all_as_read'.tr,
              onPressed: _markAllAsRead,
            ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            tooltip: 'notification_settings'.tr,
            onPressed: _showNotificationSettings,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (val) {
              if (val == 'clear') _clearAllNotifications();
              if (val == 'read_all') _markAllAsRead();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    const Icon(Icons.done_all_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('mark_all_read'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text('delete_all_notifications_title'.tr, style: const TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: theme.scaffoldBackgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCategoryChip('all', '${'all'.tr} (${notifications.length})'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('sales', 'notif_cat_sales'.tr),
                  const SizedBox(width: 8),
                  _buildCategoryChip('stock', 'notif_cat_stock'.tr),
                  const SizedBox(width: 8),
                  _buildCategoryChip('system', 'notif_cat_system'.tr),
                  const SizedBox(width: 8),
                  _buildCategoryChip('broadcast', 'notif_cat_broadcast'.tr),
                ],
              ),
            ),
          ),

          // Notifications List / Empty State
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryOrange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_off_outlined,
                            size: 56,
                            color: primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_new_notifications'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'no_notif_in_category'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppThemes.darkTextSecondary.withValues(alpha: 0.6) : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      return _buildNotificationCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label) {
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
              fontSize: 11.5,
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

  Widget _buildNotificationCard(BuildContext context, AppNotificationItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          notifications.removeWhere((n) => n.id == item.id);
        });
        Get.snackbar(
          'delete'.tr,
          'notification_deleted'.tr,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 1),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: item.isRead
              ? theme.cardColor
              : (isDark
                  ? const Color(0xFF261D18)
                  : const Color(0xFFFFF8F4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? (isDark ? AppThemes.darkBorder : AppThemes.lightBorder)
                : primaryOrange.withValues(alpha: 0.35),
            width: item.isRead ? 1 : 1.2,
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
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _showNotificationDetail(item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Avatar
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  item.timeAgo,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppThemes.darkTextSecondary
                                        : AppThemes.lightTextSecondary,
                                  ),
                                ),
                                if (!item.isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: primaryOrange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : const Color(0xFF475569),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
