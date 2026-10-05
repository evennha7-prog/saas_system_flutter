library;

class PurchaseItemModel {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitCost;
  final double subtotal;

  PurchaseItemModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'] != null ? int.tryParse('${json['id']}') : null,
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse('${json['product_id']}') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse('${json['quantity']}') ?? 1,
      unitCost: (json['unit_cost'] is num)
          ? (json['unit_cost'] as num).toDouble()
          : double.tryParse('${json['unit_cost']}') ?? 0.0,
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse('${json['subtotal']}') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_cost': unitCost,
      'subtotal': subtotal,
    };
  }
}

class PurchaseModel {
  final int id;
  final String invoiceNumber;
  final int storeId;
  final int? supplierId;
  final String? supplierName;
  final double totalAmount;
  final String status;
  final List<PurchaseItemModel> items;
  final DateTime createdAt;

  PurchaseModel({
    required this.id,
    required this.invoiceNumber,
    required this.storeId,
    this.supplierId,
    this.supplierName,
    required this.totalAmount,
    this.status = 'RECEIVED',
    this.items = const [],
    required this.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<PurchaseItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => PurchaseItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return PurchaseModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse('${json['store_id']}') ?? 0,
      supplierId: json['supplier_id'] != null
          ? int.tryParse('${json['supplier_id']}')
          : null,
      supplierName: json['supplier_name']?.toString(),
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toDouble()
          : double.tryParse('${json['total_amount']}') ?? 0.0,
      status: json['status']?.toString() ?? 'RECEIVED',
      items: parsedItems,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'store_id': storeId,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'total_amount': totalAmount,
      'status': status,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
