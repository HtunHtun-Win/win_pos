import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/core/functions/pretty_date_format.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';
import 'package:win_pos/expense/model/expense_model.dart';
import 'package:win_pos/expense/screen/expense_add_screen.dart';
import 'package:win_pos/expense/screen/expense_edit_screen.dart';
import 'package:win_pos/purchase/screens/purchase_voucher_screen.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

class ExpenseScreen extends StatelessWidget {
  ExpenseScreen({super.key});

  final UserController userController = Get.find();
  final ExpenseController _expenseController = Get.put(ExpenseController());
  final refreshController = RefreshController();
  String date = "today";
  String desc = "all";

  @override
  Widget build(BuildContext context) {
    final user = User.fromMap(userController.current_user.toJson());
    _expenseController.getAll(date: daterangeCalculate("today"));
    _expenseController.getAllDesc();
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
                      "In : ${_expenseController.totalIncome}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_expenseController.totalBalance}",
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Exp : ${_expenseController.totalExpense}",
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                child: Row(
                  spacing: 10,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: catPicker()),
                    Expanded(child: datePicker(context)),
                  ],
                ),
              ),
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
            // Get.defaultDialog(
            //     onCancel: () => Get.back(),
            //     onConfirm: () {
            //       _expenseController.deleteExpense(expense.id!);
            //       Get.back();
            //     });
            Get.dialog(
              AlertDialog(
                title: const Text('Delete Expense'),
                content: const Text('Are you sure you want to delete this expense?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _expenseController.deleteExpense(expense.id!);
                      Get.back();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          icon: Icons.delete,
        )
      ]),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            )
          ]
      ),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expense.description.toString()),
              Text(expense.type == 1 ? "-${expense.amount}" : "+${expense.amount}",style: TextStyle(
                color: expense.type == 1 ? Colors.red : Colors.green
              ),),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expense.note.toString()),
              Text(prettyDate(expense.createdDate.toString())),
            ],
          ),
        ),
      ),
    );
  }

  Widget catPicker() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            // labelText: "Select Type",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: ["All",..._expenseController.descList],
        onChanged: (value) {
          var sValue = value!.toLowerCase();
          desc = sValue;
          refreshController.loadFailed();
          if (sValue == 'all') {
            if (date == "all") {
              _expenseController.getAll();
            } else {
              _expenseController.getAll(date: daterangeCalculate(date));
            }
          } else {
            if(date=="all"){
              _expenseController.getAll(desc: sValue);
            }else{
              _expenseController.getAll(
                  date: daterangeCalculate(date), desc: sValue);
            }
          }
        },
        selectedItem: "All", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: false,
        ),
      ),
    );
  }

  Widget datePicker(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            // labelText: "Select Type",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: const ["All","Today","Yesterday","ThisMonth","LastMonth","ThisYear","LastYear","Custom"],
        onChanged: (value) async {
          var sValue = value!.toLowerCase();
          date = sValue;
          refreshController.loadFailed();
          _expenseController.date = sValue;
          if (sValue == 'all') {
            if (desc == "all") {
              _expenseController.getAll();
            } else {
              _expenseController.getAll(desc: desc);
            }
          } else if (sValue == 'custom') {
            List<DateTime>? dateTimeList =
                await showOmniDateTimeRangePicker(context: context);
            if (dateTimeList != null) {
              String startDate = DateTime(dateTimeList[0].year,
                  dateTimeList[0].month, dateTimeList[0].day)
                  .toString();
              String endDate = DateTime(dateTimeList[1].year,
                  dateTimeList[1].month, dateTimeList[1].day + 1)
                  .toString();
              _expenseController.getAll(
                  date: {'start': startDate, 'end': endDate}, desc: desc);
            }
          } else {
            _expenseController.getAll(
                date: daterangeCalculate(sValue), desc: desc);
          }
        },
        selectedItem: "Today", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: false,
        ),
      ),
    );
  }
}
