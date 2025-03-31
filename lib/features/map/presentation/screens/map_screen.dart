import 'dart:async'; // Added for Timer-based debouncing
import 'package:flutter/material.dart';
import 'package:google_maps_demo/features/map/presentation/screens/widgets/eez_status_bar.dart';
import 'package:google_maps_demo/features/map/data/polygon_coordinates.dart';
import 'package:google_maps_demo/features/map/presentation/screens/widgets/polygon_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  
  final Location _locationController = Location();
  LatLng? _userLocation; // to store the user's current location
  final ValueNotifier<bool> isInSelectedAreaNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<String> warningMessageNotifier = ValueNotifier<String>(
    "",
  );
  //custom marker code
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  void addCustomMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration(size: Size(70, 70)),
      "assets/marker1.png",
    ).then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
  }
  //custom marker code ends

  @override
  void initState() {
    super.initState();
    addCustomMarker();
    getLocationUpdates();
  }

  //checks whether user is in ocean
  void checkProximity(LatLng pointLatLng) {
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

    print(
      "Closest Distance to EEZ Boundary: ${closestDistance.toStringAsFixed(2)} meters",
    );

    if (closestDistance < 5000) {
      // Example threshold (5 km)
      print("⚠ Warning: Approaching international waters!");
      warningMessageNotifier.value =
          "⚠ Warning: Approaching international waters! (${closestDistance.toStringAsFixed(2)} m)";
    } else {
      warningMessageNotifier.value = "";
    }
  }

  // used to check if the updated location is in the selected area
  void checkUpdatedLocation(LatLng pointLatLng) {
    List<map_tool.LatLng> convatedPolygonPoint =
        PolygonCords.getAllCords().map((e) {
          return map_tool.LatLng(e.latitude, e.longitude);
        }).toList();

    bool newIsInSelectedArea = map_tool.PolygonUtil.containsLocation(
      map_tool.LatLng(pointLatLng.latitude, pointLatLng.longitude),
      convatedPolygonPoint,
      false,
    );

    if (isInSelectedAreaNotifier.value != newIsInSelectedArea) {
      isInSelectedAreaNotifier.value =
          newIsInSelectedArea; // 🔹 Update notifier instead of calling setState()
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body:
          _userLocation == null
              ? _buildLoadingView()
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _userLocation!,
                      zoom: 7,
                    ),
                    polygons: PolygonWidget.getPolygon(),
                    markers: {
                      Marker(
                        markerId: const MarkerId('marker'),
                        position: _userLocation!,
                        draggable: true,
                        onDragEnd: (updatedLatLng) {
                          checkUpdatedLocation(updatedLatLng);
                          checkProximity(updatedLatLng);
                        },
                        icon: customIcon,
                      ),
                    },
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        ValueListenableBuilder<String>(
                          valueListenable: warningMessageNotifier,
                          builder: (context, message, child) {
                            return message.isNotEmpty
                                ? Container(
                                  padding: EdgeInsets.all(12),
                                  color: Colors.red.shade700,
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                : SizedBox();
                          },
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: isInSelectedAreaNotifier,
                          builder: (context, isInFishingZone, child) {
                            return FishingAlertBottomBar(
                              isInFishingZone: isInFishingZone,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // every time isInSelectedArea changes the bottom bar changes
                ],
              ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Getting your location...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  // Used to get the user location, requests permissions
  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData? currentLocation = await _locationController.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      LatLng updatedLocation = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
      setState(() {
        _userLocation = updatedLocation;
      });
      checkUpdatedLocation(updatedLocation);
      checkProximity(updatedLocation);
    }

    //comment out when the drag is off
    // _locationController.onLocationChanged.listen((
    //   LocationData currentLocation,
    // ) {
    //   if (currentLocation.latitude != null &&
    //       currentLocation.longitude != null) {
    //     LatLng updatedLocation = LatLng(
    //       currentLocation.latitude!,
    //       currentLocation.longitude!,
    //     );
    //     setState(() {
    //       _userLocation = LatLng(
    //         currentLocation.latitude!,
    //         currentLocation.longitude!,
    //       );
    //     });
    //     checkUpdatedLocation(updatedLocation);
    //   }
    // });
  }
}
