import 'dart:async'; // Added for Timer-based debouncing
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_demo/features/map/presentation/screens/widgets/fishing_zone.dart';
import 'package:google_maps_demo/features/map/presentation/services/custom_tile_provider.dart';
import 'package:google_maps_demo/features/map/presentation/services/fishing_marker_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// imports from services
import 'package:google_maps_demo/features/map/presentation/screens/widgets/eez_status_bar.dart';
import 'package:google_maps_demo/features/map/presentation/screens/widgets/polygon_drawer.dart';
import 'package:google_maps_demo/features/map/presentation/services/custom_marker.dart';
import 'package:google_maps_demo/features/map/presentation/services/location_service.dart';
import 'package:google_maps_demo/features/map/presentation/services/polygon_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  LatLng? _userLocation; // to store the user's current location
  final ValueNotifier<bool> isInSelectedAreaNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<String> warningMessageNotifier = ValueNotifier<String>(
    "",
  );
  List<Map<String, dynamic>> _nearestLocations = [];

  Set<Marker> _markers = {}; // All map markers

  //custom marker code
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  //custom marker code ends

  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    if (!mounted) return;

    // Load custom marker asynchronously without blocking UI
    CustomMarkerService.loadCustomMarker().then((icon) {
      if (mounted) {
        setState(() => customIcon = icon);
      }
    });

    // Fetch location asynchronously
    LocationService.getLocationUpdates().then((location) {
      if (mounted && location != null) {
        setState(() => _userLocation = location);

        // Run polygon checks asynchronously
        Future.microtask(() {
          PolygonService.checkUpdatedLocation(
            location,
            isInSelectedAreaNotifier,
          );
          PolygonService.checkProximity(location, warningMessageNotifier);
        });
      }
    });
  }

  Future<void> _loadNearestFishingMarkers() async {
    if (_nearestLocations.isNotEmpty)
      return; // Avoid reloading if already fetched

    final nearest =
        await FishingZone.getNearestFishingLocations(); // you can replace with your own logic
    setState(() {
      _nearestLocations = nearest;
      _markers = FishingMarkerService.generateFishingMarkers(_nearestLocations);
    });
  }

  //checks whether user is in ocean

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
                      zoom: 10,
                    ),
                    polygons: PolygonWidget.getPolygon(),
                    markers: {
                      Marker(
                        markerId: const MarkerId('marker'),
                        position: _userLocation!,
                        draggable: true,
                        onDragEnd: (updatedLatLng) {
                          PolygonService.checkUpdatedLocation(
                            updatedLatLng,
                            isInSelectedAreaNotifier,
                          );
                          PolygonService.checkProximity(
                            updatedLatLng,
                            warningMessageNotifier,
                          );
                        },
                        icon: customIcon,
                      ),
                      ..._markers,
                    },
                    tileOverlays: {
                      TileOverlay(
                        tileOverlayId: TileOverlayId('cached_tiles'),
                        tileProvider: CustomTileProvider(),
                      ),
                    },
                  ),

                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: 160,
                    width: 250,
                    offset: 50,
                  ),

                  Positioned(
                    bottom: 200,
                    right: 15,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue[100],
                      onPressed: _loadNearestFishingMarkers,
                      child: Image.asset('assets/fishing_spot.png'),
                    ),
                  ),

                  DraggableScrollableSheet(
                    initialChildSize: 0.2,
                    minChildSize: 0.2,
                    maxChildSize: 0.5,
                    controller: _controller,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),

                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.all(16),
                          children: [
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            ValueListenableBuilder<String>(
                              valueListenable: warningMessageNotifier,
                              builder: (context, message, child) {
                                return message.isNotEmpty
                                    ? Container(
                                      padding: EdgeInsets.all(12),
                                      margin: EdgeInsets.only(bottom: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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

                            SizedBox(height: 15),

                            if (_nearestLocations.isNotEmpty) ...[
                              Text(
                                'Nearest Fishing Spots',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              SizedBox(height: 10),

                              // This is where we add the ListView.builder as a child
                              // We wrap it in a Container with a fixed height to avoid nested scrolling issues
                              Container(
                                height:
                                    _nearestLocations.length *
                                    120, // Approximate height per card
                                child: ListView.builder(
                                  physics:
                                      NeverScrollableScrollPhysics(), // Important: prevent nested scrolling
                                  itemCount: _nearestLocations.length,
                                  itemBuilder: (context, index) {
                                    final location = _nearestLocations[index];
                                    return Card(
                                      color: Colors.blue[50],
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          location['name'] ?? 'Unnamed',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Distance: ${location['distance_km']} km, Depth: ${location['depth_m']} m",
                                            ),

                                            Text(
                                              "Bearing: ${location['bearing']}°, Direction: ${location['direction']}",
                                            ),
                                          ],
                                        ),
                                        isThreeLine:
                                            true, // Allows more space for the subtitle with multiple lines
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
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
