class SaleDetailModel {
  int? id;
  int? sales_id;
  int? product_id;
  int? quantity;
  int? price;
  int? pprice;

  SaleDetailModel(
      {this.id,
      this.sales_id,
      this.product_id,
      this.quantity,
      this.price,
      this.pprice});

  SaleDetailModel.fromMap(Map map) {
    SaleDetailModel(
      id: map['id'],
      sales_id: map['sales_id'],
      product_id: map['product_id'],
      quantity: map['quantity'],
      price: map['price'],
      pprice: map['pprice'],
    );
  }
}
