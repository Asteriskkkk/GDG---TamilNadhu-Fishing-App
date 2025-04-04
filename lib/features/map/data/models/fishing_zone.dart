class FishingZone {
  int bearing;
  String depth_m;
  String direction;
  String distance_km;
  double latitude;
  double longitude;
  String name;

  FishingZone({
      required this.bearing,
      required this.depth_m,
      required this.direction,
      required this.distance_km,
      required this.latitude,
      required this.longitude,
      required this.name,
    }
  );

  FishingZone.fromJson(Map<String, Object?> json) : this(
    bearing: json['bearing']! as int,
    depth_m: json['depth_m']! as String,
    direction: json['direction']! as String,
    distance_km: json['distance_km']! as String,
    latitude: (json['latitude']!as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    name: json['name']! as String,
  );

  Map<String,Object?> toJson(){
    return {
      "bearing": bearing,
      "depth_m": depth_m,
      "direction": direction,
      "distance_km": distance_km,
      "latitude": latitude,
      "longitude": longitude,
      "name": name,
    };
  }
}
