import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_demo/features/map/presentation/screens/map_screen.dart';
import 'package:google_maps_demo/features/map/presentation/services/location_service.dart';
import 'package:google_maps_demo/pages/weather_component.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class FishingAppHomePage extends StatefulWidget {
  const FishingAppHomePage({Key? key}) : super(key: key);

  @override
  State<FishingAppHomePage> createState() => _FishingAppHomePageState();
}

class _FishingAppHomePageState extends State<FishingAppHomePage> {
  Map<String, dynamic>? weatherData;
  final String apiKey = '7dd4f4058e364360a60110835252603';
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _initLocationAndWeather();
  }

  void _initLocationAndWeather() async {
    LatLng? location = await LocationService.getLocationUpdates();
    if (location != null) {
      setState(() {
        latitude = location.latitude;
        longitude = location.longitude;
      });

      final data = await fetchCurrentWeather(apiKey, latitude, longitude);
      if (data != null) {
        setState(() { 
          weatherData = data;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentWeather(String apiKey, double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=1&aqi=no&alerts=no'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Weather API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (latitude == 0.0 && longitude == 0.0) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6ECEC0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Search for the best fishing spots',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              _buildSearchBar(),
              const SizedBox(height: 24),

              Text(
                'Lat: ${latitude.toStringAsFixed(2)}, Lon: ${longitude.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              weatherData == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: WeatherCard(weatherData: weatherData!),
                    ),

              const SizedBox(height: 20),

              _buildMapCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search fishing spot...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF6ECEC0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const MapPlaceholder(),
    );
  }
}

// Placeholder to load your actual Google Map page
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MapPage(); // Your actual map implementation
  }
}
