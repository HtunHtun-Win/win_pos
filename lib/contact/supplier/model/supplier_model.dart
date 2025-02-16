class SupplierModel{
  int? id;
  String? name;
  String? phone;
  String? address;
  SupplierModel.fromMap(Map map){
    id = map["id"];
    name = map["name"];
    phone = map["phone"];
    address = map["address"];
  }
}