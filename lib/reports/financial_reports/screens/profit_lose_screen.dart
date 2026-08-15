import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';
import 'package:win_pos/reports/financial_reports/controller/financial_report_controller.dart';

// ignore: must_be_immutable
class ProfitLoseScreen extends StatefulWidget {
  ProfitLoseScreen({super.key});

  @override
  State<ProfitLoseScreen> createState() => _ProfitLoseScreenState();
}

class _ProfitLoseScreenState extends State<ProfitLoseScreen> {
  FinancialReportController controller = FinancialReportController();
  final ExpenseController _expenseController = ExpenseController();
  String date = 'today';

  @override
  void initState() {
    super.initState();
    _expenseController.getAll(date: daterangeCalculate("today"));
  }

  @override
  Widget build(BuildContext context) {
    controller.getProfitLose(daterangeCalculate(date));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit / Loss'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withAlpha(24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.insights,
                        color: theme.colorScheme.onPrimary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profit & Loss',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Summary of income and expenses for the selected period.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: datePicker()),
                const SizedBox(width: 12),
                // Summary card with aggregates
                Expanded(
                  child: Obx(() {
                    var incomeTotal = 0;
                    var expenseTotal = 0;
                    for (var p in controller.profitLose) {
                      incomeTotal += (p.saleTotal) +
                          (p.purchaseDiscount) +
                          (_expenseController.totalIncome.value) -
                          (p.orgTotal);
                      expenseTotal += (p.saleDiscount) +
                          (p.lose.abs()) +
                          (_expenseController.totalExpense.value);
                    }
                    final profit = incomeTotal - expenseTotal;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Net', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text(
                            profit.toString(),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Content
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.profitLose.length,
                itemBuilder: (context, index) {
                  final p = controller.profitLose[index];
                  final income = (p.saleTotal) +
                      (p.purchaseDiscount) +
                      (_expenseController.totalIncome.value) -
                      (p.orgTotal);
                  final expense = (p.saleDiscount) +
                      (p.lose.abs()) +
                      (_expenseController.totalExpense.value);
                  final net = income - expense;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Income',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(income.toString(),
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _statTile(context, 'Sales Total', p.saleTotal),
                              _statTile(
                                  context, 'Sold Item Value', -(p.orgTotal)),
                              _statTile(context, 'Purchase Discount',
                                  p.purchaseDiscount),
                              Obx(() => _statTile(context, 'Income',
                                  _expenseController.totalIncome.value)),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Expense',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(expense.toString(),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _statTile(
                                  context, 'Sale Discount', -(p.saleDiscount)),
                              _statTile(context, 'Item Lose', -(p.lose.abs())),
                              _statTile(context, 'Expense',
                                  -(_expenseController.totalExpense.value)),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Profit / Loss',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text(net.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: net >= 0
                                          ? Colors.green
                                          : Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _statTile(context, String label, num value) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget datePicker() {
    List<String> dateOption = dateOptionList.where((e) => e != "All").toList();
    return Container(
      margin: const EdgeInsets.all(0),
      child: DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: dateOption,
        onChanged: (value) {
          date = value!.toLowerCase();
          controller.getProfitLose(daterangeCalculate(date));
          _expenseController.getAll(date: daterangeCalculate(date));
        },
        selectedItem: 'Today',
        popupProps: const PopupProps.menu(
          showSearchBox: false,
        ),
      ),
    );
  }
}
