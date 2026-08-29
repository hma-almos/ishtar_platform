import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Storage Keys
  static const String _keyName = 'session_name';
  static const String _keyGender = 'session_gender';
  static const String _keyCity = 'session_city';
  static const String _keyGrade = 'session_grade';
  static const String _keyBranch = 'session_branch';

  // Static In-Memory Cache (Accessible statically anywhere)
  static String? name;
  static String? gender;
  static String? city;
  static String? grade;
  static String? branch;

  /// Call this inside main() before runApp() to load data from disk into memory
  static Future<void> init() async {
    name = await _storage.read(key: _keyName);
    gender = await _storage.read(key: _keyGender);
    city = await _storage.read(key: _keyCity);
    grade = await _storage.read(key: _keyGrade);
    branch = await _storage.read(key: _keyBranch);
  }

  /// Save or update user session data encrypted on disk and in static cache
  static Future<void> save({
    String? name,
    String? gender,
    String? city,
    String? grade,
    String? branch,
  }) async {
    if (name != null) {
      Session.name = name;
      await _storage.write(key: _keyName, value: name);
    }
    if (gender != null) {
      Session.gender = gender;
      await _storage.write(key: _keyGender, value: gender);
    }
    if (city != null) {
      Session.city = city;
      await _storage.write(key: _keyCity, value: city);
    }
    if (grade != null) {
      Session.grade = grade;
      await _storage.write(key: _keyGrade, value: grade);
    }
    if (branch != null) {
      Session.branch = branch;
      await _storage.write(key: _keyBranch, value: branch);
    }
  }

  /// Check if user has stored session data
  static bool get isLoggedIn => name != null && name!.isNotEmpty;

  /// Clear disk and memory data (for Logout)
  static Future<void> clear() async {
    name = null;
    gender = null;
    city = null;
    grade = null;
    branch = null;
    await _storage.deleteAll();
  }
}