class ExpenseModel{
  int? id;
  int? amount;
  String? description;
  String? note;
  int? type; // 1 is income ,2 is expense
  int? userId;
  String? createdDate;

  ExpenseModel.fromMap(Map map){
    id = map['id'];
    amount = map['amount'];
    description = map['description'];
    note = map['note'];
    type = map['flow_type_id'];
    userId = map['user_id'];
    createdDate = map['created_at'];
  }
}