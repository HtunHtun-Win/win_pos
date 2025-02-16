class ShopModel{
  int? id;
  String? name;
  String? address;
  String? phone;

  ShopModel.fromMap(Map shop){
    id = shop["id"];
    name = shop["shop_name"];
    address = shop["shop_address"];
    phone = shop["shop_phone"];
  }
}