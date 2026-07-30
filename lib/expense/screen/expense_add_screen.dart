import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';

// ignore: must_be_immutable
class ExpenseAddScreen extends StatelessWidget {
  ExpenseAddScreen({super.key});

  final ExpenseController _expenseController = Get.find();
  TextEditingController amountController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  int flowType = 2;

  @override
  Widget build(BuildContext context) {
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
                  // Obx(() {
                  //   return _expenseController.searchList.isEmpty
                  //       ? Container()
                  //       : ListView.builder(
                  //     itemCount: _expenseController.searchList.length,
                  //     itemBuilder: (context, index) {
                  //       var cat = _expenseController.searchList[index];
                  //       return searchItem(context, cat);
                  //     },
                  //   );
                  // }),
                ],
              ),
            ),
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
      1,
    );
    if (result['msg'] == "null") {
      Get.dialog(
          AlertDialog(
            title: const Text("Null!"),
            content: const Text("Amount and description can't be empty."),
            actions: [
              TextButton(onPressed: (){Get.back();}, child: const Text("OK"))
            ],
          )
      );
    } else if (result['msg'] == 'success') {
      Get.back();
    }
  }

  Widget userInput(text, controller, {type, filter, hint, onChange}) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: TextField(
        keyboardType: type,
        inputFormatters: filter,
        controller: controller,
        decoration: InputDecoration(
            label: Text(text),
            border: const OutlineInputBorder(),
            hint: Text(hint ?? "")),
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
        selectedItem: "Expense", // Optional: Can be null if no initial selection is required
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
