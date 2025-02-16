import 'package:win_pos/product/models/product_model.dart';

class CartModel {
  ProductModel product;
  int quantity;
  int? sprice;
  int? pprice;

  CartModel({
    required this.product,
    required this.quantity,
    this.sprice,
    this.pprice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product,
      'quantity': quantity,
      'sprice': sprice,
      'pprice': pprice,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      product: map['product'] as ProductModel,
      quantity: map['quantity'] as int,
      sprice: map['sprice'],
      pprice: map['pprice'],
    );
  }
}
