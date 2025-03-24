import 'package:flutter/material.dart';
import 'package:google_maps_demo/pages/bottom_bar.dart';
import 'package:google_maps_demo/pages/latlong.dart';
import 'package:google_maps_demo/pages/polygon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng tamilnadu = LatLng(
    11.127123,
    78.656891,
  ); // initial position

  bool isInSelectedArea = true;

  // used to check if the updated location is in the selected area
  void checkUpdatedLocation(LatLng pointLatLng) {
    List<map_tool.LatLng> convatedPolygonPoint =
        PolygonCords.getAllCords().map((e) {
          return map_tool.LatLng(e.latitude, e.longitude);
        }).toList();
    setState(() {
      isInSelectedArea = map_tool.PolygonUtil.containsLocation(
        map_tool.LatLng(pointLatLng.latitude, pointLatLng.longitude),
        convatedPolygonPoint,
        false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: tamilnadu, zoom: 7),
              polygons: PolygonWidget.getPolygon(),
              markers: {
                Marker(
                  markerId: const MarkerId('marker'),
                  position: tamilnadu,
                  draggable: true,
                  onDragEnd: (updatedLatLng) {
                    checkUpdatedLocation(updatedLatLng);
                  },
                ),
              },
            ),
          ),
          FishingAlertBottomBar(isInFishingZone: isInSelectedArea),
        ],
      ),
    );
  }
}
