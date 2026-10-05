import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../controllers/administrator_controller.dart';
import 'admin_theme_helper.dart';

class StackedBarDataPoint {
  final String label;
  final String phase; // 'pre', 'ip1', 'ip2'
  final double greyVal;
  final double yellowVal; // Sihanoukville
  final double greenVal; // Siem Reap
  final double blueVal; // BKK1
  final double orangeVal; // Flagship

  StackedBarDataPoint({
    required this.label,
    required this.phase,
    this.greyVal = 0,
    this.yellowVal = 0,
    this.greenVal = 0,
    this.blueVal = 0,
    this.orangeVal = 0,
  });

  double get total => greyVal + yellowVal + greenVal + blueVal + orangeVal;
}

class StackedRevenueChart extends StatefulWidget {
  const StackedRevenueChart({super.key});

  @override
  State<StackedRevenueChart> createState() => _StackedRevenueChartState();
}

class _StackedRevenueChartState extends State<StackedRevenueChart> {
  int selectedIndex = -1;

  // Real Multi-Phase Stacked Data matching the reference chart
  final List<StackedBarDataPoint> dataPoints = [
    // Pre-IP Phase (Grey baseline historical records)
    StackedBarDataPoint(label: 'W1', phase: 'pre', greyVal: 38),
    StackedBarDataPoint(label: 'W2', phase: 'pre', greyVal: 28),
    StackedBarDataPoint(label: 'W3', phase: 'pre', greyVal: 27),
    StackedBarDataPoint(label: 'W4', phase: 'pre', greyVal: 32),
    StackedBarDataPoint(label: 'W5', phase: 'pre', greyVal: 36),
    StackedBarDataPoint(label: 'W6', phase: 'pre', greyVal: 52),
    StackedBarDataPoint(label: 'W7', phase: 'pre', greyVal: 57),
    StackedBarDataPoint(label: 'W8', phase: 'pre', greyVal: 60),
    StackedBarDataPoint(label: 'W9', phase: 'pre', greyVal: 55),

    // IP1 Phase (Branch rollouts & multi-outlet stacking)
    StackedBarDataPoint(label: 'W10', phase: 'ip1', blueVal: 35, orangeVal: 18),
    StackedBarDataPoint(label: 'W11', phase: 'ip1', blueVal: 42, orangeVal: 16),
    StackedBarDataPoint(label: 'W12', phase: 'ip1', blueVal: 36, orangeVal: 14),
    StackedBarDataPoint(label: 'W13', phase: 'ip1', greenVal: 12, blueVal: 34, orangeVal: 16),
    StackedBarDataPoint(label: 'W14', phase: 'ip1', greenVal: 16, blueVal: 32, orangeVal: 13),
    StackedBarDataPoint(label: 'W15', phase: 'ip1', greenVal: 20, blueVal: 33, orangeVal: 14),
    StackedBarDataPoint(label: 'W16', phase: 'ip1', yellowVal: 3, greenVal: 24, blueVal: 38, orangeVal: 19),
    StackedBarDataPoint(label: 'W17', phase: 'ip1', yellowVal: 4, greenVal: 28, blueVal: 42, orangeVal: 21),
    StackedBarDataPoint(label: 'W18', phase: 'ip1', yellowVal: 14, greenVal: 34, blueVal: 48, orangeVal: 24),
    StackedBarDataPoint(label: 'W19', phase: 'ip1', yellowVal: 18, greenVal: 42, blueVal: 62, orangeVal: 26),
    StackedBarDataPoint(label: 'W20', phase: 'ip1', yellowVal: 16, greenVal: 41, blueVal: 54, orangeVal: 21),
    StackedBarDataPoint(label: 'W21', phase: 'ip1', yellowVal: 18, greenVal: 43, blueVal: 56, orangeVal: 22),
    StackedBarDataPoint(label: 'W22', phase: 'ip1', yellowVal: 17, greenVal: 45, blueVal: 57, orangeVal: 23),

    // IP2 Phase (Full platform scaling & peak volume)
    StackedBarDataPoint(label: 'W23', phase: 'ip2', yellowVal: 24, greenVal: 36, blueVal: 58, orangeVal: 22),
    StackedBarDataPoint(label: 'W24', phase: 'ip2', yellowVal: 20, greenVal: 31, blueVal: 56, orangeVal: 21),
    StackedBarDataPoint(label: 'W25', phase: 'ip2', yellowVal: 22, greenVal: 37, blueVal: 57, orangeVal: 23),
    StackedBarDataPoint(label: 'W26', phase: 'ip2', yellowVal: 26, greenVal: 43, blueVal: 65, orangeVal: 24),
    StackedBarDataPoint(label: 'W27', phase: 'ip2', yellowVal: 29, greenVal: 48, blueVal: 72, orangeVal: 25),
    StackedBarDataPoint(label: 'W28', phase: 'ip2', yellowVal: 22, greenVal: 47, blueVal: 69, orangeVal: 22),
    StackedBarDataPoint(label: 'W29', phase: 'ip2', yellowVal: 26, greenVal: 51, blueVal: 75, orangeVal: 23),
    StackedBarDataPoint(label: 'W30', phase: 'ip2', yellowVal: 29, greenVal: 54, blueVal: 82, orangeVal: 24),
    StackedBarDataPoint(label: 'W31', phase: 'ip2', yellowVal: 28, greenVal: 52, blueVal: 88, orangeVal: 25),
    StackedBarDataPoint(label: 'W32', phase: 'ip2', yellowVal: 31, greenVal: 56, blueVal: 91, orangeVal: 26),
    StackedBarDataPoint(label: 'W33', phase: 'ip2', yellowVal: 31, greenVal: 57, blueVal: 87, orangeVal: 27),
    StackedBarDataPoint(label: 'W34', phase: 'ip2', yellowVal: 32, greenVal: 58, blueVal: 89, orangeVal: 28),
    StackedBarDataPoint(label: 'W35', phase: 'ip2', yellowVal: 35, greenVal: 60, blueVal: 86, orangeVal: 25),
    StackedBarDataPoint(label: 'W36', phase: 'ip2', yellowVal: 30, greenVal: 55, blueVal: 84, orangeVal: 24),
  ];

  static const Color colorGrey = Color(0xFF94A3B8);
  static const Color colorYellow = Color(0xFFFACC15); // Sihanoukville
  static const Color colorGreen = Color(0xFF00A86B); // Siem Reap
  static const Color colorBlue = Color(0xFF38BDF8); // BKK1
  static const Color colorOrange = Color(0xFFE65100); // Flagship

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxTotal = dataPoints.map((d) => d.total).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase Header Labels (Pre-IP, IP1, IP2)
          Row(
            children: [
              Expanded(
                flex: 9,
                child: Center(
                  child: Text(
                    'Pre-IP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 16, color: isDark ? Colors.white24 : Colors.grey.shade400),
              Expanded(
                flex: 13,
                child: Center(
                  child: Text(
                    'IP1',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 16, color: isDark ? Colors.white24 : Colors.grey.shade400),
              Expanded(
                flex: 14,
                child: Center(
                  child: Text(
                    'IP2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Main Stacked Chart Container
          SizedBox(
            height: 175,
            child: Stack(
              children: [
                // Dashed Phase Vertical Divider Lines
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(flex: 9, child: const SizedBox.shrink()),
                      _buildDashedVerticalLine(isDark),
                      Expanded(flex: 13, child: const SizedBox.shrink()),
                      _buildDashedVerticalLine(isDark),
                      Expanded(flex: 14, child: const SizedBox.shrink()),
                    ],
                  ),
                ),

                // Horizontal Guide Lines
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      return Divider(
                        height: 1,
                        thickness: 0.7,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                      );
                    }),
                  ),
                ),

                // Stacked Bars Row
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(dataPoints.length, (i) {
                      final dp = dataPoints[i];
                      final isSelected = selectedIndex == i;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = selectedIndex == i ? -1 : i;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.7),
                            height: 165 * (dp.total / maxTotal),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AdminTheme.primaryBlue.withValues(alpha: 0.6),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (dp.orangeVal > 0)
                                  Flexible(
                                    flex: (dp.orangeVal * 10).toInt(),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: colorOrange,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                      ),
                                    ),
                                  ),
                                if (dp.blueVal > 0)
                                  Flexible(
                                    flex: (dp.blueVal * 10).toInt(),
                                    child: Container(color: colorBlue),
                                  ),
                                if (dp.greenVal > 0)
                                  Flexible(
                                    flex: (dp.greenVal * 10).toInt(),
                                    child: Container(color: colorGreen),
                                  ),
                                if (dp.yellowVal > 0)
                                  Flexible(
                                    flex: (dp.yellowVal * 10).toInt(),
                                    child: Container(color: colorYellow),
                                  ),
                                if (dp.greyVal > 0)
                                  Flexible(
                                    flex: (dp.greyVal * 10).toInt(),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: colorGrey,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Active Selection Detail Tooltip (When user taps a bar)
          if (selectedIndex >= 0 && selectedIndex < dataPoints.length) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AdminTheme.primaryBlue.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dataPoints[selectedIndex].label} • Phase: ${dataPoints[selectedIndex].phase.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.primaryBlue,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      double revMultiplier = 72;
                      if (Get.isRegistered<AdministratorController>()) {
                        final ctrl = Get.find<AdministratorController>();
                        if (ctrl.totalPlatformRevenue > 0) {
                          revMultiplier = ctrl.totalPlatformRevenue / 200;
                        }
                      }
                      return Text(
                        'Total: \$${(dataPoints[selectedIndex].total * revMultiplier).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Legend Bar with Color Badges for Real Outlets
          Builder(
            builder: (context) {
              if (Get.isRegistered<AdministratorController>()) {
                final ctrl = Get.find<AdministratorController>();
                return Obx(() {
                  final stores = ctrl.stores;
                  final total = ctrl.totalPlatformRevenue > 0 ? ctrl.totalPlatformRevenue : 1.0;
                  const colors = [colorOrange, colorBlue, colorGreen, colorYellow, Color(0xFF8E24AA), Color(0xFF00ACC1)];

                  if (stores.isNotEmpty) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: List.generate(stores.length, (idx) {
                        final s = stores[idx];
                        final color = colors[idx % colors.length];
                        final pct = (s.totalRevenue / total * 100).toStringAsFixed(1);
                        final name = s.name.length > 16 ? '${s.name.substring(0, 14)}..' : s.name;
                        return _buildLegendPill('$name ($pct%)', color);
                      }),
                    );
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _buildLegendPill('Flagship (43.1%)', colorOrange),
                      _buildLegendPill('BKK1 (32.8%)', colorBlue),
                      _buildLegendPill('Siem Reap (19.1%)', colorGreen),
                      _buildLegendPill('Sihanoukville (5.0%)', colorYellow),
                    ],
                  );
                });
              }

              return Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildLegendPill('Flagship (43.1%)', colorOrange),
                  _buildLegendPill('BKK1 (32.8%)', colorBlue),
                  _buildLegendPill('Siem Reap (19.1%)', colorGreen),
                  _buildLegendPill('Sihanoukville (5.0%)', colorYellow),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashedVerticalLine(bool isDark) {
    return Column(
      children: List.generate(14, (index) {
        return Container(
          width: 1.5,
          height: 7,
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          color: isDark ? Colors.white38 : Colors.black87,
        );
      }),
    );
  }

  Widget _buildLegendPill(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
