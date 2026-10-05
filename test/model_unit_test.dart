import 'package:flutter_test/flutter_test.dart';
import 'package:kit_prak/app/data/models/customer_model.dart';
import 'package:kit_prak/app/data/models/product_model.dart';
import 'package:kit_prak/app/data/models/sale_model.dart';
import 'package:kit_prak/app/data/models/setting_model.dart';

void main() {
  group('Model Serialization & Deserialization Unit Tests', () {
    test('CustomerModel fromJson and toJson work accurately', () {
      final json = {
        'id': 101,
        'store_id': 1,
        'name': 'Chan Dara',
        'phone_number': '012 345 678',
        'email': 'dara@example.com',
        'address': 'Phnom Penh',
        'total_spent': 150.50,
        'points': 150,
        'visits_count': 12,
        'created_at': '2026-03-01T10:00:00.000Z',
      };

      final customer = CustomerModel.fromJson(json);
      expect(customer.id, 101);
      expect(customer.name, 'Chan Dara');
      expect(customer.phoneNumber, '012 345 678');
      expect(customer.totalSpent, 150.50);
      expect(customer.points, 150);
      expect(customer.visitsCount, 12);

      final outJson = customer.toJson();
      expect(outJson['name'], 'Chan Dara');
      expect(outJson['points'], 150);
      expect(outJson['total_spent'], 150.50);
    });

    test('ProductModel and CategoryModel fromJson work accurately', () {
      final catJson = {
        'id': 1,
        'store_id': 1,
        'name': 'Beverages',
        'code': 'beverage',
        'icon': 'coffee',
        'is_active': true,
      };

      final category = CategoryModel.fromJson(catJson);
      expect(category.name, 'Beverages');
      expect(category.code, 'beverage');
      expect(category.isActive, isTrue);

      final prodJson = {
        'id': 42,
        'store_id': 1,
        'name': 'Iced Latte',
        'barcode': '884500129384',
        'category': 'beverage',
        'price': 2.75,
        'cost_price': 1.10,
        'stock_qty': 85,
        'color': '#2E7D32',
        'is_active': true,
      };

      final product = ProductModel.fromJson(prodJson);
      expect(product.id, 42);
      expect(product.name, 'Iced Latte');
      expect(product.barcode, '884500129384');
      expect(product.price, 2.75);
      expect(product.costPrice, 1.10);
      expect(product.stockQty, 85);
      expect(product.color, '#2E7D32');
    });

    test('StoreSettingModel handles telegram bot token & chat ID', () {
      final json = {
        'id': 1,
        'store_id': 1,
        'store_name': 'AudiCafe Flagship',
        'printer_name': 'Epson TM-T88VI',
        'printer_paper_width': 80,
        'auto_print_receipt': true,
        'sound_alert': true,
        'receipt_header': 'Welcome to AudiCafe',
        'receipt_footer': 'Thank you!',
        'telegram_bot_token': '7192840192:AAEj9kLmNop1028374-QrStUvW',
        'telegram_chat_id': '-1002938491023',
        'telegram_alerts_enabled': true,
      };

      final setting = StoreSettingModel.fromJson(json);
      expect(setting.storeName, 'AudiCafe Flagship');
      expect(setting.printerName, 'Epson TM-T88VI');
      expect(setting.telegramBotToken, '7192840192:AAEj9kLmNop1028374-QrStUvW');
      expect(setting.telegramChatId, '-1002938491023');
      expect(setting.telegramAlertsEnabled, isTrue);

      final outJson = setting.toJson();
      expect(outJson['telegram_bot_token'], '7192840192:AAEj9kLmNop1028374-QrStUvW');
      expect(outJson['telegram_chat_id'], '-1002938491023');
      expect(outJson['telegram_alerts_enabled'], isTrue);
    });

    test('SaleModel and SaleItemModel compute subtotals correctly', () {
      final saleJson = {
        'id': 88,
        'invoice_number': 'INV-2026-0088',
        'store_id': 1,
        'cashier_name': 'Sophea Sok',
        'payment_method': 'CASH',
        'subtotal': 5.50,
        'discount_amount': 0.50,
        'total_amount': 5.00,
        'items': [
          {
            'id': 1,
            'sale_id': 88,
            'product_id': 42,
            'product_name': 'Iced Latte',
            'unit_price': 2.75,
            'quantity': 2,
            'subtotal': 5.50,
          }
        ],
      };

      final sale = SaleModel.fromJson(saleJson);
      expect(sale.id, 88);
      expect(sale.invoiceNumber, 'INV-2026-0088');
      expect(sale.totalAmount, 5.50);
      expect(sale.discountAmount, 0.50);
      expect(sale.finalAmount, 5.00);
      expect(sale.items.length, 1);
      expect(sale.items.first.productName, 'Iced Latte');
      expect(sale.items.first.quantity, 2);
      expect(sale.items.first.subtotal, 5.50);
    });
  });
}
