import 'package:flutter/material.dart';
import '../themes/themes.dart';

/// Standard modern docked bottom search bar with action button.
/// Automatically handles keyboard elevation and theme switching.
class BottomSearchDock extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;
  final String? actionTooltip;
  final Widget? actionWidget;
  final List<Widget>? inlineActions;
  final List<Widget>? leadingInlineActions;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color primaryColor;

  const BottomSearchDock({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.actionIcon,
    this.onActionTap,
    this.actionTooltip,
    this.actionWidget,
    this.inlineActions,
    this.leadingInlineActions,
    this.autofocus = false,
    this.focusNode,
    this.primaryColor = AppThemes.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(
        14,
        8,
        14,
        (isKeyboardVisible ? 8 : 14) + bottomInset,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppThemes.darkBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !isKeyboardVisible,
        child: Row(
          children: [
            // Pill Search Box
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: isDark ? AppThemes.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppThemes.darkBorder : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : Colors.grey.shade500,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    if (leadingInlineActions != null) ...[
                      ...leadingInlineActions!,
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: autofocus,
                        cursorColor: primaryColor,
                        onChanged: onChanged,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 13.5,
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (inlineActions != null) ...[
                      const SizedBox(width: 4),
                      ...inlineActions!,
                    ],
                    if (controller != null)
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller!,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: () {
                              controller?.clear();
                              onClear?.call();
                              onChanged?.call('');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Action Button
            if (actionWidget != null) ...[
              const SizedBox(width: 10),
              actionWidget!,
            ] else if (actionIcon != null) ...[
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Tooltip(
                    message: actionTooltip ?? '',
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF60A5FA),
                            primaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          actionIcon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
