import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkerService {
  static Future<BitmapDescriptor> loadCustomMarker() async {
    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(70, 70)),
      "assets/marker1.png",
    );
  }
}