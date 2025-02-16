import 'dart:convert';

ProfitLoseModel profitLoseModelFromJson(String str) => ProfitLoseModel.fromJson(json.decode(str));

String profitLoseModelToJson(ProfitLoseModel data) => json.encode(data.toJson());

class ProfitLoseModel {
  int saleTotal;
  int orgTotal;
  int saleDiscount;
  int purchaseDiscount;
  int lose;

  ProfitLoseModel({
    required this.saleTotal,
    required this.orgTotal,
    required this.saleDiscount,
    required this.purchaseDiscount,
    required this.lose,
  });

  factory ProfitLoseModel.fromJson(Map<String, dynamic> json) => ProfitLoseModel(
    saleTotal: json["sale_total"] ?? 0,
    orgTotal: json["org_total"] ?? 0,
    saleDiscount: json["sale_discount"] ?? 0,
    purchaseDiscount: json["purchase_discount"] ?? 0,
    lose: json["lose"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "sale_total": saleTotal,
    "org_total": orgTotal,
    "sale_discount": saleDiscount,
    "purchase_discount": purchaseDiscount,
    "lose": lose,
  };
}
