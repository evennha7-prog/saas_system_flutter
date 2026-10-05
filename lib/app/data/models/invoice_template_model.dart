class UserInvoiceTemplateModel {
  final int id;
  final int? userId;
  final int? storeId;
  final int? tenantId;
  final String style;
  final String paperSize;
  final String storeName;
  final String branchName;
  final String phoneNumber;
  final String address;
  final String vatTin;
  final String headerMessage;
  final String footerMessage;
  final String wifiInfo;
  final bool showLogo;
  final bool showKhqr;
  final bool showBarcode;
  final bool showCashier;
  final bool showTableNum;
  final bool showExchangeRate;
  final bool showVatDetails;
  final bool showWifiInfo;

  UserInvoiceTemplateModel({
    required this.id,
    this.userId,
    this.storeId,
    this.tenantId,
    this.style = 'minimal',
    this.paperSize = '80mm',
    this.storeName = 'KITLUY Coffee & Bakery',
    this.branchName = 'Main Branch',
    this.phoneNumber = '097 534 8338 / 012 345 678',
    this.address = '#128 St 2004, Phnom Penh',
    this.vatTin = 'K001-902345890',
    this.headerMessage = 'សូមស្វាគមន៍មកកាន់ហាងយើងខ្ញុំ! Welcome!',
    this.footerMessage = 'ទំនិញទិញរួចមិនអាចប្តូរវិញបានទេ\nThank you & See you again!',
    this.wifiInfo = 'Wi-Fi: KITLUY_GUEST / Pass: 88888888',
    this.showLogo = true,
    this.showKhqr = true,
    this.showBarcode = true,
    this.showCashier = true,
    this.showTableNum = true,
    this.showExchangeRate = true,
    this.showVatDetails = true,
    this.showWifiInfo = true,
  });

  factory UserInvoiceTemplateModel.fromJson(Map<String, dynamic> json) {
    return UserInvoiceTemplateModel(
      id: json['id'] as int? ?? 1,
      userId: json['user_id'] as int?,
      storeId: json['store_id'] as int?,
      tenantId: json['tenant_id'] as int?,
      style: json['style'] as String? ?? 'minimal',
      paperSize: json['paper_size'] as String? ?? '80mm',
      storeName: json['store_name'] as String? ?? 'KITLUY Coffee & Bakery',
      branchName: json['branch_name'] as String? ?? 'Main Branch',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      vatTin: json['vat_tin'] as String? ?? '',
      headerMessage: json['header_message'] as String? ?? '',
      footerMessage: json['footer_message'] as String? ?? '',
      wifiInfo: json['wifi_info'] as String? ?? '',
      showLogo: json['show_logo'] as bool? ?? true,
      showKhqr: json['show_khqr'] as bool? ?? true,
      showBarcode: json['show_barcode'] as bool? ?? true,
      showCashier: json['show_cashier'] as bool? ?? true,
      showTableNum: json['show_table_num'] as bool? ?? true,
      showExchangeRate: json['show_exchange_rate'] as bool? ?? true,
      showVatDetails: json['show_vat_details'] as bool? ?? true,
      showWifiInfo: json['show_wifi_info'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'style': style,
      'paper_size': paperSize,
      'store_name': storeName,
      'branch_name': branchName,
      'phone_number': phoneNumber,
      'address': address,
      'vat_tin': vatTin,
      'header_message': headerMessage,
      'footer_message': footerMessage,
      'wifi_info': wifiInfo,
      'show_logo': showLogo,
      'show_khqr': showKhqr,
      'show_barcode': showBarcode,
      'show_cashier': showCashier,
      'show_table_num': showTableNum,
      'show_exchange_rate': showExchangeRate,
      'show_vat_details': showVatDetails,
      'show_wifi_info': showWifiInfo,
    };
  }
}
