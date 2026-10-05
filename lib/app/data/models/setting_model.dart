class StoreSettingModel {
  final int id;
  final int? storeId;
  final String storeName;
  final String storeBranch;
  final String phoneNumber;
  final String email;
  final String address;
  final String currencySymbol;
  final double exchangeRateKhr;
  final double taxRate;
  final String printerName;
  final int printerPaperWidth;
  final bool autoPrintReceipt;
  final bool soundAlert;
  final String receiptHeader;
  final String receiptFooter;
  final String? telegramBotToken;
  final String? telegramChatId;
  final bool telegramAlertsEnabled;

  StoreSettingModel({
    required this.id,
    this.storeId,
    this.storeName = 'POS Store',
    this.storeBranch = 'Main Branch',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.currencySymbol = '\$',
    this.exchangeRateKhr = 4100.0,
    this.taxRate = 0.0,
    this.printerName = 'Bluetooth 80mm POS Thermal',
    this.printerPaperWidth = 80,
    this.autoPrintReceipt = true,
    this.soundAlert = true,
    this.receiptHeader = 'Welcome to POS',
    this.receiptFooter = 'Thank you for your visit! Please come again.',
    this.telegramBotToken,
    this.telegramChatId,
    this.telegramAlertsEnabled = false,
  });

  factory StoreSettingModel.fromJson(Map<String, dynamic> json) {
    return StoreSettingModel(
      id: json['id'] as int? ?? 1,
      storeId: json['store_id'] as int?,
      storeName: json['store_name'] as String? ?? 'POS Store',
      storeBranch: json['store_branch'] as String? ?? 'Main Branch',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      exchangeRateKhr: (json['exchange_rate_khr'] as num?)?.toDouble() ?? 4100.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      printerName: json['printer_name'] as String? ?? 'Bluetooth 80mm POS Thermal',
      printerPaperWidth: json['printer_paper_width'] as int? ?? 80,
      autoPrintReceipt: json['auto_print_receipt'] as bool? ?? true,
      soundAlert: json['sound_alert'] as bool? ?? true,
      receiptHeader: json['receipt_header'] as String? ?? 'Welcome to POS',
      receiptFooter: json['receipt_footer'] as String? ?? 'Thank you for your visit!',
      telegramBotToken: json['telegram_bot_token'] as String?,
      telegramChatId: json['telegram_chat_id'] as String?,
      telegramAlertsEnabled: json['telegram_alerts_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'store_branch': storeBranch,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'currency_symbol': currencySymbol,
      'exchange_rate_khr': exchangeRateKhr,
      'tax_rate': taxRate,
      'printer_name': printerName,
      'printer_paper_width': printerPaperWidth,
      'auto_print_receipt': autoPrintReceipt,
      'sound_alert': soundAlert,
      'receipt_header': receiptHeader,
      'receipt_footer': receiptFooter,
      if (telegramBotToken != null) 'telegram_bot_token': telegramBotToken,
      if (telegramChatId != null) 'telegram_chat_id': telegramChatId,
      'telegram_alerts_enabled': telegramAlertsEnabled,
    };
  }
}
