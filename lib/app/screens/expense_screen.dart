import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';
import '../widgets/bottom_search_dock.dart';

class ExpenseItem {
  final String id;
  String title;
  double amount;
  String category;
  String date;
  String paymentMethod;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.paymentMethod = 'Cash',
  });
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String searchQuery = '';
  final searchController = TextEditingController();
  String selectedCategory = 'All';
  bool isLoading = false;

  final List<ExpenseItem> expenses = [];

  @override
  void initState() {
    super.initState();
    fetchExpensesFromApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchExpensesFromApi() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final res = await api.getExpenses();
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          expenses.clear();
          for (var e in res.data!) {
            final dateStr = '${e.createdAt.day}/${e.createdAt.month} ${e.createdAt.hour.toString().padLeft(2, '0')}:${e.createdAt.minute.toString().padLeft(2, '0')}';
            expenses.add(ExpenseItem(
              id: e.id.toString(),
              title: e.title,
              amount: e.amount,
              category: e.category,
              date: dateStr,
              paymentMethod: 'Cash',
            ));
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  double get totalExpense => expenses.fold(0.0, (sum, e) => sum + e.amount);

  List<ExpenseItem> get filteredExpenses {
    var list = expenses;
    if (selectedCategory != 'All') {
      list = list.where((e) => e.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((e) => e.title.toLowerCase().contains(q) || e.category.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _showAddExpenseDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'Raw Materials';
    String payMethod = 'Cash';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'add_expense_title'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : Colors.grey,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'expense_title_label'.tr,
                      prefixIcon: const Icon(
                        Icons.description_outlined,
                        color: primaryOrange,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'expense_amount_label'.tr,
                      prefixIcon: const Icon(
                        Icons.attach_money_rounded,
                        color: primaryOrange,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppThemes.darkSurface
                          : const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'expense_category_label'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'Raw Materials',
                          'Utilities',
                          'Packaging',
                          'Maintenance',
                          'Rent',
                        ].map((cat) {
                          final isSelected = category == cat;
                          return ChoiceChip(
                            selected: isSelected,
                            label: Text(cat),
                            selectedColor: primaryOrange,
                            backgroundColor: isDark
                                ? AppThemes.darkSurface
                                : Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? AppThemes.darkTextPrimary
                                        : Colors.black87),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) =>
                                setSheetState(() => category = cat),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'payment_method_label'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Cash', 'ABA Bank', 'Wing / Bakong'].map((m) {
                      final isSelected = payMethod == m;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(m),
                          selectedColor: const Color(0xFFD32F2F),
                          backgroundColor: isDark
                              ? AppThemes.darkSurface
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppThemes.darkTextPrimary
                                      : Colors.black87),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) => setSheetState(() => payMethod = m),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final title = titleCtrl.text.trim();
                        final amount =
                            double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                        if (title.isEmpty || amount <= 0) return;

                        Get.back();
                        try {
                          final api = ApiService.to;
                          await api.createExpense({
                            'title': title,
                            'amount': amount,
                            'category': category,
                            'note': payMethod,
                          });
                          fetchExpensesFromApi();
                        } catch (_) {}

                        Get.snackbar(
                          'expense_recorded'.tr,
                          '${'expense_recorded_msg'.tr}: \$${amount.toStringAsFixed(2)}',
                          backgroundColor: const Color(0xFF1B5E20),
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        'save_expense'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'expenses'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomSearchDock(
        controller: searchController,
        hintText: 'search_expense_hint'.tr,
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        actionIcon: Icons.add_card_rounded,
        actionTooltip: 'add_expense_title'.tr,
        onActionTap: _showAddExpenseDialog,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Expense Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'total_expense_this_month'.tr,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${expenses.length} ${'expense_transactions_count'.tr}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                      'All',
                      'Raw Materials',
                      'Utilities',
                      'Packaging',
                      'Maintenance',
                    ].map((c) {
                      final isSelected = selectedCategory == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(c),
                          selectedColor: primaryOrange,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppThemes.darkTextPrimary
                                      : Colors.black87),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          backgroundColor: isDark
                              ? AppThemes.darkCard
                              : Colors.white,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? primaryOrange
                                  : (isDark
                                        ? AppThemes.darkBorder
                                        : Colors.grey.shade200),
                            ),
                          ),
                          onSelected: (_) =>
                              setState(() => selectedCategory = c),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Expense Items List
            ...filteredExpenses.map((exp) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark
                      ? Border.all(color: AppThemes.darkBorder)
                      : Border.all(color: AppThemes.lightBorder),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${exp.category} • ${exp.paymentMethod} • ${exp.date}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-\$${exp.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (filteredExpenses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'no_data'.tr,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ],
),
    );
  }
}
