class PurchaseDetailModel {
  int? id;
  String? product;
  int? quantity;
  int? price;

  PurchaseDetailModel({this.id,this.product, this.quantity, this.price});

  factory PurchaseDetailModel.fromMap(Map map) {
    return PurchaseDetailModel(
      id : map['id'],
      product: map['name'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
