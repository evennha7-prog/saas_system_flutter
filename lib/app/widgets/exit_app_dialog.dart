import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../themes/themes.dart';

class ExitAppDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String? cancelText;
  final String? confirmText;

  const ExitAppDialog({
    super.key,
    this.title,
    this.message,
    this.cancelText,
    this.confirmText,
  });

  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayTitle = title ?? 'are_you_sure'.tr;
    final displayMessage = message ?? 'exit_app_message'.tr;
    final displayCancel = cancelText ?? 'cancel'.tr;
    final displayConfirm = confirmText ?? 'exit'.tr;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: isDark ? 0 : 10,
      backgroundColor: isDark ? AppThemes.darkCard : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppThemes.darkBorder : const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              displayTitle,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Message Body
            Text(
              displayMessage,
              style: TextStyle(
                color: isDark ? AppThemes.darkTextSecondary : const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Row (Cancel / Exit)
            Row(
              children: [
                // Cancel Button (Light Grey)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppThemes.darkSurface
                            : const Color(0xFFF1F5F9),
                        foregroundColor: isDark
                            ? Colors.white70
                            : const Color(0xFF334155),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isDark
                                ? AppThemes.darkBorder
                                : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Get.back(result: false);
                      },
                      child: Text(
                        displayCancel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Exit Button (Vibrant Orange)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Get.back(result: true);
                        SystemNavigator.pop();
                      },
                      child: Text(
                        displayConfirm,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to trigger the Exit App Confirmation Dialog
Future<bool> showExitAppDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const ExitAppDialog(),
  );
  return result ?? false;
}
