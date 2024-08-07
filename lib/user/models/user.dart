class User {
  int? id;
  String? name;
  String? login_id;
  String? password;
  int? role_id;

  User.fromMap(Map<String, dynamic> user) {
    this.id = user["id"];
    this.name = user["name"];
    this.login_id = user["login_id"];
    this.password = user["password"];
    this.role_id = user["role_id"];
  }
}
