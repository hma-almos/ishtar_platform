import 'package:flutter/foundation.dart';

enum StudyShift { morning, parallel, evening }

/// Wrapper model for any learning mode that has GPA requirements and payment costs
class ShiftInfo {
  final StudyShift shift;
  final double requiredGpa;
  final int cost; // Tuition fee (0 if free)

  const ShiftInfo({
    required this.shift,
    required this.requiredGpa,
    this.cost = 0,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) {
    return ShiftInfo(
      shift: _shiftFromString(json['shift'] as String? ?? 'morning'),
      requiredGpa: (json['required_gpa'] as num?)?.toDouble() ?? 0.0,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift': shift.name,
      'required_gpa': requiredGpa,
      'cost': cost,
    };
  }

  static StudyShift _shiftFromString(String shiftStr) {
    switch (shiftStr.toLowerCase()) {
      case 'parallel':
        return StudyShift.parallel;
      case 'evening':
        return StudyShift.evening;
      case 'morning':
      default:
        return StudyShift.morning;
    }
  }
}

class CollegeModel {
  final String id;
  final String name; // اسم الكلية
  final String universityName; // اسم الجامعة
  final String city; // المحافظة
  final bool isPrivate; // نوع الكلية: حكومي أم أهلي
  final List<ShiftInfo> shiftOptions; // قائمة قنوات الدراسة المتاحة
  final String logoUrl;
  final String overview;
  final List<String> careerFields;
  final String establishedYear;
  final String recognitionDocNumber;
  final List<String> departments;
  final String? extraInfo;
  final double latitude;
  final double longitude;
  final String? address;

  const CollegeModel({
    required this.id,
    required this.name,
    required this.universityName,
    required this.city,
    required this.isPrivate,
    required this.shiftOptions,
    required this.logoUrl,
    required this.overview,
    required this.careerFields,
    required this.establishedYear,
    required this.recognitionDocNumber,
    required this.departments,
    required this.latitude,
    required this.longitude,
    this.extraInfo,
    this.address,
  });

  /// Helper getter: Finds the shift option for the requested shift type
  ShiftInfo? getShift(StudyShift shift) {
    try {
      return shiftOptions.firstWhere((info) => info.shift == shift);
    } catch (_) {
      return null; // Return null if this college doesn't support the requested shift
    }
  }

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    return CollegeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      universityName: json['university_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      isPrivate: json['is_private'] as bool? ?? false,
      shiftOptions: (json['shift_options'] as List<dynamic>?)
              ?.map((e) => ShiftInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      logoUrl: json['logo_url'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      careerFields: (json['career_fields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      establishedYear: json['established_year'] as String? ?? '',
      recognitionDocNumber: json['recognition_doc_number'] as String? ?? '',
      departments: (json['departments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      extraInfo: json['extra_info'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'university_name': universityName,
      'city': city,
      'is_private': isPrivate,
      'shift_options': shiftOptions.map((e) => e.toJson()).toList(),
      'logo_url': logoUrl,
      'overview': overview,
      'career_fields': careerFields,
      'established_year': establishedYear,
      'recognition_doc_number': recognitionDocNumber,
      'departments': departments,
      'extra_info': extraInfo,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}