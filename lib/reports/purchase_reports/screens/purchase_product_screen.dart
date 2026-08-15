import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/reports/purchase_reports/models/purchase_item_model.dart';
import '../../../category/controller/category_controller.dart';
import '../controller/purchase_report_controller.dart';

// ignore: must_be_immutable
class PurchaseProductScreen extends StatelessWidget {
  PurchaseProductScreen({super.key});

  PurchaseReportController purchaseController =
      Get.put(PurchaseReportController());
  CategoryController categoryController = CategoryController();
  String date = 'today';
  int? catId;
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    purchaseController.getPurchaseItems(date: daterangeCalculate('today'));
    categoryController.getAll();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: categoryBox(context)),
                const SizedBox(width: 12),
                Expanded(child: datePicker()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _TableHeader(),
          ),
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
                  if (purchaseController.maxCount ==
                      purchaseController.items.length) {
                    refreshController.loadNoData();
                  } else {
                    purchaseController.itemLoadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: purchaseController.showItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    var item = purchaseController.showItems[index];
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
                        "${purchaseController.itemTotalAmount} MMK",
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

  Widget reportListTile({required int index, required PurchaseItemModel item}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(flex: 1, child: Text(index.toString())),
            Expanded(flex: 2, child: Text(item.name.toString())),
            Expanded(flex: 2, child: Text(item.quantity.toString())),
            Expanded(flex: 2, child: Text(item.price.toString())),
          ],
        ),
      ),
    );
  }

  Widget categoryBox(BuildContext context) {
    return Obx(() {
      return DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Category',
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
          purchaseController.getPurchaseItems(
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

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 1,
                child: Text('No.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold))),
            Expanded(
                flex: 2,
                child: Text('Name',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold))),
            Expanded(
                flex: 2,
                child: Text('Qty',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold))),
            Expanded(
                flex: 2,
                child: Text('Amount',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
