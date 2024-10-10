import 'dart:convert';

ProductValueModel productValueModelFromJson(String str) => ProductValueModel.fromJson(json.decode(str));

String productValueModelToJson(ProductValueModel data) => json.encode(data.toJson());

class ProductValueModel {
  String name;
  int quantity;
  int price;
  int total;

  ProductValueModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory ProductValueModel.fromJson(Map<String, dynamic> json) => ProductValueModel(
    name: json["name"],
    quantity: json["quantity"],
    price: json["price"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "quantity": quantity,
    "price": price,
    "total": total,
  };
}
