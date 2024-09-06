import 'package:win_pos/product/models/product_model.dart';

class CartModel{
  ProductModel product;
  int quantity;
  int? sprice;

  CartModel({
    required this.product,
    required this.quantity,
    this.sprice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': this.product,
      'quantity': this.quantity,
      'sprice': this.sprice,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      product: map['product'] as ProductModel,
      quantity: map['quantity'] as int,
      sprice: map['sprice'] as int,
    );
  }
}