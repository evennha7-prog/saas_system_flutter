import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/administrator/controllers/administrator_controller.dart';
import '../themes/themes.dart';

class BroadcastNoticeScreen extends StatefulWidget {
  const BroadcastNoticeScreen({super.key});

  @override
  State<BroadcastNoticeScreen> createState() => _BroadcastNoticeScreenState();
}

class _BroadcastNoticeScreenState extends State<BroadcastNoticeScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  final titleCtrl = TextEditingController(text: 'template_maintenance_title'.tr);
  final bodyCtrl = TextEditingController(
    text: 'សូមជម្រាបជូនលោកអ្នកគ្រប់គ្រង និងបុគ្គលិកគិតលុយគ្រប់សាខា ប្រព័ន្ធ POS នឹងដំណើរការធ្វើសមកាលកម្មទិន្នន័យ (Cloud Sync) នៅម៉ោង 11:00 យប់នេះ។ ការលក់អាចដំណើរការជាធម្មតា (Offline Mode)។',
  );

  String selectedUrgency = 'maintenance'; // 'info', 'important', 'maintenance', 'promo'
  String selectedTarget = 'all'; // 'all', 'tk', 'bkk', 'sr'
  bool showPopupOnPos = true;
  bool playChimeSound = true;
  bool pinToTopBar = true;
  bool requireAcknowledge = true;

  final List<Map<String, dynamic>> broadcastHistory = [
    {
      'title': 'ការអាប់ដេតមុខទំនិញថ្មី (New Menu Release)',
      'body': 'មុខទំនិញប្រភេទ Bakery ថ្មីចំនួន ៣ មុខត្រូវបានដាក់បញ្ចូលក្នុងប្រព័ន្ធ POS រួចរាល់។',
      'urgency': 'info',
      'target': 'All Stores (8 Terminals)',
      'timeAgo': '1 day ago',
      'status': 'Delivered',
    },
    {
      'title': 'ប្រកាសអត្រាប្តូរប្រាក់ថ្មី (\$1 = 4,100 ៛)',
      'body': 'អត្រាប្តូរប្រាក់ KHR ត្រូវបានកំណត់ស្វ័យប្រវត្តិតាមការណែនាំរបស់ធនាគារជាតិ។',
      'urgency': 'important',
      'target': 'All Stores (8 Terminals)',
      'timeAgo': '3 days ago',
      'status': 'Delivered',
    },
    {
      'title': 'បិទដំណើរការប្រព័ន្ធបណ្តោះអាសន្ន',
      'body': 'ធ្វើបច្ចុប្បន្នភាពម៉ាស៊ីនមេ Database កាលពីយប់មិញរយៈពេល ១០ នាទី។',
      'urgency': 'maintenance',
      'target': 'All Stores (8 Terminals)',
      'timeAgo': '1 week ago',
      'status': 'Delivered',
    },
  ];

  @override
  void dispose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    super.dispose();
  }

  void _applyTemplate(String title, String body, String urgency) {
    setState(() {
      titleCtrl.text = title;
      bodyCtrl.text = body;
      selectedUrgency = urgency;
    });
  }

  void _sendBroadcast() {
    if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'enter_broadcast_title_warn'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    if (Get.isRegistered<AdministratorController>()) {
      final adminCtrl = Get.find<AdministratorController>();
      adminCtrl.broadcastSystemMessage(titleCtrl.text.trim(), bodyCtrl.text.trim());
    } else {
      Get.snackbar(
        'broadcast_sent'.tr,
        'broadcast_sent_success'.tr,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }

    Get.back();
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
          'send_broadcast_now'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _sendBroadcast,
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            label: Text(
              'send_now_btn'.tr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Outlets Selector Card
            _buildTargetSelectorCard(context),
            const SizedBox(height: 16),

            // Urgency & Notice Type Card
            _buildUrgencySelectorCard(context),
            const SizedBox(height: 16),

            // Notice Composer Card
            _buildComposerCard(context),
            const SizedBox(height: 16),

            // Terminal Display Options Card
            _buildDisplayOptionsCard(context),
            const SizedBox(height: 16),

            // Real-Time Mock POS Screen Preview
            _buildLivePreviewCard(context),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getUrgencyColor(selectedUrgency),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                onPressed: _sendBroadcast,
                icon: const Icon(Icons.campaign_rounded, size: 22),
                label: Text(
                  'broadcast_to_pos_title'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Broadcast History Section
            _buildHistorySection(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelectorCard(BuildContext context) {
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
                  Icon(Icons.hub_rounded, color: primaryOrange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'target_outlets_title'.tr,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '8 Terminals Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTargetChip('all', 'all_stores_option'.tr),
                const SizedBox(width: 8),
                _buildTargetChip('tk', 'AudiCafe Flagship (TK01)'),
                const SizedBox(width: 8),
                _buildTargetChip('bkk', 'BKK1 Branch (BKK02)'),
                const SizedBox(width: 8),
                _buildTargetChip('sr', 'Siem Reap (SR03)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(String key, String label) {
    final isSelected = selectedTarget == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => selectedTarget = key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryOrange
                : (isDark ? AppThemes.darkSurface : const Color(0xFFEEF2F6)),
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildUrgencySelectorCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final urgencies = [
      {'key': 'maintenance', 'label': 'System Maintenance', 'icon': Icons.build_circle_rounded, 'color': const Color(0xFFD32F2F)},
      {'key': 'important', 'label': 'Important Notice', 'icon': Icons.warning_rounded, 'color': Colors.orange.shade800},
      {'key': 'info', 'label': 'General Info', 'icon': Icons.info_rounded, 'color': const Color(0xFF0288D1)},
      {'key': 'promo', 'label': 'Promo / Discount', 'icon': Icons.local_offer_rounded, 'color': const Color(0xFF2E7D32)},
    ];

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
              Icon(Icons.label_important_rounded, color: primaryOrange, size: 18),
              SizedBox(width: 8),
              Text(
                'notice_priority_title'.tr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: urgencies.map((u) {
              final isSelected = selectedUrgency == u['key'];
              final color = u['color'] as Color;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => selectedUrgency = u['key'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: isDark ? 0.25 : 0.12)
                              : (isDark ? AppThemes.darkSurface : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : (isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
                            width: isSelected ? 1.6 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(u['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              u['label'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerCard(BuildContext context) {
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
              Icon(Icons.edit_note_rounded, color: primaryOrange, size: 20),
              SizedBox(width: 8),
              Text(
                'message_content_title'.tr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Templates Selector
          Text(
            'quick_templates'.tr,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTemplateChip(
                  label: 'template_maintenance'.tr,
                  onTap: () => _applyTemplate(
                    'template_maintenance_title'.tr,
                    'template_maintenance_body'.tr,
                    'maintenance',
                  ),
                ),
                const SizedBox(width: 6),
                _buildTemplateChip(
                  label: 'template_exchange_rate'.tr,
                  onTap: () => _applyTemplate(
                    'template_exchange_rate_title'.tr,
                    'template_exchange_rate_body'.tr,
                    'important',
                  ),
                ),
                const SizedBox(width: 6),
                _buildTemplateChip(
                  label: 'template_new_items'.tr,
                  onTap: () => _applyTemplate(
                    'template_new_items_title'.tr,
                    'template_new_items_body'.tr,
                    'promo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title Input
          TextFormField(
            controller: titleCtrl,
            onChanged: (v) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'broadcast_title_label'.tr,
              hintText: 'broadcast_title_hint'.tr,
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),

          // Body Input
          TextFormField(
            controller: bodyCtrl,
            onChanged: (v) => setState(() {}),
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'broadcast_body_label'.tr,
              hintText: 'broadcast_body_hint'.tr,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChip({required String label, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? AppThemes.darkBorder : Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayOptionsCard(BuildContext context) {
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
              Icon(Icons.settings_suggest_rounded, color: primaryOrange, size: 18),
              SizedBox(width: 8),
              Text(
                'display_behavior_title'.tr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCheckboxRow('modal_alert_option'.tr, showPopupOnPos, (v) => setState(() => showPopupOnPos = v)),
          _buildCheckboxRow('play_alert_chime_option'.tr, playChimeSound, (v) => setState(() => playChimeSound = v)),
          _buildCheckboxRow('pin_to_bar_option'.tr, pinToTopBar, (v) => setState(() => pinToTopBar = v)),
          _buildCheckboxRow('require_ack_checkbox'.tr, requireAcknowledge, (v) => setState(() => requireAcknowledge = v)),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: primaryOrange,
            onChanged: (val) => onChanged(val ?? false),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urgencyColor = _getUrgencyColor(selectedUrgency);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.remove_red_eye_rounded, size: 16, color: primaryOrange),
              const SizedBox(width: 6),
              Text(
                'live_terminal_preview'.tr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Mock Popup Modal
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: urgencyColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: urgencyColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.campaign_rounded, color: urgencyColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        titleCtrl.text.isNotEmpty ? titleCtrl.text : 'Broadcast Title',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: urgencyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bodyCtrl.text.isNotEmpty ? bodyCtrl.text : 'Announcement message body...',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ack_button'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, color: primaryOrange, size: 18),
            SizedBox(width: 8),
            Text(
              'broadcast_history'.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: broadcastHistory.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
            ),
            itemBuilder: (context, index) {
              final item = broadcastHistory[index];
              final urgencyColor = _getUrgencyColor(item['urgency'] as String);

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.campaign_rounded, color: urgencyColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                item['timeAgo'] as String,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['body'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppThemes.darkTextSecondary : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${item['target']} • Status: ${item['status']}',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'maintenance':
        return const Color(0xFFD32F2F);
      case 'important':
        return Colors.orange.shade800;
      case 'promo':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF0288D1);
    }
  }
}
