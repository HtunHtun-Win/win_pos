import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/product/screens/product_screen.dart';
import '../models/product_model.dart';

// ignore: unused_import
import 'dart:developer' as dev;

class PurchasePriceScreen extends StatelessWidget {
  final ProductModel product;

  PurchasePriceScreen(this.product, {super.key});

  final ProductController productController = Get.find();

  @override
  Widget build(BuildContext context) {
    productController.getPurchasePriceLog(product.id!);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name.toString()),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              await Get.defaultDialog(
                  title: "Clear Zero Quantity",
                  content: const Text("This action effect on all product"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () async {
                          await productController.clearZeroQty();
                          Get.back();
                          productController.getPurchasePriceLog(product.id!);
                        },
                        child: const Text("Confirm")),
                  ]);
            },
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: const Text(
              "Purchase Price History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          rowTitle("Qty", "Price", "Total"),
          Obx(
            () {
              return Expanded(
                child: ListView.builder(
                  itemCount: productController.purchasePriceLog.length,
                  itemBuilder: (context, index) {
                    var item = productController.purchasePriceLog[index];
                    return listTile(
                      item['quantity'].toString(),
                      item['price'].toString(),
                      "${item['quantity'] * item['price']}",
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget listTile(String qty, String price, String total) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(qty)),
          Expanded(child: Text(price)),
          Expanded(child: Text(total)),
        ],
      ),
    );
  }

  Widget rowTitle(String qty, String price, String total) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(
            qty,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
          Expanded(
              child: Text(
            price,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
          Expanded(
              child: Text(
            total,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
        ],
      ),
    );
  }
}
