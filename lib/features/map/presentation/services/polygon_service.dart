import 'package:flutter/material.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;
import 'package:google_maps_demo/features/map/data/polygon_coordinates.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class PolygonService {
  static void checkProximity(LatLng pointLatLng, ValueNotifier<String> notifier) {
    List<map_tool.LatLng> convatedPolygonPoint =
        PolygonCords.getAllCords().map((e) {
          return map_tool.LatLng(e.latitude, e.longitude);
        }).toList();

    // Convert user location from Google Maps LatLng to maps_tool.LatLng
    map_tool.LatLng userLocation = map_tool.LatLng(
      pointLatLng.latitude,
      pointLatLng.longitude,
    );

    double closestDistance = double.infinity;

    // Iterate through polygon edges (each consecutive pair forms a line segment)
    for (int i = 0; i < convatedPolygonPoint.length; i++) {
      map_tool.LatLng start = convatedPolygonPoint[i];
      map_tool.LatLng end =
          convatedPolygonPoint[(i + 1) %
              convatedPolygonPoint.length]; // Loop back to first point

      //   shortest distance from userLocation to the line segment
      double distance =
          map_tool.PolygonUtil.distanceToLine(
            userLocation,
            start,
            end,
          ).toDouble();

      if (distance < closestDistance) {
        closestDistance = distance;
      }
    }

    notifier.value = closestDistance < 5000
        ? "⚠ Warning: You are ${closestDistance.toInt()} meters from international waters!"
        : "";
  }

  // used to check if the updated location is in the selected area
  static void checkUpdatedLocation(LatLng pointLatLng ,ValueNotifier<bool> notifier) {
    List<map_tool.LatLng> convatedPolygonPoint =
        PolygonCords.getAllCords().map((e) {
          return map_tool.LatLng(e.latitude, e.longitude);
        }).toList();

    bool isInZone = map_tool.PolygonUtil.containsLocation(
      map_tool.LatLng(pointLatLng.latitude, pointLatLng.longitude),
      convatedPolygonPoint,
      false,
    );

    if (notifier.value != isInZone) {
      notifier.value = isInZone;
    }
  }
}
