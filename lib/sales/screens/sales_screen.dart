import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import 'package:win_pos/sales/screens/sales_save_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class SalesScreen extends StatelessWidget {
  SalesScreen({super.key});
  SalesController salesController = Get.find();
  TextEditingController searchController = TextEditingController();
  TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                if (salesController.cart.isNotEmpty) {
                  Get.to(() => SalesSaveScreen());
                }else{
                  Get.snackbar(
                  "Cart is empty!", "Select product!",
                    backgroundColor: Colors.black.withOpacity(.5),
                    colorText: Colors.white,
                  );
                }
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(children: [
          userInput(),
          Expanded(
            child: Stack(
              children: [
                //show cart items
                Obx(() {
                  return ListView.builder(
                    itemCount: salesController.cart.length,
                    itemBuilder: (context, index) {
                      var item = salesController.cart[index];
                      return selectedItem(item, index);
                    },
                  );
                }),
                //for search result
                Obx(() {
                  return salesController.products.isEmpty
                      ? Container()
                      : ListView.builder(
                          itemCount: salesController.products.length,
                          itemBuilder: (context, index) {
                            var product = salesController.products[index];
                            return searchItem(context, product);
                          },
                        );
                }),
              ],
            ),
          ),
          Obx(() {
            return totalAmountWidget(context, salesController.totalAmount);
          })
        ]),
      ),
    );
  }

  Widget userInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search...",
              ),
              onChanged: (value) {
                salesController.getAllProduct(input: value);
              },
            ),
          ),
          IconButton(
              onPressed: () {
                searchController.text = "";
              },
              icon: const Icon(Icons.cancel))
        ],
      ),
    );
  }

  Widget searchItem(context, ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.5),
                offset: const Offset(5, 5),
                blurRadius: 10)
          ]),
      child: ListTile(
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
        onTap: () {
          salesController.addToCart(product);
          salesController.products.clear();
          salesController.getTotal();
          searchController.text = "";
        },
      ),
    );
  }

  Widget selectedItem(CartModel item, index) {
    var total = item.product.sale_price! * item.quantity;
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              quantityAlert(item, index);
            },
            icon: Icons.edit,
          ),
          SlidableAction(
              onPressed: (_) {
                salesController.cart.remove(item);
                salesController.getTotal();
              },
              icon: Icons.delete,
            foregroundColor: Colors.red,
          )
        ],
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.product.name.toString()),
            Text(total.toString())
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${item.sprice}x${item.quantity}"),
          ],
        ),
      ),
    );
  }

  Widget totalAmountWidget(context, amount) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.inversePrimary,
      child: ListTile(
        title: Text("Total : $amount",
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  void quantityAlert(CartModel item, index) {
    qtyController.text = item.quantity.toString();
    Get.defaultDialog(
        title: "${item.product.name!} (${item.product.quantity!} pcs)",
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                int qty = int.parse(qtyController.text);
                qty--;
                if (qty > 0){
                  qtyController.text = qty.toString();
                  salesController.cart[index].quantity--;
                }
                salesController.cart.refresh();
                salesController.getTotal();
              },
              icon: const Icon(Icons.remove),
            ),
            Expanded(
                child: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                int quantity = int.parse(value) > 0 ? int.parse(value) : 1;
                if (quantity <= item.product.quantity!){
                  salesController.cart[index].quantity = quantity;
                }else{
                  Get.back();
                  Get.snackbar(
                    "Alert!","Not enough stock!",
                    backgroundColor: Colors.black.withOpacity(.5),
                    colorText: Colors.white,
                  );
                }
                salesController.cart.refresh();
                salesController.getTotal();
              },
              textAlign: TextAlign.center,
            )),
            IconButton(
              onPressed: () {
                int qty = int.parse(qtyController.text);
                qty++;
                if (qty <= item.product.quantity!){
                  qtyController.text = qty.toString();
                  salesController.cart[index].quantity++;
                }else{
                  Get.back();
                  Get.snackbar(
                    "Alert!","Not enough stock!",
                    backgroundColor: Colors.black.withOpacity(.5),
                    colorText: Colors.white,
                  );
                }
                salesController.cart.refresh();
                salesController.getTotal();
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ));
  }
}
