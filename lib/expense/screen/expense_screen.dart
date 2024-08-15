import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:jue_pos/core/widgets/cust_drawer.dart';
import 'package:jue_pos/expense/controller/expense_controller.dart';
import 'package:jue_pos/expense/model/expense_model.dart';
import 'package:jue_pos/user/controllers/user_controller.dart';
import 'package:jue_pos/user/models/user.dart';

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
      ),
      drawer: CustDrawer(
        user: User.fromMap(userController.current_user.toJson())
      ),
      body: Obx(
        (){
          return ListView.builder(
            itemCount: _expenseController.expense_list.length,
            itemBuilder: (context,index){
              var expense = _expenseController.expense_list[index];
              return listItem(expense);
            },
          );
        }
      ),
    );
  }

  Widget listItem(ExpenseModel expense){
    DateTime date = DateTime.parse(expense.createdDate.toString());
    var format = DateFormat("yyyy-MM-dd h:m:s a");
    var finalDate = format.format(date);
    return Container(
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
    );
  }
}