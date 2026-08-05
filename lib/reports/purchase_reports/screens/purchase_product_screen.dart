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
                    return reportListTile(item: item);
                  },
                ),
              );
            }),
          ),
          Obx(() {
            return Container(
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  'Total: ${purchaseController.itemTotalAmount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.onPrimary.withAlpha(24),
            ),
            child: Icon(Icons.inventory_2,
                color: theme.colorScheme.onPrimary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Browse purchased items with filters for category and date.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget reportListTile({required PurchaseItemModel item}) {
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
            Expanded(child: Text(item.name.toString())),
            Expanded(child: Text(item.quantity.toString())),
            Expanded(child: Text(item.price.toString())),
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
        items: const [
          'All',
          'Today',
          'Yesterday',
          'ThisMonth',
          'LastMonth',
          'ThisYear',
          'LastYear',
        ],
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

  Map<String, String> daterangeCalculate(String selectedDate) {
    String startDate = '';
    String endDate = '';
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    if (selectedDate == 'today') {
      startDate = today.toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == 'yesterday') {
      startDate = DateTime(now.year, now.month, now.day - 1).toString();
      endDate = DateTime(now.year, now.month, now.day).toString();
    } else if (selectedDate == 'thismonth') {
      startDate = DateTime(now.year, now.month, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == 'lastmonth') {
      startDate = DateTime(now.year, now.month - 1, 1).toString();
      endDate = DateTime(now.year, now.month, 1).toString();
    } else if (selectedDate == 'thisyear') {
      startDate = DateTime(now.year, 1, 1).toString();
      endDate = DateTime(now.year, now.month, now.day + 1).toString();
    } else if (selectedDate == 'lastyear') {
      startDate = DateTime(now.year - 1, 1, 1).toString();
      endDate = DateTime(now.year, 1, 1).toString();
    }
    return {'start': startDate, 'end': endDate};
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text('Name',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(
            child: Text('Qty',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(
            child: Text('Amount',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold))),
      ],
    );
  }
}
