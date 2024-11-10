import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:win_pos/reports/financial_reports/controller/financial_report_controller.dart';
import 'package:win_pos/reports/financial_reports/models/profit_lose_model.dart';

class ProfitLoseScreen extends StatelessWidget {
  ProfitLoseScreen({super.key});

  FinancialReportController controller = FinancialReportController();
  String date = 'today';

  @override
  Widget build(BuildContext context) {
    controller.getProfitLose(daterangeCalculate(date));
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profit / Lose"),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: datePicker(),
              ),
              Expanded(
                child: Obx(() {
                  var income = 0;
                  var expense = 0;
                  return ListView.builder(
                    itemCount : controller.profitLose.length,
                    itemBuilder: (context,index){
                      var profitLose = controller.profitLose[index];
                      income = profitLose.saleTotal+profitLose.purchaseDiscount-profitLose.orgTotal;
                      expense = profitLose.saleDiscount+profitLose.lose.abs();
                      return Column(
                        children: [
                          const ListTile(
                              title: Text(
                                "Income",
                                style: TextStyle(fontWeight: FontWeight.w500,),)
                          ),
                          Column(
                            children: [
                              itemValue(label: "Sales Total", value: profitLose.saleTotal),
                              itemValue(label: "Sold Item Value", value: profitLose.orgTotal),
                              itemValue(label: "Purchase Discount", value: profitLose.purchaseDiscount),
                              itemValue(
                                  label: "Total",
                                  value: income
                              ),
                            ],
                          ),
                          const Divider(),
                          const ListTile(
                              title: Text(
                                "Expense",
                                style: TextStyle(fontWeight: FontWeight.w500,),)
                          ),
                          Column(
                            children: [
                              itemValue(label: "Sale Discount", value: -profitLose.saleDiscount),
                              itemValue(label: "Item Lose", value: -profitLose.lose.abs()),
                              itemValue(
                                  label: "Total",
                                  value: -expense
                              ),
                            ],
                          ),
                          const Divider(),
                          itemValue(label: "Profit/Lose", value: income-expense),
                        ],
                      );
                    }
                  );
                }),
              ),
            ]
        )
    );
  }

  Widget itemValue({required String label,required var value}){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
      child: Row(
          children: [
            Expanded(flex: 2,child: Text(label)),
            const Expanded(flex: 1,child: Text(':')),
            Expanded(flex: 2,child: Text(value!=null? value.toString() : '0'))
          ],
        ),
    );
  }

  Widget datePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownMenu(
        initialSelection: "today",
        width: double.infinity,
        dropdownMenuEntries: const [
          DropdownMenuEntry(value: "all", label: "All"),
          DropdownMenuEntry(value: "today", label: "Today"),
          DropdownMenuEntry(value: "yesterday", label: "Yesterday"),
          DropdownMenuEntry(value: "thismonth", label: "This month"),
          DropdownMenuEntry(value: "lastmonth", label: "Last month"),
          DropdownMenuEntry(value: "thisyear", label: "This year"),
          DropdownMenuEntry(value: "lastyear", label: "Last year"),
        ],
        onSelected: (value) {
          date = value!;
          controller.getProfitLose(daterangeCalculate(date));
        },
      ),
    );
  }

  Map daterangeCalculate(String selectedDate) {
    String startDate = "";
    String endDate = "";
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    if (selectedDate == "today") {
      startDate = today.toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == "yesterday") {
      startDate = DateTime(now.year, now.month, now.day - 1).toString();
      endDate = DateTime(now.year, now.month, now.day).toString();
    } else if (selectedDate == "thismonth") {
      startDate = DateTime(now.year, now.month, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == "lastmonth") {
      startDate = DateTime(now.year, now.month - 1, 1).toString();
      endDate = DateTime(now.year, now.month, 1).toString();
    } else if (selectedDate == "thisyear") {
      startDate = DateTime(now.year, 1, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == "lastyear") {
      startDate = DateTime(now.year - 1, 1, 1).toString();
      endDate = DateTime(now.year, 1, 1).toString();
    }
    return {'start': startDate, 'end': endDate};
  }
}
