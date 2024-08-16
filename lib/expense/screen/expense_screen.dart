import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';
import 'package:win_pos/expense/model/expense_model.dart';
import 'package:win_pos/expense/screen/expense_add_screen.dart';
import 'package:win_pos/expense/screen/expense_edit_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

class ExpenseScreen extends StatelessWidget {
  ExpenseScreen({super.key});
  UserController userController = Get.find();
  ExpenseController _expenseController = Get.put(ExpenseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Income ~ Expense"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: ()=>Get.to(()=>ExpenseAddScreen()), 
            icon: const Icon(Icons.add)
            )
        ],
      ),
      drawer: CustDrawer(
        user: User.fromMap(userController.current_user.toJson())
      ),
      body: Obx(
        (){
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Income : ${_expenseController.totalIncome}",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  Text(
                    "Expense : ${_expenseController.totalExpense}",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                ],
              ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _expenseController.expense_list.length,
                  itemBuilder: (context,index){
                    var expense = _expenseController.expense_list[index];
                    return listItem(expense);
                  },
            ),
              )
            ],
          );
        }
      ),
    );
  }

  Widget listItem(ExpenseModel expense){
    DateTime date = DateTime.parse(expense.createdDate.toString());
    var format = DateFormat("yyyy-MM-dd h:m:s a");
    var finalDate = format.format(date);
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_){
              Get.to(()=>ExpenseEditScreen(expense));
            },
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (_){
              Get.defaultDialog(
                onCancel: () => Get.back(),
                onConfirm: () {
                  _expenseController.deleteExpense(expense.id!);
                  Get.back();
                }
              );
            },
            icon: Icons.delete,
          )
        ]
      ),
      child: Container(
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      color: expense.type==1 ? Colors.blue[200] : Colors.red[200],
      child: 
      ListTile(
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
}