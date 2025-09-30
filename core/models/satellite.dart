class Satellite {
  final int satelliteId;
  final String satelliteCode;
  final String satelliteName;

  Satellite({
    required this.satelliteId,
    required this.satelliteCode,
    required this.satelliteName,
  });

  factory Satellite.fromJson(Map<String, dynamic> json) {
    return Satellite(
      satelliteId: json['satellite_id'],
      satelliteCode: json['satellite_code'],
      satelliteName: json['satellite_name'],
    );
  }
}
