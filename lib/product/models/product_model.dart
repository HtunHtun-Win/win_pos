class ProductModel{
  int? id;
  String? code;
  String? name;
  String? description;
  int? quantity;
  int? category_id;
  String? category_name;
  int? purchase_price;
  int? sale_price;

  ProductModel.fromMap(Map product){
    id = product["id"];
    code = product["code"];
    name = product["name"];
    description = product["description"];
    quantity = product["quantity"];
    category_id = product["category_id"];
    category_name = product["category_name"];
    purchase_price = product["purchase_price"];
    sale_price = product["sale_price"];
  }
}