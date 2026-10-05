library;

class CategoryModel {
  final int id;
  final int? storeId;
  final String name;
  final String code;
  final String icon;
  final bool isActive;

  CategoryModel({
    required this.id,
    this.storeId,
    required this.name,
    required this.code,
    this.icon = 'category',
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeId: json['store_id'] != null
          ? int.tryParse('${json['store_id']}')
          : null,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'category',
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'code': code,
      'icon': icon,
      'is_active': isActive,
    };
  }
}

class ProductModel {
  final int id;
  final int? storeId;
  final String name;
  final String barcode;
  final String category;
  final int? categoryId;
  final double price;
  final double costPrice;
  final int stockQty;
  final String color;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    this.storeId,
    required this.name,
    required this.barcode,
    required this.category,
    this.categoryId,
    required this.price,
    this.costPrice = 0.0,
    this.stockQty = 100,
    this.color = '#2E7D32',
    this.imageUrl,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeId: json['store_id'] != null
          ? int.tryParse('${json['store_id']}')
          : null,
      name: json['name']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      category: json['category']?.toString() ?? 'coffee',
      categoryId: json['category_id'] != null
          ? int.tryParse('${json['category_id']}')
          : null,
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0.0,
      costPrice: (json['cost_price'] is num)
          ? (json['cost_price'] as num).toDouble()
          : double.tryParse('${json['cost_price']}') ?? 0.0,
      stockQty: json['stock_qty'] is int
          ? json['stock_qty']
          : int.tryParse('${json['stock_qty']}') ?? 0,
      color: json['color']?.toString() ?? '#2E7D32',
      imageUrl: json['image_url']?.toString(),
      description: json['description']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'barcode': barcode,
      'category': category,
      'category_id': categoryId,
      'price': price,
      'cost_price': costPrice,
      'stock_qty': stockQty,
      'color': color,
      'image_url': imageUrl,
      'description': description,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
