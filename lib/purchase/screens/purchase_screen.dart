import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/purchase/controller/purchase_controller.dart';
import 'package:win_pos/purchase/screens/purchase_save_screen.dart';
import 'package:win_pos/sales/models/cart_model.dart';

// ignore: must_be_immutable
class PurchaseScreen extends StatelessWidget {
  PurchaseScreen({super.key});
  PurchaseController purchaseController = Get.find();
  TextEditingController searchController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController ppriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase"),
      ),
      body: Column(
        children: [
          userInput(context),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  return ListView.builder(
                    itemCount: purchaseController.cart.length,
                    itemBuilder: (context, index) {
                      var item = purchaseController.cart[index];
                      return selectedItem(context, item, index);
                    },
                  );
                }),
                Obx(() {
                  return purchaseController.products.isEmpty
                      ? const SizedBox.shrink()
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
          Obx(() => totalAmountWidget(context, purchaseController.totalAmount)),
        ],
      ),
    );
  }

  Widget userInput(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                purchaseController.getAllProduct(input: value);
              },
            ),
          ),
          IconButton(
            onPressed: () {
              searchController.clear();
              purchaseController.products.clear();
            },
            icon: const Icon(Icons.cancel),
          )
        ],
      ),
    );
  }

  Widget searchItem(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        child: ListTile(
          tileColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(product.name.toString())),
              Text(product.purchase_price.toString()),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.code.toString()),
              Text(product.quantity.toString()),
            ],
          ),
          onTap: () {
            purchaseController.addToCart(product);
            purchaseController.products.clear();
            purchaseController.getTotal();
            searchController.clear();
          },
        ),
      ),
    );
  }

  Widget selectedItem(BuildContext context, CartModel item, index) {
    final theme = Theme.of(context);
    var total = item.pprice! * item.quantity;
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
              purchaseController.cart.remove(item);
              purchaseController.getTotal();
            },
            icon: Icons.delete,
            foregroundColor: Colors.red,
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 1,
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.product.name.toString(), style: theme.textTheme.titleMedium)),
              Text(total.toString(), style: theme.textTheme.titleMedium),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${item.pprice} x ${item.quantity}"),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: theme.colorScheme.primary.withValues(alpha:0.08),
      child: ListTile(
        title: Text("Total : $amount", style: theme.textTheme.titleMedium),
        trailing: ElevatedButton(
          onPressed: () {
            if (purchaseController.cart.isNotEmpty) {
              Get.to(() => PurchaseSaveScreen());
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
    ppriceController.text = item.pprice.toString();
    qtyController.text = item.quantity.toString();
    Get.defaultDialog(
      title: "${item.product.name!} (${item.product.quantity!} pcs)",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: ppriceController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Purchase price',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              int price = int.tryParse(value) != null && int.parse(value) > 0 ? int.parse(value) : 1;
              purchaseController.cart[index].pprice = price;
              purchaseController.cart.refresh();
              purchaseController.getTotal();
            },
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
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
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) {
                    int quantity = int.tryParse(value) != null && int.parse(value) > 0 ? int.parse(value) : 1;
                    purchaseController.cart[index].quantity = quantity;
                    purchaseController.cart.refresh();
                    purchaseController.getTotal();
                  },
                  textAlign: TextAlign.center,
                ),
              ),
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
          ),
        ],
      ),
    );
  }
}
