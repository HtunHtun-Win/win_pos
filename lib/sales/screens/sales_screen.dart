import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import 'package:win_pos/sales/screens/sales_save_screen.dart';
// import 'package:win_pos/user/controllers/user_controller.dart';

class SalesScreen extends StatelessWidget {
  SalesScreen({super.key});
  final SalesController salesController = Get.find();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(children: [
          userInput(context),
          Expanded(
            child: Stack(
              children: [
                //show cart items
                Obx(() {
                  return ListView.builder(
                    itemCount: salesController.cart.length,
                    itemBuilder: (context, index) {
                      var item = salesController.cart[index];
                      return selectedItem(context, item, index);
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

  Widget userInput(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search...",
                isDense: true,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                salesController.getAllProduct(input: value);
              },
            ),
          ),
          IconButton(
              onPressed: () {
                searchController.text = "";
                salesController.products.clear();
              },
              icon: const Icon(Icons.cancel))
        ],
      ),
    );
  }

  Widget searchItem(context, ProductModel product) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          tileColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }

  Widget selectedItem(BuildContext context,CartModel item, index) {
    var total = item.product.sale_price! * item.quantity;
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              quantityAlert(context, item, index);
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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.product.name.toString()),
              Text(total.toString())
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("${item.sprice} x ${item.quantity}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget totalAmountWidget(context, amount) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: theme.colorScheme.primary.withValues(alpha:0.06),
      child: ListTile(
        title: Text("Total : $amount", style: theme.textTheme.titleMedium),
        trailing: ElevatedButton(
          onPressed: () {
            if (salesController.cart.isNotEmpty) {
              Get.to(() => SalesSaveScreen());
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cart is Empty"),
                  content: const Text("Please add items to the cart before checkout."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('Checkout'),
        ),
      ),
    );
  }

  void quantityAlert(BuildContext context, CartModel item, index) {
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
                if (quantity <= item.product.quantity!) {
                  salesController.cart[index].quantity = quantity;
                } else {
                  qtyController.text = item.product.quantity.toString();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Not Enough Stock"),
                      content: Text("Remaining stock is ${item.product.quantity!}"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
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
                if (qty <= item.product.quantity!) {
                  qtyController.text = qty.toString();
                  salesController.cart[index].quantity++;
                } else {
                  qtyController.text = item.product.quantity.toString();
                  Get.snackbar(
                    "Alert!",
                    "Not enough stock!",
                    backgroundColor: Colors.black.withValues(alpha:0.5),
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
