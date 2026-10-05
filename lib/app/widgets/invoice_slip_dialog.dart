library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/sale_model.dart';
import '../modules/list_sales/controllers/list_sales_controller.dart';
import '../themes/themes.dart';

class InvoiceSlipData {
  final String invoiceNo;
  final String transactionType;
  final String receiverName;
  final String? receiverInitials;
  final double amount;
  final String currencySymbol;
  final String paidFrom;
  final String accountNo;
  final double debitAmount;
  final String referenceNo;
  final DateTime date;
  final String paymentMethod;
  final List<SaleItemModel>? items;

  InvoiceSlipData({
    required this.invoiceNo,
    this.transactionType = 'Transaction KHQR to',
    required this.receiverName,
    this.receiverInitials,
    required this.amount,
    this.currencySymbol = '៛',
    required this.paidFrom,
    required this.accountNo,
    required this.debitAmount,
    required this.referenceNo,
    required this.date,
    this.paymentMethod = 'KHQR',
    this.items,
  });

  String get initials {
    if (receiverInitials != null && receiverInitials!.isNotEmpty) {
      return receiverInitials!;
    }
    final parts = receiverName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (receiverName.isNotEmpty) {
      return receiverName.substring(0, receiverName.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'SD';
  }

  factory InvoiceSlipData.fromSaleRecord(SaleRecord record, {String? storeName, String? cashierName}) {
    final now = record.fullDate ?? DateTime.now();
    final isKhqr = record.paymentMethod.toLowerCase().contains('khqr');
    return InvoiceSlipData(
      invoiceNo: record.invoiceNo,
      transactionType: isKhqr ? 'Transaction KHQR to' : 'sale_invoice'.tr,
      receiverName: storeName?.isNotEmpty == true
          ? storeName!
          : (cashierName?.isNotEmpty == true ? cashierName! : 'SONG DANAVUDTH'),
      amount: record.amount,
      currencySymbol: record.amount > 1000 ? '៛' : '\$',
      paidFrom: record.customer.startsWith('general_') ? 'Pha Sophal' : record.customer,
      accountNo: isKhqr ? '000***214 (KHR)' : 'payment_cash'.tr,
      debitAmount: record.amount,
      referenceNo: record.invoiceNo.replaceAll('-', ''),
      date: now,
      paymentMethod: record.paymentMethod,
    );
  }

  factory InvoiceSlipData.fromSaleModel(SaleModel sale, {String? storeName}) {
    final isKhqr = sale.paymentMethod.toUpperCase().contains('KHQR');
    return InvoiceSlipData(
      invoiceNo: sale.invoiceNumber,
      transactionType: isKhqr ? 'Transaction KHQR to' : 'sale_invoice'.tr,
      receiverName: storeName?.isNotEmpty == true
          ? storeName!
          : (sale.cashierName?.isNotEmpty == true ? sale.cashierName! : 'SONG DANAVUDTH'),
      amount: sale.finalAmount,
      currencySymbol: sale.finalAmount > 1000 ? '៛' : '\$',
      paidFrom: sale.customerName?.isNotEmpty == true ? sale.customerName! : 'Pha Sophal',
      accountNo: isKhqr ? '000***214 (KHR)' : 'payment_cash'.tr,
      debitAmount: sale.finalAmount,
      referenceNo: sale.invoiceNumber.replaceAll('-', ''),
      date: sale.createdAt,
      paymentMethod: sale.paymentMethod,
      items: sale.items,
    );
  }
}

class InvoiceSlipDialog extends StatelessWidget {
  final InvoiceSlipData data;

  const InvoiceSlipDialog({super.key, required this.data});

  static Future<void> show(
    BuildContext context, {
    required InvoiceSlipData data,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'InvoiceSlip',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => InvoiceSlipDialog(data: data),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  static String _formatNumber(num value, {bool withDecimals = false}) {
    final str = withDecimals ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
    final parts = str.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    final buffer = StringBuffer();
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
      count++;
      if (count % 3 == 0 && i > 0 && integerPart[i - 1] != '-') {
        buffer.write(',');
      }
    }
    final formattedInt = buffer.toString().split('').reversed.join('');
    return '$formattedInt$decimalPart';
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year;
    final hourInt = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year | $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(data.date);

    final isKhr = data.currencySymbol == '៛' || data.amount > 1000;
    final formattedAmount = isKhr
        ? '${_formatNumber(data.amount, withDecimals: true)} ៛'
        : '\$${_formatNumber(data.amount, withDecimals: true)}';

    final formattedDebit = isKhr
        ? '-${_formatNumber(data.debitAmount, withDecimals: false)} KHR'
        : '-\$${_formatNumber(data.debitAmount, withDecimals: true)}';

    final formattedTotal = isKhr
        ? '${_formatNumber(data.amount, withDecimals: false)} KHR'
        : '\$${_formatNumber(data.amount, withDecimals: true)}';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ticket Slip
              Container(
                constraints: const BoxConstraints(maxWidth: 360),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipPath(
                  clipper: TicketSlipClipper(punchPosition: 145, punchRadius: 12),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Section (Avatar + Recipient + Big Red Amount)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Red-Orange Circular Initials Badge
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE54335),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x33E54335),
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      data.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data.transactionType,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Color(0xFF4A5568),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          data.receiverName.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1E293B),
                                            letterSpacing: 0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Big Highlight Amount in Crimson Red
                              Text(
                                formattedAmount,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFD32F2F),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dashed divider line across the notch cutouts
                        SizedBox(
                          height: 16,
                          child: CustomPaint(
                            size: const Size(double.infinity, 1),
                            painter: DashedDividerPainter(
                              color: const Color(0xFFCBD5E1),
                              dashWidth: 4,
                              dashSpace: 3,
                            ),
                          ),
                        ),

                        // Body Details Container
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFEEF2F6),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow('paid_from'.tr, data.paidFrom),
                                const SizedBox(height: 10),
                                _buildDetailRow('account_no'.tr, data.accountNo),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                  'debit_amount'.tr,
                                  formattedDebit,
                                  valueColor: const Color(0xFFD32F2F),
                                  isBold: true,
                                ),
                                const SizedBox(height: 12),

                                // Inner Dashed Line
                                CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DashedDividerPainter(
                                    color: const Color(0xFFE2E8F0),
                                    dashWidth: 3,
                                    dashSpace: 3,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                _buildDetailRow('receiver'.tr, data.receiverName),
                                const SizedBox(height: 10),
                                _buildDetailRow('total'.tr, formattedTotal),
                                const SizedBox(height: 12),

                                // Inner Dashed Line
                                CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DashedDividerPainter(
                                    color: const Color(0xFFE2E8F0),
                                    dashWidth: 3,
                                    dashSpace: 3,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                _buildDetailRow('reference_no'.tr, data.referenceNo),
                                const SizedBox(height: 10),
                                _buildDetailRow('date'.tr, formattedDate),
                              ],
                            ),
                          ),
                        ),

                        // Heart icon badge centered above bottom wavy edge
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFE2D4B7),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 20,
                            color: Color(0xFFC5A059),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Actions (Share / Print / Close)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.share_rounded,
                    label: 'share'.tr,
                    onTap: () {
                      Get.snackbar(
                        'invoice'.tr,
                        'invoice_slip_shared_msg'.tr,
                        backgroundColor: Colors.white,
                        colorText: Colors.black87,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.print_rounded,
                    label: 'print'.tr,
                    onTap: () {
                      Get.snackbar(
                        'print_receipt'.tr,
                        'sending_to_printer'.tr,
                        backgroundColor: AppThemes.primaryBlue,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    label: 'close'.tr,
                    isClose: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color valueColor = const Color(0xFF1E293B),
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isClose = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isClose ? Colors.white.withValues(alpha: 0.18) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: isClose ? Border.all(color: Colors.white38) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: isClose ? Colors.white : const Color(0xFF1E293B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isClose ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Clipper for Ticket Notches and Scalloped Bottom Edge
class TicketSlipClipper extends CustomClipper<Path> {
  final double punchPosition;
  final double punchRadius;
  final double scallopRadius;

  TicketSlipClipper({
    this.punchPosition = 145.0,
    this.punchRadius = 12.0,
    this.scallopRadius = 5.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    const cornerR = 24.0;

    // Top-left corner
    path.moveTo(0, cornerR);
    path.quadraticBezierTo(0, 0, cornerR, 0);

    // Top edge
    path.lineTo(size.width - cornerR, 0);
    // Top-right corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerR);

    // Right edge down to punch hole
    path.lineTo(size.width, punchPosition - punchRadius);
    // Right notch cutout (inward semicircular arc)
    path.arcToPoint(
      Offset(size.width, punchPosition + punchRadius),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );

    // Right edge down to bottom
    path.lineTo(size.width, size.height - scallopRadius);

    // Bottom scalloped perforated edge (wavy tear paper)
    final totalWidth = size.width;
    final diameter = scallopRadius * 2;
    final count = (totalWidth / diameter).floor();
    final step = totalWidth / count;
    final r = step / 2;

    for (int i = count - 1; i >= 0; i--) {
      final endX = i * step;
      path.arcToPoint(
        Offset(endX, size.height - scallopRadius),
        radius: Radius.circular(r),
        clockwise: false,
      );
    }

    // Left edge from bottom up to punch hole
    path.lineTo(0, punchPosition + punchRadius);
    // Left notch cutout (inward semicircular arc)
    path.arcToPoint(
      Offset(0, punchPosition - punchRadius),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );

    // Left edge up to top-left corner
    path.lineTo(0, cornerR);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Custom painter for dashed horizontal dividers
class DashedDividerPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashedDividerPainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 3,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
