class CityModel {
  final String name;
  final int distance;

  const CityModel({
    required this.name,
    required this.distance,
  });

  /// Allows creating a new instance with updated relative distance
  CityModel copyWith({String? name, int? distance}) {
    return CityModel(
      name: name ?? this.name,
      distance: distance ?? this.distance,
    );
  }

  /// Master list stored once in memory as constant data
  static const List<CityModel> baseCities = [
    CityModel(name: "اربيل", distance: 0),
    CityModel(name: "كركوك", distance: 105),
    CityModel(name: "السليمانية", distance: 104),
    CityModel(name: "الموصل", distance: 85),
    CityModel(name: "دهوك", distance: 150),
    CityModel(name: "بغداد", distance: 360),
    CityModel(name: "ديالى", distance: 330),
    CityModel(name: "صلاح الدين", distance: 270),
    CityModel(name: "كربلاء", distance: 430),
    CityModel(name: "بابل", distance: 450),
    CityModel(name: "الانبار", distance: 480),
    CityModel(name: "واسط", distance: 500),
    CityModel(name: "النجف", distance: 511),
    CityModel(name: "الديوانية", distance: 520),
    CityModel(name: "المثنى", distance: 590),
    CityModel(name: "ذي قار", distance: 620),
    CityModel(name: "ميسان", distance: 650),
    CityModel(name: "البصرة", distance: 770),
  ];

  static List<CityModel> getCitiesSortedByProximity(CityModel relativeTo) {
    return baseCities.map((city) {
      final relativeDistance = (city.distance - relativeTo.distance).abs();
      return city.copyWith(distance: relativeDistance);
    }).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }
}