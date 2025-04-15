class SaleDetailModel {
  int? id;
  String? product;
  int? quantity;
  int? price;

  SaleDetailModel({
      this.id,
      this.product,
      this.quantity,
      this.price
      });

  factory SaleDetailModel.fromMap(Map map) {
    return SaleDetailModel(
      id : map['id'],
      product: map['name'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
