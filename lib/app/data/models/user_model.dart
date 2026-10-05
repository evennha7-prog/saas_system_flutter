library;

class UserModel {
  final int id;
  final int storeId;
  final String? storeName;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? telegramUsername;
  final String role;
  final String? pinCode;
  final String? shift;
  final int avatarIndex;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.storeId,
    this.storeName,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.telegramUsername,
    required this.role,
    this.pinCode,
    this.shift,
    this.avatarIndex = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse('${json['store_id']}') ?? 0,
      storeName: json['store_name']?.toString(),
      fullName: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email']?.toString(),
      telegramUsername: json['telegram_username']?.toString(),
      role: json['role']?.toString() ?? 'cashier',
      pinCode: json['pin_code']?.toString(),
      shift: json['shift']?.toString(),
      avatarIndex: json['avatar_index'] is int
          ? json['avatar_index']
          : int.tryParse('${json['avatar_index']}') ?? 0,
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
      'store_name': storeName,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'telegram_username': telegramUsername,
      'role': role,
      'pin_code': pinCode,
      'shift': shift,
      'avatar_index': avatarIndex,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

class TokenModel {
  final String accessToken;
  final String tokenType;
  final String role;
  final int? storeId;
  final String? storeName;
  final int userId;
  final String fullName;
  final UserModel? user;

  TokenModel({
    required this.accessToken,
    required this.tokenType,
    required this.role,
    this.storeId,
    this.storeName,
    required this.userId,
    required this.fullName,
    this.user,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['user']);
    }

    final resolvedRole = json['role']?.toString() ?? (parsedUser?.role ?? 'cashier');
    final resolvedStoreId = json['store_id'] != null
        ? int.tryParse('${json['store_id']}')
        : parsedUser?.storeId;
    final resolvedStoreName = json['store_name']?.toString() ?? parsedUser?.storeName;
    final resolvedUserId = parsedUser?.id ??
        (json['user_id'] is int
            ? json['user_id']
            : int.tryParse('${json['user_id']}') ?? 0);
    final resolvedFullName = parsedUser?.fullName ?? (json['full_name']?.toString() ?? '');

    return TokenModel(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      role: resolvedRole,
      storeId: resolvedStoreId,
      storeName: resolvedStoreName,
      userId: resolvedUserId,
      fullName: resolvedFullName,
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'role': role,
      'store_id': storeId,
      'store_name': storeName,
      'user_id': userId,
      'full_name': fullName,
      if (user != null) 'user': user!.toJson(),
    };
  }
}
