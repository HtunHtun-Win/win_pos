import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  ProductModel product;
  ProductDetailScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name.toString()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
        ],
      ),
    );
  }

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
