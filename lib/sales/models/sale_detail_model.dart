class SaleDetailModel {
  int? id;
  String? product;
  int? quantity;
  int? price;
  int? pprice;

  SaleDetailModel({
      this.id,
      this.product,
      this.quantity,
      this.price,
      this.pprice,
      });

  factory SaleDetailModel.fromMap(Map map) {
    return SaleDetailModel(
      id : map['id'],
      product: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      pprice: map['pprice'],
    );
  }
}
