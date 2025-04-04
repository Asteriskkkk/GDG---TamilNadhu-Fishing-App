import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

const String FISHING_ZONE_REF = "fishing_locations";

class DatabaseService {
  final _firebase = FirebaseFirestore.instance;

  late final CollectionReference _fishinglocationRef;

  DatabaseService() {
    _fishinglocationRef = _firebase.collection(FISHING_ZONE_REF);
  }

  Future<List<Map<String, dynamic>>> getAllFishingLocations() async {
    try {
      QuerySnapshot querySnapshot = await _fishinglocationRef.get();

      // Convert each document snapshot into a Map<String, dynamic>
      List<Map<String, dynamic>> locations =
          querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data;
          }).toList();

      return locations;
    } catch (e) {
      print("Error fetching documents: $e");
      return [];
    }
  }


  /// Get 5 nearest fishing locations using SphericalUtil
  List<Map<String, dynamic>> getNearestLocations( LatLng userLocation, List<Map<String, dynamic>> locations) {

    double userLat = userLocation.latitude;
    double userLng = userLocation.longitude;
    // Calculate distances and sort
    locations.forEach((location) {
      location["distance"] = SphericalUtil.computeDistanceBetween(
          LatLng(userLat, userLng), LatLng(location["latitude"], location["longitude"])
      );
    });

    // Sort by distance and return top 5
    locations.sort((a, b) => a["distance"].compareTo(b["distance"]));
    return locations.take(5).toList();
  }

}
