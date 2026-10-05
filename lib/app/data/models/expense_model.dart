library;

class ExpenseModel {
  final int id;
  final int storeId;
  final String title;
  final double amount;
  final String category;
  final String? note;
  final int? createdBy;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.storeId,
    required this.title,
    required this.amount,
    this.category = 'general',
    this.note,
    this.createdBy,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse('${json['store_id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse('${json['amount']}') ?? 0.0,
      category: json['category']?.toString() ?? 'general',
      note: json['note']?.toString(),
      createdBy: json['created_by'] != null
          ? int.tryParse('${json['created_by']}')
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'title': title,
      'amount': amount,
      'category': category,
      'note': note,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
