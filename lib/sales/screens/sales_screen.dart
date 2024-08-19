import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

class SalesScreen extends StatelessWidget {
  SalesScreen({super.key});
  SalesController salesController = Get.put(SalesController());
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sale"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            userInput(),
            Expanded(
              child: Stack(
                children: [
                  Obx((){
                    return ListView.builder(
                      itemCount: salesController.products.length,
                      itemBuilder: (context,index){
                        var product = salesController.products[index];
                        return searchItem(product);
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userInput(){
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
          hintText: "Search..."
      ),
      onChanged: (value){
        salesController.getAllProduct(input: value);
      },
    );
  }

  Widget searchItem(ProductModel product){
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(product.name.toString()),
          Text(product.sale_price.toString())
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(product.code.toString()),
          Text(product.quantity.toString())
        ],
      ),
      onTap: (){
        salesController.products.clear();
      },
    );
  }
}
