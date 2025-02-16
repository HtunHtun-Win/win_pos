class CategoryModel{
  int? id;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;

  CategoryModel.fromMap(Map category){
    id = category["id"];
    name = category["name"];
    description = category["description"];
    createdAt = category["created_at"];
    updatedAt = category["updated_at"];
  }

}