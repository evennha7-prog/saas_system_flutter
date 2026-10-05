library;

class StoreModel {
  final int id;
  final String storeName;
  final String? branchName;
  final String? ownerName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String currency;
  final bool isSubscriptionActive;
  final String plan;
  final double totalRevenue;
  final int staffCount;
  final int totalOrders;
  final DateTime? createdAt;

  StoreModel({
    required this.id,
    required this.storeName,
    this.branchName,
    this.ownerName,
    this.phoneNumber,
    this.email,
    this.address,
    this.currency = 'USD',
    this.isSubscriptionActive = true,
    this.plan = 'Pro',
    this.totalRevenue = 0.0,
    this.staffCount = 1,
    this.totalOrders = 0,
    this.createdAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeName: json['store_name']?.toString() ?? '',
      branchName: (json['store_branch'] ?? json['branch_name'])?.toString(),
      ownerName: (json['owner_name'] ?? json['full_name'])?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      currency: json['currency_symbol']?.toString() ?? json['currency']?.toString() ?? 'USD',
      isSubscriptionActive: json['is_active'] == true ||
          json['is_subscription_active'] == true ||
          json['is_active'] == 1,
      plan: json['plan']?.toString() ?? 'Pro',
      totalRevenue: (json['total_revenue'] is num)
          ? (json['total_revenue'] as num).toDouble()
          : double.tryParse('${json['total_revenue']}') ?? 0.0,
      staffCount: json['staff_count'] is int
          ? json['staff_count']
          : int.tryParse('${json['staff_count']}') ?? 1,
      totalOrders: json['total_orders'] is int
          ? json['total_orders']
          : int.tryParse('${json['total_orders']}') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'branch_name': branchName,
      'owner_name': ownerName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'currency': currency,
      'is_active': isSubscriptionActive,
      'plan': plan,
      'total_revenue': totalRevenue,
      'staff_count': staffCount,
      'total_orders': totalOrders,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

class StoreSettingModel {
  final int id;
  final int storeId;
  final String storeName;
  final String? branchName;
  final String? address;
  final String? phoneNumber;
  final String currency;
  final double taxRate;
  final String? receiptHeader;
  final String? receiptFooter;
  final String? wifiName;
  final String? wifiPassword;
  final String? telegramToken;
  final String? telegramChatId;

  StoreSettingModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    this.branchName,
    this.address,
    this.phoneNumber,
    this.currency = 'USD',
    this.taxRate = 0.0,
    this.receiptHeader,
    this.receiptFooter,
    this.wifiName,
    this.wifiPassword,
    this.telegramToken,
    this.telegramChatId,
  });

  factory StoreSettingModel.fromJson(Map<String, dynamic> json) {
    return StoreSettingModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse('${json['store_id']}') ?? 0,
      storeName: json['store_name']?.toString() ?? 'AudiCafe',
      branchName: json['branch_name']?.toString(),
      address: json['address']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      currency: json['currency']?.toString() ?? 'USD',
      taxRate: (json['tax_rate'] is num)
          ? (json['tax_rate'] as num).toDouble()
          : double.tryParse('${json['tax_rate']}') ?? 0.0,
      receiptHeader: json['receipt_header']?.toString(),
      receiptFooter: json['receipt_footer']?.toString(),
      wifiName: json['wifi_name']?.toString(),
      wifiPassword: json['wifi_password']?.toString(),
      telegramToken: json['telegram_token']?.toString(),
      telegramChatId: json['telegram_chat_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'store_name': storeName,
      'branch_name': branchName,
      'address': address,
      'phone_number': phoneNumber,
      'currency': currency,
      'tax_rate': taxRate,
      'receipt_header': receiptHeader,
      'receipt_footer': receiptFooter,
      'wifi_name': wifiName,
      'wifi_password': wifiPassword,
      'telegram_token': telegramToken,
      'telegram_chat_id': telegramChatId,
    };
  }
}
