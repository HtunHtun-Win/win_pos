import 'dart:convert';

SaleItemModel saleItemModelFromJson(String str) => SaleItemModel.fromJson(json.decode(str));

String saleItemModelToJson(SaleItemModel data) => json.encode(data.toJson());

class SaleItemModel {
  String name;
  int quantity;
  int price;

  SaleItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
    name: json["name"],
    quantity: json["quantity"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "quantity": quantity,
    "price": price,
  };
}
