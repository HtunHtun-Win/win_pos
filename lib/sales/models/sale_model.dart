class SaleModel{
  int? id;
  String? sale_no;
  String? customer;
  String? user;
  int? net_price;
  int? discount;
  int? total_price;
  String? payment;
  String? created_at;

  SaleModel({
    this.id,
    this.sale_no,
    this.customer,
    this.user,
    this.net_price,
    this.discount,
    this.total_price,
    this.payment,
    this.created_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_no': sale_no,
      'customer_id': customer,
      'user_id': user,
      'net_price': net_price,
      'discount': discount,
      'total_price': total_price,
      'payment_type_id': payment,
      'created_at': created_at,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'] as int,
      sale_no: map['sale_no'] as String,
      customer: map['customer'],
      user: map['user'],
      net_price: map['net_price'] as int,
      discount: map['discount'] as int,
      total_price: map['total_price'] as int,
      payment: map['payment'],
      created_at: map['created_at'] as String,
    );
  }

}