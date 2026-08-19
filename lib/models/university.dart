
import 'package:ishtar_platform/models/college_model.dart';

class University {
  final int id;
  final String name;
  final String description;
  final Set<CollegeModel> colleges;

  University({
    required this.id,
    required this.name,
    required this.description,
    required this.colleges,
  });
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      colleges: Set<CollegeModel>.from(
          (json['colleges'] as List<dynamic>).map((e) => CollegeModel.fromJson(e as Map<String, dynamic>)),
        ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'colleges': colleges.map((e) => e.toJson()).toList(),
  };
}
