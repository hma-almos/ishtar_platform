class CarrerFeilds {
  final int id;
  final String name;
  final String description;

  CarrerFeilds({
    required this.id,
    required this.name,
    required this.description,
  });
  
  factory CarrerFeilds.fromJson(Map<String, dynamic> json) {
    return CarrerFeilds(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
 Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
}