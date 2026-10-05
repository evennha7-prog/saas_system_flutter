import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/themes.dart';

class TelegramBotScreen extends StatefulWidget {
  const TelegramBotScreen({super.key});

  @override
  State<TelegramBotScreen> createState() => _TelegramBotScreenState();
}

class _TelegramBotScreenState extends State<TelegramBotScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;
  static const Color telegramBlue = Color(0xFF24A1DE);

  final botTokenController = TextEditingController(
    text: '7192840192:AAEj9kLmNop1028374-QrStUvW',
  );
  final chatIdController = TextEditingController(text: '-1002938491023');
  final groupNameController = TextEditingController(
    text: 'AudiCafe Sales & Management Alert',
  );

  bool isConnected = true;
  bool isTokenObscured = true;

  // Notification Preferences
  bool notifyOnEverySale = true;
  bool notifyDailySummary = true;
  bool notifyLowStock = true;
  bool notifyVoidRefund = true;
  bool notifyShiftClose = true;

  @override
  void dispose() {
    botTokenController.dispose();
    chatIdController.dispose();
    groupNameController.dispose();
    super.dispose();
  }

  void _sendTestMessage() {
    Get.defaultDialog(
      title: 'telegram_test_msg'.tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: telegramBlue.withValues(alpha: 0.3)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.telegram, color: telegramBlue, size: 20),
                SizedBox(width: 6),
                Text(
                  'AudiCafe POS Bot',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: telegramBlue,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              '🔔 [NEW SALE #INV-2026-0042]\n'
              '☕ 1x Iced Latte (\$2.25)\n'
              '🥐 1x Butter Croissant (\$1.80)\n'
              '💵 Total: \$4.05 (ABA KHQR)\n'
              '👤 Cashier: Sokha (POS 01)\n'
              '⏰ Time: Just now',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'send_test_ping'.tr,
      textCancel: 'close'.tr,
      confirmTextColor: Colors.white,
      buttonColor: telegramBlue,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'telegram_bot'.tr,
          'test_ping_sent_success'.tr,
          backgroundColor: const Color(0xFF1B5E20),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.telegram, color: Colors.white),
        );
      },
    );
  }

  void _saveBotSettings() {
    Get.snackbar(
      'success'.tr,
      'telegram_settings_saved'.tr,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
    Future.delayed(const Duration(milliseconds: 800), () => Get.back());
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
          'telegram_bot'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Connection Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2AABEE),
                    Color(0xFF229ED9),
                    Color(0xFF1B7FBD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: telegramBlue.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.telegram,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isConnected
                                    ? const Color(0xFF69F0AE)
                                    : Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConnected
                                  ? 'bot_status_connected'.tr
                                  : 'bot_status_disconnected'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@AudiCafePOS_Bot',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    onPressed: _sendTestMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Bot Configuration Card
            _buildCardWrapper(
              title: 'bot_token_config'.tr,
              icon: Icons.key_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'bot_api_token_label'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : const Color(0xFF4A5260),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: botTokenController,
                    obscureText: isTokenObscured,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.vpn_key_rounded,
                        color: telegramBlue,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isTokenObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => isTokenObscured = !isTokenObscured),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: telegramBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'chat_id_label'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : const Color(0xFF4A5260),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: chatIdController,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.tag_rounded,
                        color: telegramBlue,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: telegramBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'channel_name_label'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : const Color(0xFF4A5260),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: groupNameController,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.groups_rounded,
                        color: telegramBlue,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppThemes.darkBorder
                              : Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: telegramBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: telegramBlue,
                            side: const BorderSide(color: telegramBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _sendTestMessage,
                          icon: const Icon(Icons.send_outlined, size: 16),
                          label: Text(
                            'send_test_ping'.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Notification Options
            _buildCardWrapper(
              title: 'notifications_group'.tr,
              icon: Icons.notifications_active_rounded,
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'notify_every_sale'.tr,
                    subtitle: 'notify_every_sale_sub'.tr,
                    value: notifyOnEverySale,
                    onChanged: (val) => setState(() => notifyOnEverySale = val),
                  ),
                  Divider(
                    height: 16,
                    color: isDark
                        ? AppThemes.darkBorder
                        : AppThemes.lightBorder,
                  ),
                  _buildSwitchRow(
                    title: 'notify_daily_summary'.tr,
                    subtitle: 'notify_daily_summary_sub'.tr,
                    value: notifyDailySummary,
                    onChanged: (val) =>
                        setState(() => notifyDailySummary = val),
                  ),
                  Divider(
                    height: 16,
                    color: isDark
                        ? AppThemes.darkBorder
                        : AppThemes.lightBorder,
                  ),
                  _buildSwitchRow(
                    title: 'notify_low_stock'.tr,
                    subtitle: 'notify_low_stock_sub'.tr,
                    value: notifyLowStock,
                    onChanged: (val) => setState(() => notifyLowStock = val),
                  ),
                  Divider(
                    height: 16,
                    color: isDark
                        ? AppThemes.darkBorder
                        : AppThemes.lightBorder,
                  ),
                  _buildSwitchRow(
                    title: 'notify_void_refund'.tr,
                    subtitle: 'notify_void_refund_sub'.tr,
                    value: notifyVoidRefund,
                    onChanged: (val) => setState(() => notifyVoidRefund = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: primaryOrange.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _saveBotSettings,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  'save_telegram_config'.tr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: isDark
            ? Border.all(color: AppThemes.darkBorder)
            : Border.all(color: AppThemes.lightBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: telegramBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: telegramBlue,
        ),
      ],
    );
  }
}
