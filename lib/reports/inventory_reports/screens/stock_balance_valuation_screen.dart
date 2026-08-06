import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/reports/inventory_reports/controller/inventory_report_controller.dart';
import 'package:win_pos/reports/inventory_reports/models/product_value_model.dart';
import '../../../category/controller/category_controller.dart';

// ignore: must_be_immutable
class StockBalanceValuationScreen extends StatelessWidget {
  StockBalanceValuationScreen({super.key});
  InventoryReportController reportController = InventoryReportController();
  CategoryController categoryController = Get.put(CategoryController());
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    reportController.getWithValue();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance With Valuation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: categoryBox(context),
          ),
          const SizedBox(height: 12),
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
                  if (reportController.maxCount ==
                      reportController.productsValue.length) {
                    refreshController.loadNoData();
                  } else {
                    reportController.productValueLoadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reportController.showProductsValue.length,
                  itemBuilder: (context, index) {
                    var item = reportController.showProductsValue[index];
                    return stockItem(product: item);
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
                  'Total: ${reportController.totalValue} MMK',
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
          colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
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
            child: Icon(Icons.pie_chart, color: theme.colorScheme.onPrimary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Valuation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review stock value with quantity, unit price and totals.',
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

  Widget stockItem({required ProductValueModel product}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${product.quantity} pcs'),
                Text('${product.price} MMK'),
                Text('${product.total} MMK'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryBox(BuildContext context) {
    return Obx(
      () => DropdownSearch<String>(
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
        onChanged: (String? selectedCategory) {
          refreshController.loadFailed();
          if (selectedCategory != 'All') {
            final selected = categoryController.categories.firstWhere(
              (category) => category.name == selectedCategory,
            );
            reportController.getWithValue(catId: selected.id);
          } else {
            reportController.getWithValue();
          }
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
      ),
    );
  }
}
