import 'package:flutter/material.dart';

import '../models/product_model.dart';
class ProductDetailScreen extends StatelessWidget {
  ProductModel product;
  ProductDetailScreen(this.product);

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
          listTile("Description", product.description!.length>0 ? product.description.toString() : '-'),
          listTile("Quantity", product.quantity.toString()),
          listTile("Category", product.category_name.toString()),
          listTile("Purchase Price", product.purchase_price.toString()),
          listTile("Sale Price", product.sale_price.toString()),
        ],
      ),
    );
  }
  
  Widget listTile(String desc,String value){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            desc,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
