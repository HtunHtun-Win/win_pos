import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';
import 'package:win_pos/expense/model/expense_model.dart';

// ignore: must_be_immutable
class ExpenseEditScreen extends StatelessWidget {
  final ExpenseModel expense;

  ExpenseEditScreen(this.expense, {super.key});

  final ExpenseController _expenseController = Get.find();
  TextEditingController amountController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  int flowType = 2;

  @override
  Widget build(BuildContext context) {
    amountController.text = expense.amount.toString();
    descController.text = expense.description!;
    noteController.text = expense.note!;
    flowType = expense.type!;
    _expenseController.setDateTime(expense.createdDate!);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return Text(_expenseController.dateTime.value);
                  }),
                  TextButton(
                      onPressed: () async {
                        DateTime? dateTime =
                        await showOmniDateTimePicker(context: context);
                        if (dateTime != null) {
                          _expenseController.setDateTime(dateTime.toString());
                        }
                      },
                      child: const Text("Select Date"))
                ],
              ),
            ),
            userInput("Amount", amountController,
                type: TextInputType.number,
                filter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
            userInput("Description", descController, type: TextInputType.text,
                onChange: (value) {
                  _expenseController.getDescByKeyword(value);
                }),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      userInput("Note (Optional)", noteController,
                          type: TextInputType.text),
                      flowDropdown(),
                    ],
                  ),
                  Obx(() {
                    return _expenseController.searchList.isEmpty
                        ? Container()
                        : ListView.builder(
                      itemCount: _expenseController.searchList.length,
                      itemBuilder: (context, index) {
                        var cat = _expenseController.searchList[index];
                        return searchItem(context, cat);
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onUpdate(
      TextEditingController amountController,
      TextEditingController descController,
      TextEditingController noteController) async {
    ExpenseModel model = ExpenseModel(
        id: expense.id!,
        amount: int.parse(amountController.text),
        description: descController.text,
        note: noteController.text,
        type: flowType,
        userId: 1,
        createdDate: _expenseController.dateTime.value);
    var result = await _expenseController.updateExpense(model);
    if (result['msg'] == "null") {
      Get.snackbar("Null!", "Amount and description can't be empty");
    } else if (result['msg'] == 'success') {
      Get.back();
    }
  }

  Widget userInput(text, controller, {type, filter, onChange}) {
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
        onChanged: onChange,
      ),
    );
  }

  Widget flowDropdown() {
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
        items: const ["Expense","Income"],
        onChanged: (value) {
          if(value=="Expense"){
            flowType = 2;
          }else{
            flowType = 1;
          }
        },
        selectedItem: expense.type==2 ? "Expense" : "Income", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: false,
        ),
      ),
    );
  }

  Widget searchItem(context, String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .5),
                offset: const Offset(5, 5),
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(name),
        onTap: () {
          descController.text = name;
          _expenseController.searchList.value = [];
        },
      ),
    );
  }
}
