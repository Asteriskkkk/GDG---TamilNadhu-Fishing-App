import 'package:google_maps_flutter/google_maps_flutter.dart';

class FishingMarkerService {
  static Set<Marker> generateFishingMarkers(
    List<Map<String, dynamic>> locations,
  ) {
    return locations.asMap().entries.map((entry) {
      final index = entry.key;
      final location = entry.value;

      final lat = location['latitude'];
      final lng = location['longitude'];
      final name = location['name'] ?? 'Fishing Spot #$index';
      final bearing = location['bearing'] ?? 'N/A';
      final depth = location['depth_m'] ?? 'N/A';
      final direction = location['direction'] ?? 'N/A';
      final distance = location['distance_km'] ?? 'N/A';

      return Marker(
        markerId: MarkerId('fishing_marker_$index'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: name,
          snippet: '''
            Depth: $depth m
            Direction: $direction
            Distance: $distance km
            Bearing: $bearing
            ''',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }).toSet();
  }
}
