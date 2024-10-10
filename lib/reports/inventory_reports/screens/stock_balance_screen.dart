import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/inventory_reports/controller/inventory_report_controller.dart';
import '../../../category/controller/category_controller.dart';
import '../../../product/models/product_model.dart';

class StockBalanceScreen extends StatelessWidget {
  StockBalanceScreen({super.key});
  InventoryReportController reportController = InventoryReportController();
  CategoryController categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    reportController.getAll();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Stock Balance"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: categoryBox(context),
          ),
          Expanded(child: Obx((){
            return ListView.builder(
              itemCount: reportController.products.length,
                itemBuilder: (context,index){
                  var item = reportController.products[index];
                  return stockItem(product: item);
                }
            );
          }))
        ],
      ),
    );
  }

  Widget stockItem({required ProductModel product}){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.name!),
              Text("${product.quantity.toString()} pcs"),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.code!),
              Text("${product.sale_price.toString()} mmk"),
            ],
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
          if(selectedCategory!='All'){
            final selected = categoryController.categories.firstWhere(
                  (category) => category.name == selectedCategory,
            );
            reportController.getAll(catId: selected.id);
          }else{
            reportController.getAll();
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
