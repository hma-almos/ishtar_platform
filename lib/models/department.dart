import 'package:ishtar_platform/models/college_model.dart';

class Department {
  final int id;
  final String name;
  final String description;
  final double minimumGpa;
  final CollegeModel college;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.minimumGpa,
    required this.college,
  });
  
  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      minimumGpa: json['minimumGpa'].toDouble(),
      college: CollegeModel.fromJson(json['college'] as Map<String, dynamic>),
    );
  }
 Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'minimumGpa':minimumGpa,
    'college': college.toJson(),
  };
}