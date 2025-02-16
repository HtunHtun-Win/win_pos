class SaleDetailModel {
  String? product;
  int? quantity;
  int? price;

  SaleDetailModel({
      this.product,
      this.quantity,
      this.price
      });

  factory SaleDetailModel.fromMap(Map map) {
    return SaleDetailModel(
      product: map['name'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
