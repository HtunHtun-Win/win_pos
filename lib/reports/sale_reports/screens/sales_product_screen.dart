import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/reports/sale_reports/models/sale_item_model.dart';
import '../../../category/controller/category_controller.dart';
import '../controller/sales_report_controller.dart';

// ignore: must_be_immutable
class SalesProductScreen extends StatelessWidget {
  SalesProductScreen({super.key});

  final SalesReportController salesController =
      Get.put(SalesReportController());
  final CategoryController categoryController = CategoryController();
  String date = 'all';
  int? catId;
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    salesController.getSaleItems(date: daterangeCalculate('today'));
    categoryController.getAll();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(child: categoryBox(context)),
                const SizedBox(width: 12),
                Expanded(child: datePicker()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('No.',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 2,
                        child: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 2,
                        child: Text('Qty',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 2,
                        child: Text('Amount',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              return SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                enablePullDown: false,
                footer: CustomFooter(builder: (context, LoadStatus? mode) {
                  Widget body = Container();
                  if (mode == LoadStatus.loading) {
                    body = const CircularProgressIndicator();
                  } else if (mode == LoadStatus.noMore) {
                    body = const Text('No More Data...');
                  }
                  return SizedBox(
                    height: 55,
                    child: Center(child: body),
                  );
                }),
                onLoading: () {
                  if (salesController.maxCount ==
                      salesController.items.length) {
                    refreshController.loadNoData();
                  } else {
                    salesController.itemLoadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: salesController.showItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = salesController.showItems[index];
                    return reportListTile(index: index + 1, item: item);
                  },
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "${salesController.itemTotalAmount.value} MMK",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reportListTile({required int index, required SaleItemModel item}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                index.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(flex: 2, child: Text(item.name.toString())),
            Expanded(flex: 2, child: Text(item.quantity.toString())),
            Expanded(
              flex: 2,
              child: Text(
                item.price.toString(),
                // textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryBox(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      return DropdownSearch<String>(
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Category',
            filled: true,
            fillColor: theme.cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        items: ['All'] +
            categoryController.categories
                .map((category) => category.name.toString())
                .toList(),
        onChanged: (value) {
          refreshController.loadFailed();
          if (value != 'All') {
            final selected = categoryController.categories.firstWhere(
              (category) => category.name == value,
            );
            catId = selected.id;
          } else {
            catId = null;
          }
          salesController.getSaleItems(
            catId: catId,
            date: date != 'all' ? daterangeCalculate(date) : null,
          );
        },
        selectedItem: 'All',
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Search Category',
            ),
          ),
        ),
      );
    });
  }

  Widget datePicker() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: dateOptionList,
        onChanged: (value) {
          refreshController.loadFailed();
          date = value!.toLowerCase();
          salesController.getSaleItems(
            catId: catId,
            date: date != 'all' ? daterangeCalculate(date) : null,
          );
        },
        selectedItem: 'Today',
        popupProps: const PopupProps.menu(
          showSearchBox: false,
        ),
      ),
    );
  }
}
