import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/purchase/controller/purchase_controller.dart';
import 'package:win_pos/purchase/screens/purchase_save_screen.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class PurchaseScreen extends StatelessWidget {
  PurchaseScreen({super.key});
  PurchaseController purchaseController = Get.find();
  TextEditingController searchController = TextEditingController();
  TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                if (purchaseController.cart.isNotEmpty) {
                  Get.to(() => PurchaseSaveScreen());
                } else {
                  Get.snackbar(
                    "Cart is empty!",
                    "Select product!",
                    backgroundColor: Colors.black.withOpacity(.5),
                    colorText: Colors.white,
                  );
                }
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: [
          userInput(),
          Expanded(
            child: Stack(
              children: [
                //show cart items
                Obx(() {
                  return ListView.builder(
                    itemCount: purchaseController.cart.length,
                    itemBuilder: (context, index) {
                      var item = purchaseController.cart[index];
                      return selectedItem(item, index);
                    },
                  );
                }),
                //for search result
                Obx(() {
                  return purchaseController.products.isEmpty
                      ? Container()
                      : ListView.builder(
                          itemCount: purchaseController.products.length,
                          itemBuilder: (context, index) {
                            var product = purchaseController.products[index];
                            return searchItem(context, product);
                          },
                        );
                }),
              ],
            ),
          ),
          Obx(() {
            return totalAmountWidget(context, purchaseController.totalAmount);
          })
        ]),
      ),
    );
  }

  Widget userInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search...",
            ),
            onChanged: (value) {
              purchaseController.getAllProduct(input: value);
            },
          ),
        ),
        IconButton(
            onPressed: () {
              searchController.text = "";
            },
            icon: const Icon(Icons.cancel))
      ],
    );
  }

  Widget searchItem(context, ProductModel product) {
    return Container(
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
          purchaseController.addToCart(product);
          purchaseController.products.clear();
          purchaseController.getTotal();
          searchController.text = "";
        },
      ),
    );
  }

  Widget selectedItem(CartModel item, index) {
    var total = item.sprice! * item.quantity;
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
              purchaseController.cart.remove(item);
              purchaseController.getTotal();
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
        title: Text("Total : $amount"),
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
                if (qty > 0) {
                  qtyController.text = qty.toString();
                  purchaseController.cart[index].quantity--;
                }
                purchaseController.cart.refresh();
                purchaseController.getTotal();
              },
              icon: const Icon(Icons.remove),
            ),
            Expanded(
                child: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int quantity = int.parse(value) > 0 ? int.parse(value) : 1;
                purchaseController.cart[index].quantity = quantity;
                purchaseController.cart.refresh();
                purchaseController.getTotal();
              },
              textAlign: TextAlign.center,
            )),
            IconButton(
              onPressed: () {
                int qty = int.parse(qtyController.text);
                qty++;
                qtyController.text = qty.toString();
                purchaseController.cart[index].quantity++;
                purchaseController.cart.refresh();
                purchaseController.getTotal();
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ));
  }
}
