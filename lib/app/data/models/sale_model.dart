library;

class SaleItemModel {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] != null ? int.tryParse('${json['id']}') : null,
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse('${json['product_id']}') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse('${json['quantity']}') ?? 1,
      unitPrice: (json['unit_price'] is num)
          ? (json['unit_price'] as num).toDouble()
          : double.tryParse('${json['unit_price']}') ?? 0.0,
      subtotal: (json['total_price'] is num)
          ? (json['total_price'] as num).toDouble()
          : ((json['subtotal'] is num)
              ? (json['subtotal'] as num).toDouble()
              : double.tryParse('${json['total_price'] ?? json['subtotal']}') ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'total_price': subtotal,
    };
  }
}

class SaleModel {
  final int id;
  final String invoiceNumber;
  final int storeId;
  final int? cashierId;
  final String? cashierName;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? customerName;
  final String? customerPhone;
  final List<SaleItemModel> items;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.storeId,
    this.cashierId,
    this.cashierName,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.finalAmount,
    this.paymentMethod = 'CASH',
    this.paymentStatus = 'COMPLETED',
    this.customerName,
    this.customerPhone,
    this.items = const [],
    required this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<SaleItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => SaleItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    final invoice = json['invoice_no']?.toString() ??
        json['invoice_number']?.toString() ??
        'INV-${json['id']}';

    final total = (json['total_amount'] is num)
        ? (json['total_amount'] as num).toDouble()
        : ((json['final_amount'] is num)
            ? (json['final_amount'] as num).toDouble()
            : double.tryParse('${json['total_amount'] ?? json['final_amount']}') ?? 0.0);

    final subtotal = (json['subtotal'] is num)
        ? (json['subtotal'] as num).toDouble()
        : ((json['total_amount'] is num)
            ? (json['total_amount'] as num).toDouble()
            : double.tryParse('${json['subtotal'] ?? json['total_amount']}') ?? total);

    final discount = (json['discount'] is num)
        ? (json['discount'] as num).toDouble()
        : ((json['discount_amount'] is num)
            ? (json['discount_amount'] as num).toDouble()
            : double.tryParse('${json['discount'] ?? json['discount_amount']}') ?? 0.0);

    final tax = (json['tax'] is num)
        ? (json['tax'] as num).toDouble()
        : ((json['tax_amount'] is num)
            ? (json['tax_amount'] as num).toDouble()
            : double.tryParse('${json['tax'] ?? json['tax_amount']}') ?? 0.0);

    return SaleModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      invoiceNumber: invoice,
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse('${json['store_id']}') ?? 1,
      cashierId: json['cashier_id'] != null
          ? int.tryParse('${json['cashier_id']}')
          : null,
      cashierName: json['cashier_name']?.toString() ?? 'Cashier',
      totalAmount: subtotal,
      discountAmount: discount,
      taxAmount: tax,
      finalAmount: total,
      paymentMethod: json['payment_method']?.toString() ?? 'CASH',
      paymentStatus: json['payment_status']?.toString() ?? 'PAID',
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      items: parsedItems,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNumber,
      'invoice_number': invoiceNumber,
      'store_id': storeId,
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'total_amount': finalAmount,
      'subtotal': totalAmount,
      'discount': discountAmount,
      'discount_amount': discountAmount,
      'tax': taxAmount,
      'tax_amount': taxAmount,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
