import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/controller/product_log_controller.dart';
import 'package:win_pos/product/models/product_log_model.dart';
import 'package:intl/intl.dart';
import 'package:win_pos/product/screens/product_adjust_add_screen.dart';

class ProductAdjustScreen extends StatelessWidget {
  ProductAdjustScreen({super.key});
  ProductLogController productLogController = Get.put(ProductLogController());

  @override
  Widget build(BuildContext context) {
    productLogController.getAll();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          datePicker(),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: productLogController.logs.length,
                  itemBuilder: (context, index) {
                    var productLog = productLogController.logs[index];
                    return listItem(productLog);
                  },
                )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => ProductAdjustAddScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget listItem(ProductLogModel log) {
    DateTime date = DateTime.parse(log.date.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m:s a");
    var finalDate = fdate.format(date);
    return Container(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(log.product.toString()),
            Text(log.user.toString()),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${log.quantity.toString()} : pcs (${log.note.toString()})'),
            Text(finalDate),
          ],
        ),
      ),
    );
  }

  Widget datePicker() {
    return Container(
      padding: const EdgeInsets.only(top: 5, right: 10),
      child: DropdownMenu(
        initialSelection: "all",
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
          if (value == 'all') {
            productLogController.getAll();
          } else {
            productLogController.getAll(map: daterangeCalculate(value!));
          }
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
