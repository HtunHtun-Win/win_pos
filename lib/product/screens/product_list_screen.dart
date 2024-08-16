import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/product/screens/product_add_screen.dart';
import 'package:win_pos/product/screens/product_detail_screen.dart';
import 'package:win_pos/product/screens/product_edit_screen.dart';
import '../../category/controller/category_controller.dart';

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});
  ProductController productController = Get.put(ProductController());
  CategoryController categoryController = Get.put(CategoryController());
  String filterInput = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search...",
              ),
              onChanged: (value){
                filterInput = value!;
                productController.getAll(input: value!);
              },
              // onTap: () => productController.getAll(),
            ),
          ),
          Expanded(
            child: Obx(()=>ListView.builder(
              itemCount: productController.products.length,
              itemBuilder: (context,index){
                var product = productController.products[index];
                return listItem(product);
              },
            )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.to(()=>ProductAddScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget listItem(ProductModel product){
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_){
              Get.to(()=>ProductDetailScreen(product));
            },
            icon: Icons.menu,
          ),
          SlidableAction(
            onPressed: (_){
              Get.to(()=>ProductEditScreen(product));
            },
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (_){
              Get.defaultDialog(
                title: "Delete!",
                middleText: "Are you sure to delete!",
                actions: [
                  TextButton(onPressed: (){
                    productController.deleteProduct(product);
                    productController.getAll(input: filterInput);
                    Get.back();
                  }, child: Text("save")),
                  TextButton(onPressed: (){
                    Get.back();
                  }, child: Text("Cancel"))
                ]
              );
            },
            icon: Icons.delete,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.name.toString(),style: TextStyle(fontSize: 18),),
                Text(product.quantity.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.code.toString()),
                Text(product.category_name.toString()),
                Text(product.sale_price.toString()),
              ],
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
