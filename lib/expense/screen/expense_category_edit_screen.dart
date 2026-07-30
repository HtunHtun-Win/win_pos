import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/expense/controller/expense_controller.dart';

// ignore: must_be_immutable
class ExpenseCategoryEditScreen extends StatelessWidget {
  ExpenseCategoryEditScreen({super.key});

  final ExpenseController _expenseController = ExpenseController();
  TextEditingController descController = TextEditingController();
  TextEditingController newValueController = TextEditingController();
  int flowType = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense Category"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () async{
                if(newValueController.text.isEmpty) return;
                int result = await _expenseController.updateDesc(descController.text, newValueController.text);
                if(result != 0){
                  Get.dialog(
                      AlertDialog(
                        title: const Text("Success!"),
                        content: const Text("Exp category name successfully renamed."),
                        actions: [
                          TextButton(onPressed: (){Get.back();}, child: const Text("OK"))
                        ],
                      )
                  );
                }
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userInput("Old Value", descController, type: TextInputType.text,
                onChange: (value) {
                  _expenseController.getDescByKeyword(value);
                }),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      userInput("New Value", newValueController,
                          type: TextInputType.text),
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
