import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/reports/inventory_reports/controller/inventory_report_controller.dart';
import 'package:win_pos/reports/inventory_reports/models/sale_log_model.dart';

// ignore: must_be_immutable
class SaleLogScreen extends StatefulWidget {
  SaleLogScreen({super.key});

  @override
  State<SaleLogScreen> createState() => _SaleLogScreenState();
}

class _SaleLogScreenState extends State<SaleLogScreen> {
  InventoryReportController reportController =
      Get.put(InventoryReportController());
  ProductController productController = Get.put(ProductController());

  final refreshController = RefreshController();

  int? pId;
  String date = 'today';

  @override
  void initState() {
    super.initState();
    reportController.getSaleLog(date: daterangeCalculate('today'));
    productController.getAll();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale Price History"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: Obx((){
              return productList();
            }),
          ),
          datePicker(),
          const ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: Text("Name")),
                Expanded(flex: 2, child: Text("Old")),
                Expanded(flex: 2, child: Text("New")),
                Expanded(flex: 2, child: Text("Date")),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: Obx(() {
            return SmartRefresher(
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
                if (reportController.saleLog.length >=
                    reportController.maxCount) {
                  refreshController.loadNoData();
                } else {
                  reportController.saleLogLoadMore();
                  refreshController.loadComplete();
                }
              },
              child: ListView.builder(
                  itemCount: reportController.showSalelog.length,
                  itemBuilder: (context, index) {
                    var saleLog = reportController.showSalelog[index];
                    return reportListTile(saleLog: saleLog);
                  }),
            );
          }))
        ],
      ),
    );
  }

  Widget reportListTile({required SaleLogModel saleLog}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(saleLog.name.toString())),
            Expanded(flex: 2, child: Text(saleLog.oldPrice.toString())),
            Expanded(flex: 2, child: Text(saleLog.newPrice.toString())),
            Expanded(
                flex: 2,
                child: Text(DateFormat("dd/MM/yyyy HH:mm")
                    .format(DateTime.parse(saleLog.createdAt)))),
          ],
        ),
      ),
    );
  }

  Widget productList() {
    return DropdownSearch<String>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Product",
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
      items: ['All'] +
          productController.products
              .map((product) => product.name.toString())
              .toList(),
      onChanged: (value) {
        // salesController.maxCount = 10;
        refreshController.resetNoData();
        if (value != 'All') {
          final product = productController.products.firstWhere(
                (product) => product.name == value,
          );
          pId = product.id;
        } else {
          pId = null;
        }
        reportController.getSaleLog(
          pid: pId,
          date: date != 'all' ? daterangeCalculate(date) : null,
        );
      },
      selectedItem: "All",
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Product",
          ),
        ),
      ),
    );
  }

  Widget datePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownMenu(
        initialSelection: "today",
        width: double.infinity,
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
          // salesController.maxCount = 10;
          refreshController.resetNoData();
          date = value!;
          reportController.getSaleLog(
            pid: pId,
            date: value != 'all' ? daterangeCalculate(date) : null,
          );
        },
      ),
    );
  }

  Map<String, String> daterangeCalculate(String type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    late DateTime start;
    late DateTime end;

    switch (type) {
      case "today":
        start = today;
        end = today.add(const Duration(days: 1));
        break;

      case "yesterday":
        start = today.subtract(const Duration(days: 1));
        end = today;
        break;

      case "thismonth":
        start = DateTime(now.year, now.month, 1);
        end = today.add(const Duration(days: 1));
        break;

      case "lastmonth":
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 1);
        break;

      case "thisyear":
        start = DateTime(now.year, 1, 1);
        end = today.add(const Duration(days: 1));
        break;

      case "lastyear":
        start = DateTime(now.year - 1, 1, 1);
        end = DateTime(now.year, 1, 1);
        break;

      default:
        start = today;
        end = today.add(const Duration(days: 1));
    }

    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }
}
