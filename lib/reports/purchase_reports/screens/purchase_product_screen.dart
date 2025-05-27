import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/reports/purchase_reports/models/purchase_item_model.dart';
import '../../../category/controller/category_controller.dart';
import '../controller/purchase_report_controller.dart';

// ignore: must_be_immutable
class PurchaseProductScreen extends StatelessWidget {
  PurchaseProductScreen({super.key});
  PurchaseReportController purchaseController =
      Get.put(PurchaseReportController());
  CategoryController categoryController = CategoryController();
  String date = 'all';
  int? catId;
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    purchaseController.getPurchaseItems(date: daterangeCalculate('today'));
    categoryController.getAll();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Items"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: categoryBox(context),
          ),
          datePicker(),
          const ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Name")),
                Expanded(child: Text("Qty")),
                Expanded(child: Text("Amount")),
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
                if (purchaseController.maxCount ==
                    purchaseController.items.length) {
                  refreshController.loadNoData();
                } else {
                  purchaseController.itemLoadMore();
                  refreshController.loadComplete();
                }
              },
              child: ListView.builder(
                  itemCount: purchaseController.showItems.length,
                  itemBuilder: (context, index) {
                    var item = purchaseController.showItems[index];
                    return reportListTile(item: item);
                  }),
            );
          })),
          Obx(() {
            return Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      purchaseController.itemTotalAmount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget reportListTile({required PurchaseItemModel item}) {
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(item.name.toString())),
          Expanded(child: Text(item.quantity.toString())),
          Expanded(child: Text(item.price.toString())),
        ],
      ),
    );
  }

  Widget categoryBox(BuildContext context) {
    return Obx(() {
      return DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Category",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: ['All'] +
            categoryController.categories
                .map((category) => category.name.toString())
                .toList(),
        onChanged: (value) {
          if (value != 'All') {
            refreshController.loadFailed();
            final selected = categoryController.categories.firstWhere(
              (category) => category.name == value,
            );
            catId = selected.id;
          } else {
            catId = null;
          }
          purchaseController.getPurchaseItems(
            catId: catId,
            date: date != 'all' ? daterangeCalculate(date) : null,
          );
        },
        selectedItem:
            "All", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Search Category",
            ),
          ),
        ),
      );
    });
  }

  Widget datePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          refreshController.loadFailed();
          date = value!;
          purchaseController.getPurchaseItems(
            catId: catId,
            date: value != 'all' ? daterangeCalculate(date) : null,
          );
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
