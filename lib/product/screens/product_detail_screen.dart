import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/product/screens/product_ledger_screen.dart';
import 'purchase_price_screen.dart';
import '../models/product_model.dart';

// ignore: unused_import
import 'dart:developer' as dev;

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name.toString()),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                PurchasePriceScreen(product),
                transition: Transition.zoom,
                duration: const Duration(milliseconds: 300),
              );
            },
            icon: const Icon(Icons.price_change_rounded),
          ),
          IconButton(
            onPressed: () {
              Get.to(
                ProductLedgerScreen(id: product.id!),
                transition: Transition.zoom,
                duration: const Duration(milliseconds: 300),
              );
            },
            icon: const Icon(Icons.event_note),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          listTile("Code", product.code.toString()),
          listTile(
              "Description",
              product.description!.isNotEmpty
                  ? product.description.toString()
                  : '-'),
          listTile("Quantity", product.quantity.toString()),
          listTile("Category", product.category_name.toString()),
          listTile("Purchase Price", product.purchase_price.toString()),
          listTile("Sale Price", product.sale_price.toString()),
          // purchasePriceButton(),
        ],
      ),
    );
  }

  // Widget purchasePriceButton() {
  //   return Container(
  //     width: double.infinity,
  //     margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  //     decoration: BoxDecoration(
  //       color: Colors.blueAccent,
  //       borderRadius: BorderRadius.circular(5),
  //     ),
  //     child: TextButton(
  //       onPressed: () {
  //         Get.to(
  //           PurchasePriceScreen(product),
  //           transition: Transition.zoom,
  //           duration: const Duration(milliseconds: 300),
  //         );
  //       },
  //       child: const Text(
  //         "Check Purchase Price",
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget listTile(String desc, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            desc,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
