import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:maps_toolkit/maps_toolkit.dart' as maps;
import 'package:google_maps_demo/features/map/data/service/database_service.dart';
import 'package:google_maps_demo/features/map/presentation/services/location_service.dart';

class FishingZone {
  static Future<List<Map<String, dynamic>>> getNearestFishingLocations() async {
    final gmaps.LatLng? location = await LocationService.getLocationUpdates();

    if (location == null) {
      print("Error: Could not get user location.");
      return [];
    }

    final databaseService = DatabaseService();
    final List<Map<String, dynamic>> documents = await databaseService.getAllFishingLocations();

    if (documents.isEmpty) {
      print("No fishing locations found.");
      return [];
    }

    final maps.LatLng convertedLocation = maps.LatLng(location.latitude, location.longitude);

    return databaseService.getNearestLocations(convertedLocation, documents);
  }
}
