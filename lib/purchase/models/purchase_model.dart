class PurchaseModel {
  int? id;
  String? purchaseNo;
  String? supplier;
  String? user;
  int? net_price;
  int? discount;
  int? total_price;
  String? payment;
  int? isdeleted;
  String? created_at;

  PurchaseModel({
    this.id,
    this.purchaseNo,
    this.supplier,
    this.user,
    this.net_price,
    this.discount,
    this.total_price,
    this.payment,
    this.isdeleted,
    this.created_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_no': purchaseNo,
      'customer_id': supplier,
      'user_id': user,
      'net_price': net_price,
      'discount': discount,
      'total_price': total_price,
      'payment_type_id': payment,
      'isdeleted' : isdeleted,
      'created_at': created_at,
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as int,
      purchaseNo: map['purchase_no'] as String,
      supplier: map['customer'],
      user: map['user'],
      net_price: map['net_price'] as int,
      discount: map['discount'] as int,
      total_price: map['total_price'] as int,
      payment: map['payment'],
      isdeleted: map['isdeleted'],
      created_at: map['created_at'] as String,
    );
  }
}
