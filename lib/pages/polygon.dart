import 'package:flutter/material.dart';
import 'package:google_maps_demo/pages/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonWidget{
  static Set<Polygon> getPolygon() {
    
  return {
      Polygon(
        polygonId: PolygonId('tamilnadu'),
        points: PolygonCords.getAllCords(),
        fillColor: Colors.blue.shade100.withValues(alpha: 150),
        strokeWidth: 1,
        strokeColor: Colors.black
      ),
    };
  }
} 