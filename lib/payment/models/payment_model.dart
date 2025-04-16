class PaymentModel {
  int id;
  String name;
  String description;

  PaymentModel({
    required this.id,
    required this.name,
    required this.description
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}
