import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/product/controller/product_log_controller.dart';
import 'package:win_pos/product/models/product_log_model.dart';
import 'package:intl/intl.dart';
import 'package:win_pos/product/screens/product_adjust_add_screen.dart';

// ignore: must_be_immutable
class ProductLedgerScreen extends StatelessWidget {
  int id;
  ProductLedgerScreen({super.key,required this.id});
  ProductLogController productLogController = Get.put(ProductLogController());
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    // productLogController.getAll();
    productLogController.getAllLog(map: daterangeCalculate("today"),pid: id);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ledger"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          datePicker(),
          Expanded(
            child: Obx(() => SmartRefresher(
              controller: refreshController,
              enablePullUp: true,
              enablePullDown: false,
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
                if (productLogController.maxCount ==
                    productLogController.logs.length) {
                  refreshController.loadNoData();
                } else {
                  productLogController.loadMore();
                  refreshController.loadComplete();
                }
              },
              child: ListView.builder(
                itemCount: productLogController.showLogs.length,
                itemBuilder: (context, index) {
                  var productLog = productLogController.showLogs[index];
                  return listItem(productLog);
                },
              ),
            )),
          )
        ],
      ),
    );
  }

  Widget listItem(ProductLogModel log) {
    DateTime date = DateTime.parse(log.date.toString());
    var fdate = DateFormat("yyyy-MM-dd h:m:s a");
    var finalDate = fdate.format(date);
    return ListTile(
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
          productLogController.maxCount=10;
          refreshController.loadFailed();
          if (value == 'all') {
            productLogController.getAllLog(pid: id);
          } else {
            productLogController.getAllLog(map: daterangeCalculate(value!),pid: id);
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
