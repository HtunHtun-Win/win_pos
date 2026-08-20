import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/product/controller/product_log_controller.dart';
import 'package:win_pos/product/models/product_log_model.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProductLedgerScreen extends StatelessWidget {
  int id;
  ProductLedgerScreen({super.key, required this.id});
  ProductLogController productLogController = Get.put(ProductLogController());
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    productLogController.getAllLog(map: daterangeCalculate('today'), pid: id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: datePicker(context)),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Obx(() {
                      return Text(
                        '${productLogController.showLogs.length}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                enablePullDown: false,
                footer: CustomFooter(builder: (context, LoadStatus? mode) {
                  Widget body = Container();
                  if (mode == LoadStatus.loading) {
                    body = const CircularProgressIndicator();
                  } else if (mode == LoadStatus.noMore) {
                    body = const Text('No more data');
                  }
                  return SizedBox(
                    height: 55,
                    child: Center(child: body),
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
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: productLogController.showLogs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    var productLog = productLogController.showLogs[index];
                    return listItem(productLog);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem(ProductLogModel log) {
    DateTime date = DateTime.parse(log.date.toString());
    var fdate = DateFormat('yyyy-MM-dd h:mm:ss a');
    var finalDate = fdate.format(date);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(log.product.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(log.user.toString(),
                  style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                      '${log.quantity.toString()} pcs • ${log.note.toString()}',
                      style: const TextStyle(color: Colors.black87))),
              Text(finalDate,
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
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
        items: const [
          "All",
          "Today",
          "Yesterday",
          "ThisMonth",
          "LastMonth",
          "ThisYear",
          "LastYear",
          // "Custom"
        ],
        onChanged: (value) async {
          var sValue = value!.toLowerCase();
          productLogController.maxCount = 10;
          refreshController.loadFailed();
          if (value == 'All') {
            productLogController.getAllLog(pid: id);
          } else {
            productLogController.getAllLog(
                map: daterangeCalculate(sValue), pid: id);
          }
        },
        selectedItem:
            "Today", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: false,
        ),
      ),
    );
  }

  // Widget datePicker() {
  //   return DropdownMenu(
  //     width: double.infinity,
  //     initialSelection: 'today',
  //     dropdownMenuEntries: const [
  //       DropdownMenuEntry(value: 'all', label: 'All'),
  //       DropdownMenuEntry(value: 'today', label: 'Today'),
  //       DropdownMenuEntry(value: 'yesterday', label: 'Yesterday'),
  //       DropdownMenuEntry(value: 'thismonth', label: 'This month'),
  //       DropdownMenuEntry(value: 'lastmonth', label: 'Last month'),
  //       DropdownMenuEntry(value: 'thisyear', label: 'This year'),
  //       DropdownMenuEntry(value: 'lastyear', label: 'Last year'),
  //     ],
  //     onSelected: (value) {
  //       productLogController.maxCount = 10;
  //       refreshController.loadFailed();
  //       if (value == 'all') {
  //         productLogController.getAllLog(pid: id);
  //       } else {
  //         productLogController.getAllLog(
  //             map: daterangeCalculate(value!), pid: id);
  //       }
  //     },
  //   );
  // }
}
