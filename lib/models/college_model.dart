
enum StudyShift { morning, parallel, evening }

class ShiftInfo {
  final StudyShift shift;
  final double requiredGpa;
  final int cost;
  final int id;

  const ShiftInfo({
    required this.shift,
    required this.requiredGpa,
    this.cost = 0,
    this.id=0,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) {
    return ShiftInfo(
      shift: _shiftFromString(json['shift'] as String? ?? 'morning'),
      requiredGpa: (json['requiredGpa'] ?? json['required_gpa'] as num?)?.toDouble() ?? 0.0,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift': shift.name,
      'requiredGpa': requiredGpa,
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
  final int id;
  final String name;
  final String universityName;
  final String city;
  final bool isPrivate;
  final String logoUrl;
  final String overview;
  final String establishedYear;
  final String recognitionDocNumber;
  final String? extraInfo;
  final List<String> departments;
  final List<String> careerFields;
  final double latitude;
  final double longitude;
  final String? gender;
  final String? studyType;
  final String? address;
  final List<ShiftInfo> shiftOptions;

  const CollegeModel({
    required this.id,
    required this.name,
    required this.universityName,
    required this.city,
    required this.isPrivate,
    required this.logoUrl,
    required this.overview,
    required this.establishedYear,
    required this.recognitionDocNumber,
    this.extraInfo,
    required this.departments,
    required this.careerFields,
    required this.latitude,
    required this.longitude,
    this.gender,
    this.studyType,
    this.address,
    required this.shiftOptions,
  });

  ShiftInfo? getShift(StudyShift shift) {
    try {
      return shiftOptions.firstWhere((info) => info.shift == shift);
    } catch (_) {
      // Fallback shift using root minimumGpa if shiftOptions isn't populated
      if (shift == StudyShift.morning) {
        return ShiftInfo(shift: StudyShift.morning, requiredGpa: shiftOptions[0].requiredGpa);
      }
      return null;
    }
  }

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    // Extract university name from nested UniversityDto object
    String uniName = '';
    if (json['university'] is Map<String, dynamic>) {
      uniName = json['university']['name'] as String? ?? '';
    } else if (json['universityName'] != null) {
      uniName = json['universityName'] as String;
    }

    // Extract department names from Set<DepartmentDto>
    List<String> parsedDepartments = [];
    if (json['departments'] is List) {
      parsedDepartments = (json['departments'] as List).map((e) {
        if (e is Map<String, dynamic>) return e['name'] as String? ?? '';
        return e.toString();
      }).toList();
    }

    // Extract career field names from Set<CarrerFeildDto>
    List<String> parsedCareerFields = [];
    if (json['careerFields'] is List) {
      parsedCareerFields = (json['careerFields'] as List).map((e) {
        if (e is Map<String, dynamic>) return e['name'] as String? ?? '';
        return e.toString();
      }).toList();
    }

    double rootGpa = (json['minimumGpa'] as num?)?.toDouble() ?? 0.0;

    return CollegeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      universityName: uniName,
      city: json['city'] as String? ?? '',
      isPrivate: json['isPrivate'] as bool? ?? false,
      logoUrl: json['logoUrl'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      establishedYear: json['establishedYear'] as String? ?? '',
      recognitionDocNumber: json['recognitionDocNumber'] as String? ?? '',
      extraInfo: json['extraInfo'] as String?,
      departments: parsedDepartments,
      careerFields: parsedCareerFields,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      gender: json['gender'] as String?,
      studyType: json['studyType'] as String?,
      address: json['address'] as String?,
      shiftOptions: (json['shift'] as List<dynamic>?)
              ?.map((e) => ShiftInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [
            ShiftInfo(shift: StudyShift.morning, requiredGpa: rootGpa)
          ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'university': {'name': universityName},
      'city': city,
      'isPrivate': isPrivate,
      'logoUrl': logoUrl,
      'overview': overview,
      'establishedYear': establishedYear,
      'recognitionDocNumber': recognitionDocNumber,
      'extraInfo': extraInfo,
      'departments': departments.map((d) => {'name': d}).toList(),
      'careerFields': careerFields.map((c) => {'name': c}).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'gender': gender,
      'studyType': studyType,
      'address': address,
      'shift': shiftOptions.map((e) => e.toJson()).toList(),
    };
  }
}