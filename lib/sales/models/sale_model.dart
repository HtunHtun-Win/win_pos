class SaleModel{
  int? id;
  String? sale_no;
  int? customer_id;
  int? user_id;
  int? net_price;
  int? discount;
  int? total_price;
  int? payment_type_id;
  String? created_at;

  SaleModel({
    this.id,
    this.sale_no,
    this.customer_id,
    this.user_id,
    this.net_price,
    this.discount,
    this.total_price,
    this.payment_type_id,
    this.created_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_no': sale_no,
      'customer_id': customer_id,
      'user_id': user_id,
      'net_price': net_price,
      'discount': discount,
      'total_price': total_price,
      'payment_type_id': payment_type_id,
      'created_at': created_at,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'] as int,
      sale_no: map['sale_no'] as String,
      customer_id: map['customer_id'] as int,
      user_id: map['user_id'] as int,
      net_price: map['net_price'] as int,
      discount: map['discount'] as int,
      total_price: map['total_price'] as int,
      payment_type_id: map['payment_type_id'] as int,
      created_at: map['created_at'] as String,
    );
  }

}