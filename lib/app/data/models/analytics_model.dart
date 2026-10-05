library;

class DashboardSummaryModel {
  final double totalSales;
  final int totalOrders;
  final double totalExpenses;
  final double netProfit;
  final int lowStockCount;
  final int totalCustomers;
  final int totalProducts;

  DashboardSummaryModel({
    this.totalSales = 0.0,
    this.totalOrders = 0,
    this.totalExpenses = 0.0,
    this.netProfit = 0.0,
    this.lowStockCount = 0,
    this.totalCustomers = 0,
    this.totalProducts = 0,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalSales: (json['income'] is num)
          ? (json['income'] as num).toDouble()
          : ((json['total_sales'] is num)
              ? (json['total_sales'] as num).toDouble()
              : double.tryParse('${json['income'] ?? json['total_sales']}') ?? 0.0),
      totalOrders: json['total_transactions'] is int
          ? json['total_transactions']
          : (json['total_orders'] is int
              ? json['total_orders']
              : int.tryParse('${json['total_transactions'] ?? json['total_orders']}') ?? 0),
      totalExpenses: (json['expense'] is num)
          ? (json['expense'] as num).toDouble()
          : ((json['total_expenses'] is num)
              ? (json['total_expenses'] as num).toDouble()
              : double.tryParse('${json['expense'] ?? json['total_expenses']}') ?? 0.0),
      netProfit: (json['net_profit'] is num)
          ? (json['net_profit'] as num).toDouble()
          : double.tryParse('${json['net_profit']}') ?? 0.0,
      lowStockCount: json['low_stock_count'] is int
          ? json['low_stock_count']
          : int.tryParse('${json['low_stock_count']}') ?? 0,
      totalCustomers: json['total_customers'] is int
          ? json['total_customers']
          : int.tryParse('${json['total_customers']}') ?? 0,
      totalProducts: json['total_products'] is int
          ? json['total_products']
          : int.tryParse('${json['total_products']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'income': totalSales,
      'total_sales': totalSales,
      'total_transactions': totalOrders,
      'total_orders': totalOrders,
      'expense': totalExpenses,
      'total_expenses': totalExpenses,
      'net_profit': netProfit,
      'low_stock_count': lowStockCount,
      'total_customers': totalCustomers,
      'total_products': totalProducts,
    };
  }
}

class DailyTransactionModel {
  final String date;
  final String dayName;
  final double totalRevenue;
  final int orderCount;

  DailyTransactionModel({
    required this.date,
    required this.dayName,
    required this.totalRevenue,
    required this.orderCount,
  });

  factory DailyTransactionModel.fromJson(Map<String, dynamic> json) {
    return DailyTransactionModel(
      date: json['date']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
      totalRevenue: (json['total_sales'] is num)
          ? (json['total_sales'] as num).toDouble()
          : ((json['total_revenue'] is num)
              ? (json['total_revenue'] as num).toDouble()
              : double.tryParse('${json['total_sales'] ?? json['total_revenue']}') ?? 0.0),
      orderCount: json['transactions_count'] is int
          ? json['transactions_count']
          : (json['order_count'] is int
              ? json['order_count']
              : int.tryParse('${json['transactions_count'] ?? json['order_count']}') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day_name': dayName,
      'total_sales': totalRevenue,
      'total_revenue': totalRevenue,
      'transactions_count': orderCount,
      'order_count': orderCount,
    };
  }
}
