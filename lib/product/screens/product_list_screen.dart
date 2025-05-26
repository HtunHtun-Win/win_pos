import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/product/screens/product_add_screen.dart';
import 'package:win_pos/product/screens/product_detail_screen.dart';
import 'package:win_pos/product/screens/product_edit_screen.dart';
import '../../category/controller/category_controller.dart';

// ignore: must_be_immutable
class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  ProductController productController = Get.put(ProductController());
  CategoryController categoryController = Get.put(CategoryController());
  String filterInput = '';
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search...",
              ),
              onChanged: (value) {
                productController.maxCount = 10;
                refreshController.loadFailed();
                filterInput = value;
                productController.getAll(input: value);
              },
            ),
          ),
          Expanded(
            child: Obx(() => productController.showProducts.isEmpty
                ? const Text("No Data")
                : SmartRefresher(
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
                      if (productController.maxCount ==
                          productController.products.length) {
                        refreshController.loadNoData();
                      } else {
                        productController.loadMore();
                        refreshController.loadComplete();
                      }
                    },
                    child: ListView.builder(
                      itemCount: productController.showProducts.length,
                      itemBuilder: (context, index) {
                        var product = productController.showProducts[index];
                        return listItem(product);
                      },
                    ),
                  )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refreshController.loadFailed();
          Get.to(() => ProductAddScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget listItem(ProductModel product) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              Get.to(() => ProductDetailScreen(product));
            },
            icon: Icons.menu,
          ),
          SlidableAction(
            onPressed: (_) {
              Get.to(() => ProductEditScreen(product));
            },
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (_) {
              Get.defaultDialog(
                  title: "Delete!",
                  middleText: "Are you sure to delete!",
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          productController.deleteProduct(product);
                          productController.getAll(input: filterInput);
                          Get.back();
                        },
                        child: const Text("Delete")),
                    
                  ]);
            },
            icon: Icons.delete,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                Text(product.quantity.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(product.code.toString())),
                Expanded(
                    child: Text(
                  product.category_name.toString(),
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                Text(product.sale_price.toString()),
              ],
            ),
            const Divider()
          ],
        ),
      ),
    );
  }
}
