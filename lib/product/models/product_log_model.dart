class ProductLogModel{
  String? date;
  String? product;
  int? quantity;
  String? note;
  String? user;

  ProductLogModel.fromMap(Map map){
    date = map["date"];
    product = map["product"];
    quantity = map["quantity"];
    note = map["note"];
    user = map["user"];
  }

}