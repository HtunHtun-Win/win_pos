import 'dart:convert';

SaleLogModel saleLogModelFromJson(String str) => SaleLogModel.fromJson(json.decode(str));

String saleLogModelToJson(SaleLogModel data) => json.encode(data.toJson());

class SaleLogModel {
  String name;
  int oldPrice;
  int newPrice;
  String createdAt;

  SaleLogModel({
    required this.name,
    required this.oldPrice,
    required this.newPrice,
    required this.createdAt,
  });

  factory SaleLogModel.fromJson(Map<String, dynamic> json) => SaleLogModel(
    name: json["name"],
    oldPrice: json["old_price"],
    newPrice: json["new_price"],
    createdAt: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "old_price": oldPrice,
    "new_price": newPrice,
    "date": createdAt,
  };
}
