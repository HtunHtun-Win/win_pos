import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';
import 'package:win_pos/expense/model/expense_model.dart';
import 'package:win_pos/expense/screen/expense_add_screen.dart';
import 'package:win_pos/expense/screen/expense_edit_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

import '../../core/functions/date_range_calc.dart';
import '../../purchase/screens/purchase_voucher_screen.dart';
import '../../sales/screens/sales_voucher_screen.dart';

class ExpenseScreen extends StatelessWidget {
  ExpenseScreen({super.key});
  final UserController userController = Get.find();
  final ExpenseController _expenseController = Get.put(ExpenseController());
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final user = User.fromMap(userController.current_user.toJson());
    _expenseController.getAll(date: daterangeCalculate("today"));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (user.role_id == 3) {
            Get.off(() => PurchaseVoucherScreen());
          } else {
            Get.off(() => SalesVoucherScreen());
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Income ~ Expense"),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
                onPressed: () {
                  refreshController.loadFailed();
                  Get.to(() => ExpenseAddScreen());
                },
                icon: const Icon(Icons.add))
          ],
        ),
        drawer: CustDrawer(user: user),
        body: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Income : ${_expenseController.totalIncome}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Expense : ${_expenseController.totalExpense}",
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              datePicker(),
              Expanded(
                child: SmartRefresher(
                  controller: refreshController,
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: CustomFooter(builder: (context, LoadStatus? mode) {
                    Widget body = Container();
                    if (mode == LoadStatus.loading) {
                      body = const CircularProgressIndicator();
                    } else if (mode == LoadStatus.noMore) {
                      body = const Text("No More Data...");
                    }
                    return SizedBox(
                      height: 55,
                      child: Center(
                        child: body,
                      ),
                    );
                  }),
                  onLoading: () {
                    if (_expenseController.maxCount ==
                        _expenseController.expenseList.length) {
                      refreshController.loadNoData();
                    } else {
                      _expenseController.loadMore();
                      refreshController.loadComplete();
                    }
                  },
                  child: ListView.builder(
                    itemCount: _expenseController.showExpenseList.length,
                    itemBuilder: (context, index) {
                      var expense = _expenseController.showExpenseList[index];
                      return listItem(expense);
                    },
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget listItem(ExpenseModel expense) {
    DateTime date = DateTime.parse(expense.createdDate.toString());
    var format = DateFormat("yyyy-MM-dd h:m:s a");
    var finalDate = format.format(date);
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: (_) {
            refreshController.loadFailed();
            Get.to(() => ExpenseEditScreen(expense));
          },
          icon: Icons.edit,
        ),
        SlidableAction(
          onPressed: (_) {
            refreshController.loadFailed();
            Get.defaultDialog(
                onCancel: () => Get.back(),
                onConfirm: () {
                  _expenseController.deleteExpense(expense.id!);
                  Get.back();
                });
          },
          icon: Icons.delete,
        )
      ]),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: expense.type == 1 ? Colors.blue[200] : Colors.red[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expense.description.toString()),
              Text(expense.amount.toString()),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expense.note.toString()),
              Text(finalDate),
            ],
          ),
        ),
      ),
    );
  }

  Widget datePicker() {
    return Container(
      padding: const EdgeInsets.only(top: 5, right: 10),
      child: DropdownMenu(
        initialSelection: "today",
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
          refreshController.loadFailed();
          _expenseController.date = value!;
          if (value == 'all') {
            _expenseController.getAll();
          } else {
            _expenseController.getAll(date: daterangeCalculate(value));
          }
        },
      ),
    );
  }
}
