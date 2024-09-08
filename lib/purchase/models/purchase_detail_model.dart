class PurchaseDetailModel {
  String? product;
  int? quantity;
  int? price;

  PurchaseDetailModel({this.product, this.quantity, this.price});

  factory PurchaseDetailModel.fromMap(Map map) {
    return PurchaseDetailModel(
      product: map['name'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
