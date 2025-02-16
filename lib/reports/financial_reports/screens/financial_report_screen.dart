import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/financial_reports/screens/bank_payment_screen.dart';
import 'package:win_pos/reports/financial_reports/screens/cash_flow_screen.dart';
import 'package:win_pos/reports/financial_reports/screens/profit_lose_screen.dart';

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Reports"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListItem(context, const Icon(Icons.attach_money), "Profit and Lose", () {
            Get.to(() => ProfitLoseScreen());
          }),
          // ListItem(context, const Icon(Icons.attach_money), "Cash flow", () {
          //   Get.to(() => const CashFlowScreen());
          // }),
          ListItem(context, const Icon(Icons.attach_money), "Bank Payment", () {
            Get.to(() => BankPaymentScreen());
          }),
        ],
      ),
    );
  }

  Widget ListItem(context, icon, text, VoidCallback fun) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(1),
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: icon,
        iconColor: Colors.white,
        title: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onTap: fun,
      ),
    );
  }
}
