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
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Balance With Valuation"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: categoryBox(context),
          ),
          Expanded(
            child: Obx((){
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
                if (reportController.maxCount ==
                    reportController.productsValue.length) {
                  refreshController.loadNoData();
                } else {
                  reportController.productValueLoadMore();
                  refreshController.loadComplete();
                }
              },
              child: ListView.builder(
                  itemCount: reportController.showProductsValue.length,
                  itemBuilder: (context,index){
                    var item = reportController.showProductsValue[index];
                    return stockItem(product: item);
                  }
              ),
            );
          }),
          ),
          Obx((){
            // salesController.getTotal();
            return Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child:ListTile(
                title:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Total",style: TextStyle(color: Colors.white),),
                    Text(
                      "${reportController.totalValue.toString()} MMK",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget stockItem({required ProductValueModel product}){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                   product.name,
                 style: const TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w500,
                 ),
               ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${product.quantity.toString()} pcs"),
                    Text("${product.price.toString()} MMK"),
                    Text("${product.total.toString()} MMK"),
                  ],
                ),
            ]
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget categoryBox(BuildContext context) {
    return Obx(
          ()=>DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Category",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: ['All']+categoryController.categories.map((category) => category.name.toString()).toList(),
        onChanged: (String? selectedCategory) {
          refreshController.loadFailed();
          if(selectedCategory!='All'){
            final selected = categoryController.categories.firstWhere(
                  (category) => category.name == selectedCategory,
            );
            reportController.getWithValue(catId: selected.id);
          }else{
            reportController.getWithValue();
          }
        },
        selectedItem: "All", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Search Category",
            ),
          ),
        ),
      ),
    );
  }
}
