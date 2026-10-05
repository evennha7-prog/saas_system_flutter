library;

class SupplierModel {
  final int id;
  final int storeId;
  final String name;
  final String? companyName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final double totalPurchases;
  final DateTime? createdAt;

  SupplierModel({
    required this.id,
    required this.storeId,
    required this.name,
    this.companyName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.totalPurchases = 0.0,
    this.createdAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse('${json['store_id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      totalPurchases: (json['total_purchases'] is num)
          ? (json['total_purchases'] as num).toDouble()
          : double.tryParse('${json['total_purchases']}') ?? 0.0,
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
      'company_name': companyName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'total_purchases': totalPurchases,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
