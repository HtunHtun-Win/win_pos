class CustomerModel{
  int? id;
  String? name;
  String? phone;
  String? address;
  CustomerModel.fromMap(Map map){
    id = map["id"];
    name = map["name"];
    phone = map["phone"];
    address = map["address"];
  }
}