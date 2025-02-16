import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';

class ExpenseAddScreen extends StatelessWidget {
  ExpenseAddScreen({super.key});
  final ExpenseController _expenseController = Get.find();
  int flowType = 2;

  @override
  Widget build(BuildContext context) {
    TextEditingController amountController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController noteController = TextEditingController();
    amountController.text = '0';
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                onSave(amountController, descController, noteController);
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userInput(
                "Amount",
                amountController,
                type: TextInputType.number,
                filter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]
            ),
            userInput("Description", descController, type: TextInputType.text),
            userInput("Note", noteController, type: TextInputType.text),
            flowDropdown()
          ],
        ),
      ),
    );
  }

  void onSave(
      TextEditingController amountController,
      TextEditingController descController,
      TextEditingController noteController) async {
    var result = await _expenseController.addExpense(
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

  Widget userInput(text, controller, {type,filter}) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: TextField(
        keyboardType: type,
        inputFormatters: filter,
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
        initialSelection: 2,
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
