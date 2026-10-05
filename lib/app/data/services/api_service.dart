library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../endpoint.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/analytics_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/expense_model.dart';
import '../models/purchase_model.dart';
import '../models/store_model.dart';
import '../models/invoice_template_model.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/sales/controllers/sales_controller.dart';
import '../../modules/list_sales/controllers/list_sales_controller.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode = 200,
  });

  factory ApiResponse.success(T data, {int statusCode = 200}) {
    return ApiResponse(isSuccess: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String message, {int statusCode = 400}) {
    return ApiResponse(isSuccess: false, message: message, statusCode: statusCode);
  }
}
class ApiService extends GetxService {
  static ApiService get to {
    if (!Get.isRegistered<ApiService>()) {
      return Get.put<ApiService>(ApiService(), permanent: true);
    }
    return Get.find<ApiService>();
  }

  // ── Session Storage Keys ─────────────────────────────────────────────────
  static const String _keyToken = 'kitprak_auth_token';
  static const String _keyStoreId = 'kitprak_store_id';
  static const String _keyUserData = 'kitprak_user_data';

  // ── Authentication & Tenancy State ───────────────────────────────────────
  final Rx<String?> token = Rx<String?>(null);
  final Rx<int> currentStoreId = 1.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isOnline = true.obs;

  bool get isAuthenticated => token.value != null && token.value!.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    autoDiscoverHost();
  }

  /// Restores saved authentication session on app launch
  Future<void> initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_keyToken);
      final savedStoreId = prefs.getInt(_keyStoreId);
      final savedUserData = prefs.getString(_keyUserData);

      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
        if (savedStoreId != null && savedStoreId > 0) {
          currentStoreId.value = savedStoreId;
        }
        if (savedUserData != null && savedUserData.isNotEmpty) {
          try {
            currentUser.value = UserModel.fromJson(jsonDecode(savedUserData));
          } catch (_) {}
        }

        // Verify and refresh latest store/user profile in background
        getMe().then((res) {
          if (res.isSuccess && res.data != null) {
            syncActiveControllers();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Session] Init session error: $e');
    }
  }

  /// Sets auth state and persists to local storage
  Future<void> setAuth({required String authToken, int? storeId, UserModel? user}) async {
    token.value = authToken;
    if (storeId != null && storeId > 0) {
      currentStoreId.value = storeId;
    } else if (user != null && user.storeId > 0) {
      currentStoreId.value = user.storeId;
    } else if (user != null && user.role == 'super_admin') {
      currentStoreId.value = 0;
    }

    if (user != null) {
      currentUser.value = user;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, authToken);
      if (currentStoreId.value > 0) {
        await prefs.setInt(_keyStoreId, currentStoreId.value);
      }
      if (currentUser.value != null) {
        await prefs.setString(_keyUserData, jsonEncode(currentUser.value!.toJson()));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Session] Save error: $e');
    }

    syncActiveControllers();
  }

  /// Clears session and removes saved state
  Future<void> logout() async {
    token.value = null;
    currentUser.value = null;
    currentStoreId.value = 1;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyStoreId);
      await prefs.remove(_keyUserData);
    } catch (_) {}

    syncActiveControllers(isLogout: true);
  }

  /// Syncs all active GetX controllers when user or store changes
  void syncActiveControllers({bool isLogout = false}) {
    // 1. Profile Controller
    if (Get.isRegistered<ProfileController>()) {
      final profile = Get.find<ProfileController>();
      if (isLogout) {
        profile.userName.value = 'Store User';
        profile.phoneNumber.value = '';
        profile.userEmail.value = '';
        profile.telegramUsername.value = '';
        profile.userRole.value = 'cashier';
        profile.storeName.value = 'Store';
        profile.storeBranch.value = 'Main Branch';
      } else if (currentUser.value != null) {
        final u = currentUser.value!;
        profile.userName.value = u.fullName;
        profile.phoneNumber.value = u.phoneNumber;
        profile.userEmail.value = u.email ?? '';
        profile.telegramUsername.value = u.telegramUsername ?? '';
        profile.userRole.value = u.role;
        profile.userShift.value = u.shift ?? 'Morning Shift';
        profile.avatarIndex.value = u.avatarIndex;
        if (u.storeName != null && u.storeName!.isNotEmpty) {
          profile.storeName.value = u.storeName!;
        }
        if (u.storeId > 0) {
          profile.currentStoreId.value = u.storeId;
        }
      }
    }

    // 2. Home Controller
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      if (isLogout) {
        home.shopName.value = 'AudiCafe';
        home.cashierName.value = 'Store Cashier';
        home.phoneNumber.value = '';
        home.income.value = 0.0;
        home.expense.value = 0.0;
        home.netProfit.value = 0.0;
        home.totalTransactions.value = 0;
      } else {
        home.syncUserInfo();
        home.fetchDashboardData();
      }
    }

    // 3. Sales Controller (POS)
    if (Get.isRegistered<SalesController>()) {
      final sales = Get.find<SalesController>();
      sales.cart.clear();
      if (!isLogout) {
        sales.fetchLiveCategories();
        sales.fetchLiveProducts();
      } else {
        sales.products.clear();
      }
    }

    // 4. List Sales Controller
    if (Get.isRegistered<ListSalesController>()) {
      final listSales = Get.find<ListSalesController>();
      if (!isLogout) {
        listSales.fetchSales();
      } else {
        listSales.sales.clear();
      }
    }
  }

  // ── Network Helper ───────────────────────────────────────────────────────
  Map<String, String> _headers({String contentType = 'application/json'}) {
    return Endpoints.getHeaders(
      token: token.value,
      storeId: currentStoreId.value,
      contentType: contentType,
    );
  }

  dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint('[API ${response.request?.method}] ${response.request?.url} -> ${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        return response.body;
      }
    } else {
      String errorMessage = 'Server error (${response.statusCode})';
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map && decoded.containsKey('detail')) {
          errorMessage = decoded['detail'].toString();
        } else if (decoded is Map && decoded.containsKey('message')) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  String _formatError(Object e) {
    final str = e.toString();
    if (str.contains('SocketException') ||
        str.contains('Connection refused') ||
        str.contains('ClientException') ||
        str.contains('HandshakeException') ||
        str.contains('TimeoutException') ||
        str.contains('Failed host lookup')) {
      autoDiscoverHost();
      return 'server_connection_failed'.tr;
    }
    return str.replaceFirst('Exception: ', '');
  }

  // ── Health & Connection Check with Auto-Discovery ───────────────────────
  Future<void> autoDiscoverHost() async {
    if (Get.testMode) return;
    final futures = Endpoints.candidateBaseUrls.map((host) async {
      try {
        final response = await http
            .get(Uri.parse('$host/health'))
            .timeout(const Duration(milliseconds: 1500));
        if (response.statusCode == 200) {
          return host;
        }
      } catch (_) {}
      return null;
    });

    final results = await Future.wait(futures);
    for (final host in results) {
      if (host != null) {
        Endpoints.baseUrl = host;
        isOnline.value = true;
        if (kDebugMode) {
          debugPrint('[API] Connected to working host: $host');
        }
        return;
      }
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.rootUrl(Endpoints.health)))
          .timeout(const Duration(seconds: 2));
      isOnline.value = response.statusCode == 200;
      if (!isOnline.value) {
        await autoDiscoverHost();
      }
      return isOnline.value;
    } catch (_) {
      await autoDiscoverHost();
      return isOnline.value;
    }
  }

  // ── 1. Authentication ────────────────────────────────────────────────────
  Future<ApiResponse<TokenModel>> login(String identifier, String password) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.login));
      final response = await http
          .post(
            url,
            headers: _headers(),
            body: jsonEncode({
              'identifier': identifier,
              'password': password,
            }),
          )
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      final tokenModel = TokenModel.fromJson(json);
      setAuth(
        authToken: tokenModel.accessToken,
        storeId: tokenModel.storeId,
        user: tokenModel.user ??
            UserModel(
              id: tokenModel.userId,
              storeId: tokenModel.storeId ?? 0,
              storeName: tokenModel.storeName,
              fullName: tokenModel.fullName,
              phoneNumber: identifier,
              role: tokenModel.role,
            ),
      );
      return ApiResponse.success(tokenModel);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<TokenModel>> pinLogin(String pin, {int? storeId}) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.pinLogin));
      final targetStoreId = storeId ?? currentStoreId.value;
      final response = await http
          .post(
            url,
            headers: _headers(),
            body: jsonEncode({
              'pin': pin,
              'store_id': targetStoreId,
            }),
          )
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      final tokenModel = TokenModel.fromJson(json);
      setAuth(
        authToken: tokenModel.accessToken,
        storeId: tokenModel.storeId ?? targetStoreId,
        user: tokenModel.user ??
            UserModel(
              id: tokenModel.userId,
              storeId: tokenModel.storeId ?? targetStoreId,
              storeName: tokenModel.storeName,
              fullName: tokenModel.fullName,
              phoneNumber: 'PIN: $pin',
              role: tokenModel.role,
            ),
      );
      return ApiResponse.success(tokenModel);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<TokenModel>> registerStore(Map<String, dynamic> data, {bool autoSetAuth = false}) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.registerStore));
      final response = await http
          .post(
            url,
            headers: _headers(),
            body: jsonEncode(data),
          )
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      final tokenModel = TokenModel.fromJson(json);
      if (autoSetAuth) {
        setAuth(
          authToken: tokenModel.accessToken,
          storeId: tokenModel.storeId,
          user: tokenModel.user ??
              UserModel(
                id: tokenModel.userId,
                storeId: tokenModel.storeId ?? 0,
                storeName: tokenModel.storeName,
                fullName: tokenModel.fullName,
                phoneNumber: data['phone_number']?.toString() ?? '',
                role: tokenModel.role,
              ),
        );
      }
      return ApiResponse.success(tokenModel);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<TokenModel>> register(Map<String, dynamic> data, {bool autoSetAuth = false}) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.register));
      final response = await http
          .post(
            url,
            headers: _headers(),
            body: jsonEncode(data),
          )
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      final tokenModel = TokenModel.fromJson(json);
      if (autoSetAuth) {
        setAuth(
          authToken: tokenModel.accessToken,
          storeId: tokenModel.storeId,
          user: tokenModel.user ??
              UserModel(
                id: tokenModel.userId,
                storeId: tokenModel.storeId ?? 0,
                storeName: tokenModel.storeName,
                fullName: tokenModel.fullName,
                phoneNumber: data['phone_number']?.toString() ?? '',
                role: tokenModel.role,
              ),
        );
      }
      return ApiResponse.success(tokenModel);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> checkRegistrationStatus(String phone) async {
    try {
      final cleanPhone = phone.replaceAll(' ', '').replaceAll('-', '');
      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.registrationStatus))
          .replace(queryParameters: {'phone': cleanPhone});

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      return ApiResponse.success(Map<String, dynamic>.from(json ?? {}));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<UserModel>> getMe() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.authMe));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final json = _handleResponse(response);
      final user = UserModel.fromJson(json);
      currentUser.value = user;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
      } catch (_) {}
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.updateProfile));
      final response = await http
          .put(
            url,
            headers: _headers(),
            body: jsonEncode(data),
          )
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      final user = UserModel.fromJson(json);
      currentUser.value = user;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
      } catch (_) {}
      syncActiveControllers();
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }


  // ── 2. Products & Categories ─────────────────────────────────────────────
  Future<ApiResponse<List<ProductModel>>> getProducts({
    String? category,
    String? query,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (category != null && category.isNotEmpty && category != 'cat_all') {
        queryParams['category'] = category;
      }
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }

      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.products))
          .replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final products = json.map((p) => ProductModel.fromJson(p)).toList();
        return ApiResponse.success(products);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<List<CategoryModel>>> getCategories() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.productCategories));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final categories = json.map((c) => CategoryModel.fromJson(c)).toList();
        return ApiResponse.success(categories);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<CategoryModel>> createCategory(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.productCategories));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(CategoryModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<bool>> deleteCategory(int id) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.categoryById(id)));
      final response = await http
          .delete(url, headers: _headers())
          .timeout(Endpoints.sendTimeout);

      _handleResponse(response);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<ProductModel>> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.productByBarcode(barcode)));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(ProductModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<ProductModel>> createProduct(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.products));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(ProductModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<ProductModel>> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.productById(id)));
      final response = await http
          .put(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(ProductModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<bool>> deleteProduct(int id) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.productById(id)));
      final response = await http
          .delete(url, headers: _headers())
          .timeout(Endpoints.sendTimeout);

      _handleResponse(response);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 3. Sales & POS Checkout ──────────────────────────────────────────────
  Future<ApiResponse<SaleModel>> checkout({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    double discountAmount = 0.0,
    double taxAmount = 0.0,
    required double finalAmount,
    String paymentMethod = 'CASH',
    String? customerName,
    String? customerPhone,
    String? note,
  }) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.checkout));
      final Map<String, dynamic> body = {
        'items': items,
        'total_amount': totalAmount,
        'discount': discountAmount,
        'discount_amount': discountAmount,
        'tax': taxAmount,
        'tax_amount': taxAmount,
        'final_amount': finalAmount,
        'payment_method': paymentMethod,
      };
      if (customerName != null) body['customer_name'] = customerName;
      if (customerPhone != null) body['customer_phone'] = customerPhone;
      if (note != null) body['note'] = note;

      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(body))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(SaleModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<List<SaleModel>>> getSales({
    String? filterPreset,
    String? paymentMethod,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (filterPreset != null && filterPreset.isNotEmpty) {
        queryParams['filter_preset'] = filterPreset;
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParams['payment_method'] = paymentMethod;
      }

      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.sales))
          .replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final sales = json.map((s) => SaleModel.fromJson(s)).toList();
        return ApiResponse.success(sales);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 4. Dashboard & Analytics ─────────────────────────────────────────────
  Future<ApiResponse<DashboardSummaryModel>> getDashboardSummary() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.analyticsSummary));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(DashboardSummaryModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<List<DailyTransactionModel>>> getDailyTransactions({int days = 7}) async {
    try {
      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.dailyTransactions))
          .replace(queryParameters: {'days': days.toString()});

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final list = json.map((d) => DailyTransactionModel.fromJson(d)).toList();
        return ApiResponse.success(list);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 5. Staff Management ──────────────────────────────────────────────────
  Future<ApiResponse<List<UserModel>>> getStaff({int skip = 0, int limit = 100}) async {
    try {
      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.staff))
          .replace(queryParameters: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final staffList = json.map((u) => UserModel.fromJson(u)).toList();
        return ApiResponse.success(staffList);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<UserModel>> createStaff(Map<String, dynamic> staffData) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.staff));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(staffData))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(UserModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 6. Super Admin & Stores ──────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> getAdminDashboard() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.adminDashboard));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(Map<String, dynamic>.from(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<List<StoreModel>>> getStores({int skip = 0, int limit = 100}) async {
    try {
      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.adminStores))
          .replace(queryParameters: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final stores = json.map((s) => StoreModel.fromJson(s)).toList();
        return ApiResponse.success(stores);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<StoreModel>> updateStore(int storeId, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.adminStoreById(storeId)));
      final response = await http
          .put(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final dynamic json = _handleResponse(response);
      return ApiResponse.success(StoreModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<List<UserModel>>> getStoreStaff(int storeId) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.adminStoreStaff(storeId)));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final list = json.map((u) => UserModel.fromJson(u)).toList();
        return ApiResponse.success(list);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<UserModel>> updateStaff(int staffId, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.staffById(staffId)));
      final response = await http
          .put(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final dynamic json = _handleResponse(response);
      return ApiResponse.success(UserModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getStoreOwners({
    String? status,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        queryParams['status'] = status.toLowerCase();
      }

      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.adminStoreOwners))
          .replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final list = json.map((item) => Map<String, dynamic>.from(item)).toList();
        return ApiResponse.success(list);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createStoreOwner(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.adminStoreOwners));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final dynamic json = _handleResponse(response);
      return ApiResponse.success(Map<String, dynamic>.from(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> approveStoreOwner(int ownerId) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.adminApproveStoreOwner(ownerId)));
      final response = await http
          .post(url, headers: _headers())
          .timeout(Endpoints.sendTimeout);

      final dynamic json = _handleResponse(response);
      return ApiResponse.success(Map<String, dynamic>.from(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> rejectStoreOwner(int ownerId, {String? reason}) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.adminRejectStoreOwner(ownerId)));
      final body = reason != null ? jsonEncode({'rejection_reason': reason}) : jsonEncode({});
      final response = await http
          .post(url, headers: _headers(), body: body)
          .timeout(Endpoints.sendTimeout);

      final dynamic json = _handleResponse(response);
      return ApiResponse.success(Map<String, dynamic>.from(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteStoreOwner(int ownerId) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.adminStoreOwnerById(ownerId)));
      final response = await http
          .delete(url, headers: _headers())
          .timeout(Endpoints.sendTimeout);

      final dynamic json = _handleResponse(response);
      return ApiResponse.success(Map<String, dynamic>.from(json ?? {}));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 7. Customers ─────────────────────────────────────────────────────────
  Future<ApiResponse<List<CustomerModel>>> getCustomers({String? query}) async {
    try {
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['query'] = query;

      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.customers))
          .replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final customers = json.map((c) => CustomerModel.fromJson(c)).toList();
        return ApiResponse.success(customers);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<CustomerModel>> createCustomer(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.customers));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(CustomerModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 8. Suppliers ─────────────────────────────────────────────────────────
  Future<ApiResponse<List<SupplierModel>>> getSuppliers({String? query}) async {
    try {
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['query'] = query;

      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.suppliers))
          .replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final suppliers = json.map((s) => SupplierModel.fromJson(s)).toList();
        return ApiResponse.success(suppliers);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<SupplierModel>> createSupplier(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.suppliers));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(SupplierModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 9. Expenses ──────────────────────────────────────────────────────────
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({String? filterPreset, String? category}) async {
    try {
      final queryParams = <String, String>{};
      if (filterPreset != null) queryParams['filter_preset'] = filterPreset;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.expenses))
          .replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final expenses = json.map((e) => ExpenseModel.fromJson(e)).toList();
        return ApiResponse.success(expenses);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<ExpenseModel>> createExpense(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.expenses));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(ExpenseModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 10. Purchases ────────────────────────────────────────────────────────
  Future<ApiResponse<List<PurchaseModel>>> getPurchases() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.purchases));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final dynamic json = _handleResponse(response);
      if (json is List) {
        final purchases = json.map((p) => PurchaseModel.fromJson(p)).toList();
        return ApiResponse.success(purchases);
      }
      return ApiResponse.success([]);
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<PurchaseModel>> createPurchase(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.purchases));
      final response = await http
          .post(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(PurchaseModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 11. Store Settings ───────────────────────────────────────────────────
  Future<ApiResponse<StoreSettingModel>> getSettings() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.settings));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(StoreSettingModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<StoreSettingModel>> updateSettings(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.settings));
      final response = await http
          .put(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(StoreSettingModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  // ── 12. User Invoice Template ────────────────────────────────────────────
  Future<ApiResponse<UserInvoiceTemplateModel>> getInvoiceTemplate() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.invoiceTemplate));
      final response = await http
          .get(url, headers: _headers())
          .timeout(Endpoints.receiveTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(UserInvoiceTemplateModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<UserInvoiceTemplateModel>> updateInvoiceTemplate(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.invoiceTemplate));
      final response = await http
          .put(url, headers: _headers(), body: jsonEncode(data))
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(UserInvoiceTemplateModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }

  Future<ApiResponse<UserInvoiceTemplateModel>> resetInvoiceTemplate() async {
    try {
      final url = Uri.parse(Endpoints.getFullUrl(Endpoints.resetInvoiceTemplate));
      final response = await http
          .post(url, headers: _headers())
          .timeout(Endpoints.sendTimeout);

      final json = _handleResponse(response);
      return ApiResponse.success(UserInvoiceTemplateModel.fromJson(json));
    } catch (e) {
      return ApiResponse.error(_formatError(e));
    }
  }
}
