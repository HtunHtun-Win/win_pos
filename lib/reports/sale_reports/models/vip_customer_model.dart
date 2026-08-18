import 'dart:convert';

VipCustomerModel vipCustomerModelFromJson(String str) =>
    VipCustomerModel.fromJson(json.decode(str));

String vipCustomerModelToJson(VipCustomerModel data) =>
    json.encode(data.toJson());

class VipCustomerModel {
  String name;
  int total;

  VipCustomerModel({
    required this.name,
    required this.total,
  });

  factory VipCustomerModel.fromJson(Map<String, dynamic> json) =>
      VipCustomerModel(
        name: json["customer"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "total": total,
      };
}
