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
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      isDense: true,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      productController.searchKeywork = value;
                      productController.maxCount = 10;
                      refreshController.loadFailed();
                      filterInput = value;
                      productController.getAll(input: value);
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  margin: const EdgeInsets.only(left: 6),
                  width: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Obx(() {
                    return Text(
                      '${productController.products.length} items',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    );
                  }),
                ),
              ],
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
                        return listItem(context, product);
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

  Widget listItem(context, ProductModel product) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              Get.to(() => ProductDetailScreen(product));
            },
            icon: Icons.menu,
            foregroundColor: color,
          ),
          SlidableAction(
            onPressed: (_) {
              Get.to(() => ProductEditScreen(product));
            },
            icon: Icons.edit,
            foregroundColor: color,
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
            foregroundColor: Colors.red,
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    product.name.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  )),
                  Text("${product.quantity} pcs"),
                ],
              ),
              const SizedBox(height: 8),
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
                  Text("${product.sale_price} MMK"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
