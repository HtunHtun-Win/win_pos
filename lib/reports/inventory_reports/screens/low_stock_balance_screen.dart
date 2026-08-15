import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/reports/inventory_reports/controller/inventory_report_controller.dart';
import '../../../category/controller/category_controller.dart';
import '../../../product/models/product_model.dart';

// ignore: must_be_immutable
class LowStockBalanceScreen extends StatelessWidget {
  LowStockBalanceScreen({super.key});

  InventoryReportController reportController = InventoryReportController();
  CategoryController categoryController = Get.put(CategoryController());
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    reportController.getLowQtyStock();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Quantity Stock'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search item...',
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                refreshController.loadFailed();
                reportController.searchProducts(value);
              },
            ),
          ),
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
                      reportController.products.length) {
                    refreshController.loadNoData();
                  } else {
                    reportController.productLoadMore();
                    refreshController.loadComplete();
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reportController.showProducts.length,
                  itemBuilder: (context, index) {
                    var item = reportController.showProducts[index];
                    return stockItem(product: item);
                  },
                ),
              );
            })),
        ],
      ),
    );
  }

  Widget stockItem({required ProductModel product}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(product.name!)),
                Text('${product.quantity} pcs'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.code!),
                Text('${product.sale_price} MMK'),
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
            reportController.getLowQtyStock(catId: selected.id);
          } else {
            reportController.getLowQtyStock();
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
