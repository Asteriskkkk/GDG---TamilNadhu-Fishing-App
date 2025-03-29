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
  bool isInProximity = false;

  //custom marker code
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  void addCustomMarker() {
    BitmapDescriptor.asset(ImageConfiguration(size: Size(70,70)), "assets/marker1.png").then(
      (icon) {
        setState(() {
          customIcon = icon;
        });
      },
    );
  }
  //custom marker code ends

  @override 
  void initState() {
    super.initState();
    addCustomMarker();
    getLocationUpdates();
  }
  
  //checks whether user is in ocean 
  void checkProximity(LatLng pointLatLng){

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
      body:
          _userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
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
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isInSelectedAreaNotifier,
                    builder: (context, isInFishingZone, child) {
                      return FishingAlertBottomBar(
                        isInFishingZone: isInFishingZone,
                      );
                    },
                  ),
                  // every time isInSelectedArea changes the bottom bar changes
                ],
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
