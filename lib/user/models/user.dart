class User {
  int? id;
  String? name;
  String? login_id;
  String? password;
  int? role_id;

  User.fromMap(Map<String, dynamic> user) {
    id = user["id"];
    name = user["name"];
    login_id = user["login_id"];
    password = user["password"];
    role_id = user["role_id"];
  }
}
