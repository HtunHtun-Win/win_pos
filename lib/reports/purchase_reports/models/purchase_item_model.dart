import 'dart:convert';

PurchaseItemModel PurchaseItemModelFromJson(String str) => PurchaseItemModel.fromJson(json.decode(str));

String PurchaseItemModelToJson(PurchaseItemModel data) => json.encode(data.toJson());

class PurchaseItemModel {
  String name;
  int quantity;
  int price;

  PurchaseItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) => PurchaseItemModel(
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
