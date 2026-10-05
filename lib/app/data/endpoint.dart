class Endpoints {
  Endpoints._();

  // ── Base URL Configuration ───────────────────────────────────────────────
  static const String productionBaseUrl = 'https://severprak.vercel.app';

  /// Server base URL (Vercel Cloud Serverless API)
  static String baseUrl = productionBaseUrl;
  static const String apiPrefix = '/api/v1';

  static List<String> get candidateBaseUrls => [
    productionBaseUrl,
    'http://127.0.0.1:8080',
    'http://localhost:8080',
    'http://10.0.2.2:8080',
  ];

  /// Complete base URL with API version prefix (e.g. https://severprak.vercel.app/api/v1)
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // ── URL Normalization & Helper Methods ────────────────────────────────────
  /// Resolves full API URL with '/api/v1' prefix
  static String getFullUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final normalized = path.trim();
    if (normalized.startsWith('/api/v1')) {
      return '$baseUrl$normalized';
    }

    if (normalized.startsWith('/')) {
      return '$apiBaseUrl$normalized';
    }
    return '$apiBaseUrl/$normalized';
  }

  /// Construct root URL (without '/api/v1' prefix, e.g. for /health)
  static String rootUrl(String rootPath) {
    if (rootPath.startsWith('http://') || rootPath.startsWith('https://')) {
      return rootPath;
    }
    final path = rootPath.startsWith('/') ? rootPath : '/$rootPath';
    return '$baseUrl$path';
  }

  /// Resolves server assets or media URLs (e.g. uploaded images, logos)
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final normalized = path.trim();

    // Handle relative paths (e.g. "/uploads/...", "uploads/...")
    if (normalized.startsWith('/')) {
      return '$baseUrl$normalized';
    }
    return '$baseUrl/$normalized';
  }

  // Connection settings – fast timeouts so cold-start retries don't block forever
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ── Auth Endpoints ───────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String pinLogin = '/auth/pin-login';
  static const String register = '/auth/register';
  static const String registerStore = '/auth/register-store';
  static const String registrationStatus = '/auth/registration-status';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String authMe = '/auth/me';
  static const String updateProfile = '/auth/profile';

  // ── Super Administrator (Platform Owner) Endpoints ──────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStores = '/admin/stores';
  static String adminStoreById(int id) => '/admin/stores/$id';
  static String adminStoreStaff(int storeId) => '/admin/stores/$storeId/staff';
  static const String adminStoreOwners = '/admin/store-owners';
  static String adminApproveStoreOwner(int id) => '/admin/store-owners/$id/approve';
  static String adminRejectStoreOwner(int id) => '/admin/store-owners/$id/reject';
  static String adminStoreOwnerById(int id) => '/admin/store-owners/$id';

  // ── Staff Management Endpoints ───────────────────────────────────────────
  static const String staff = '/staff';
  static String staffById(int id) => '/staff/$id';

  // ── Products & Catalog Endpoints ─────────────────────────────────────────
  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static String categoryById(int id) => '/products/categories/$id';
  static String productById(int id) => '/products/$id';
  static String productByBarcode(String barcode) => '/products/barcode/$barcode';

  // ── Sales & POS Checkout Endpoints ───────────────────────────────────────
  static const String checkout = '/sales/checkout';
  static const String sales = '/sales';
  static String saleById(int id) => '/sales/$id';

  // ── Dashboard & Analytics Endpoints ──────────────────────────────────────
  static const String analyticsSummary = '/analytics/summary';
  static const String dailyTransactions = '/analytics/daily-transactions';

  // ── Customers Endpoints ──────────────────────────────────────────────────
  static const String customers = '/customers';
  static String customerById(int id) => '/customers/$id';

  // ── Suppliers Endpoints ──────────────────────────────────────────────────
  static const String suppliers = '/suppliers';
  static String supplierById(int id) => '/suppliers/$id';

  // ── Expenses Endpoints ───────────────────────────────────────────────────
  static const String expenses = '/expenses';
  static String expenseById(int id) => '/expenses/$id';

  // ── Purchases & Stock-In Endpoints ───────────────────────────────────────
  static const String purchases = '/purchases';

  // ── Store Settings Endpoints ─────────────────────────────────────────────
  static const String settings = '/settings';
  static const String invoiceTemplate = '/invoice-template';
  static const String resetInvoiceTemplate = '/invoice-template/reset';

  // ── System & Health Endpoints ────────────────────────────────────────────
  static const String root = '/';
  static const String health = '/health';
  static const String openApiJson = '/api/v1/openapi.json';
  static const String docs = '/docs';

  // ── Request Headers ──────────────────────────────────────────────────────
  static Map<String, String> getHeaders({
    String? token,
    int? storeId,
    String contentType = 'application/json',
  }) {
    final Map<String, String> headers = {
      'Content-Type': contentType,
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (storeId != null && storeId > 0) {
      headers['X-Store-Id'] = storeId.toString();
    }

    return headers;
  }
}
