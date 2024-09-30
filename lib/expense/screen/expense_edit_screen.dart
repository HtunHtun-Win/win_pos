import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';
import 'package:win_pos/expense/model/expense_model.dart';

class ExpenseEditScreen extends StatelessWidget {
  ExpenseModel expense;
  ExpenseEditScreen(this.expense, {super.key});
  final ExpenseController _expenseController = Get.find();
  int flowType = 2;

  @override
  Widget build(BuildContext context) {
    TextEditingController amountController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController noteController = TextEditingController();
    amountController.text = expense.amount.toString();
    descController.text = expense.description!;
    noteController.text = expense.note!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                onUpdate(amountController, descController, noteController);
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userInput("Amount", amountController, type: TextInputType.number),
            userInput("Description", descController, type: TextInputType.text),
            userInput("Note", noteController, type: TextInputType.text),
            flowDropdown()
          ],
        ),
      ),
    );
  }

  void onUpdate(
      TextEditingController amountController,
      TextEditingController descController,
      TextEditingController noteController) async {
    var result = await _expenseController.updateExpense(
        expense.id!,
        int.parse(amountController.text),
        descController.text,
        noteController.text,
        flowType,
        1);
    if (result['msg'] == "null") {
      Get.snackbar("Null!", "Amount and description can't be empty");
    } else if (result['msg'] == 'success') {
      Get.back();
    }
  }

  Widget userInput(text, controller, {type}) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: TextField(
        keyboardType: type,
        controller: controller,
        decoration: InputDecoration(
          label: Text(text),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget flowDropdown() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: DropdownMenu(
        width: double.infinity,
        initialSelection: expense.type,
        dropdownMenuEntries: const [
          DropdownMenuEntry(value: 1, label: "Income"),
          DropdownMenuEntry(value: 2, label: "Expense"),
        ],
        onSelected: (value) {
          flowType = value!;
        },
      ),
    );
  }
}
