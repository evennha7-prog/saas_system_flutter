library;

class CustomerModel {
  final int id;
  final int storeId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final double totalSpent;
  final int points;
  final int visitsCount;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    this.totalSpent = 0.0,
    this.points = 0,
    this.visitsCount = 0,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse('${json['store_id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      totalSpent: (json['total_spent'] is num)
          ? (json['total_spent'] as num).toDouble()
          : double.tryParse('${json['total_spent']}') ?? 0.0,
      points: json['points'] is int
          ? json['points']
          : int.tryParse('${json['points']}') ?? 0,
      visitsCount: json['visits_count'] is int
          ? json['visits_count']
          : int.tryParse('${json['visits_count']}') ?? 0,
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
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'total_spent': totalSpent,
      'points': points,
      'visits_count': visitsCount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
