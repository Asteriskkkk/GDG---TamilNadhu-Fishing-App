import 'package:flutter/material.dart';
import 'package:google_maps_demo/features/map/presentation/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final DraggableScrollableController _controller = DraggableScrollableController();
  final String apiKey = '7dd4f4058e364360a60110835252603';
  
  // Weather data
  Map<String, dynamic> currentWeather = {};
  List<dynamic> hourlyForecast = [];
  List<dynamic> dailyForecast = [];
  bool isLoading = true;
  String city = '';
  String country = 'IN';

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    setState(() {
      isLoading = true;
    });

    try {
      LatLng? location = await LocationService.getLocationUpdates();
      double latitude = 0.0, longitude = 0.0;
      if(location != null){
        latitude = location.latitude;
        longitude = location.longitude;
      }

      // Fetch current weather
      final currentResponse = await http.get(Uri.parse(
          'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=7&aqi=no&alerts=yes'));
      
      if (currentResponse.statusCode == 200) {
        final data = json.decode(currentResponse.body);
        setState(() {
          currentWeather = data;

          city = data['location']['name'];
          print(city);
          
          // Extract hourly forecast for today
          hourlyForecast = data['forecast']['forecastday'][0]['hour'];
          
          // Extract daily forecast
          dailyForecast = data['forecast']['forecastday'];
          
          isLoading = false;
        });
      } else {
        print('Failed to load weather data: ${currentResponse.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    return DateFormat('E, MMM d HH:mm').format(now);
  }

  IconData getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.water_drop;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return Icons.flash_on;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Icons.cloud_queue;
    } else {
      return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                '$city, $country',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        leadingWidth: 150,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchWeatherData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                // Enhanced background with gradient overlay
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/weather_back.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.blue.shade900.withOpacity(0.7),
                          Colors.blue.shade800.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          getFormattedDate(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3.0,
                                color: Color.fromARGB(150, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Temperature with gradient
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white, Colors.lightBlueAccent],
                              ).createShader(bounds),
                              child: Text(
                                currentWeather['current']?['temp_c']?.toInt()?.toString() ?? '0',
                                style: const TextStyle(
                                  fontSize: 120,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4.0,
                                      color: Color.fromARGB(100, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '°C',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(150, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    currentWeather['current']?['condition']?['text'] ?? 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(150, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0, right: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                                  Text(
                                    ' ${dailyForecast.isNotEmpty ? dailyForecast[0]['day']['maxtemp_c'].toInt() : 0}° ',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Icon(Icons.arrow_downward, size: 16, color: Colors.white),
                                  Text(
                                    ' ${dailyForecast.isNotEmpty ? dailyForecast[0]['day']['mintemp_c'].toInt() : 0}°',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildWeatherInfoItem(
                                Icons.water_drop_outlined,
                                '${currentWeather['current']?['precip_mm'] ?? 0} mm',
                                'Precipitation',
                              ),
                              _buildWeatherInfoItem(
                                Icons.air,
                                '${currentWeather['current']?['wind_kph'] ?? 0} km/h',
                                '${currentWeather['current']?['wind_dir'] ?? ''}\nwind',
                              ),
                              _buildWeatherInfoItem(
                                Icons.wb_sunny_outlined,
                                'UV: ${currentWeather['current']?['uv'] ?? 0}',
                                getUVDescription(currentWeather['current']?['uv'] ?? 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                dailyForecast.length > 1
                                    ? getWeatherIcon(dailyForecast[1]['day']['condition']['text'])
                                    : Icons.cloud_queue,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tomorrow',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    dailyForecast.length > 1
                                        ? dailyForecast[1]['day']['condition']['text']
                                        : 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_upward, size: 14, color: Colors.white70),
                                  Text(
                                    ' ${dailyForecast.length > 1 ? dailyForecast[1]['day']['maxtemp_c'].toInt() : 0}° ',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Icon(Icons.arrow_downward, size: 14, color: Colors.white70),
                                  Text(
                                    ' ${dailyForecast.length > 1 ? dailyForecast[1]['day']['mintemp_c'].toInt() : 0}°',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom drawer with hourly forecast
                DraggableScrollableSheet(
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
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
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 10, bottom: 10),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0, top: 10.0),
                              child: Text(
                                'Hourly Forecast',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: hourlyForecast.length,
                                itemBuilder: (context, index) {
                                  if (index % 3 != 0) return const SizedBox.shrink(); // Show every 3 hours
                                  
                                  final hourData = hourlyForecast[index];
                                  final time = DateFormat('HH:mm').format(
                                      DateTime.parse(hourData['time']));
                                  final temp = hourData['temp_c'].toInt().toString();
                                  final condition = hourData['condition']['text'];
                                  
                                  return _buildHourlyForecast(
                                    time,
                                    getWeatherIcon(condition),
                                    '$temp°',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text(
                                'Weekly Forecast',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dailyForecast.length,
                              itemBuilder: (context, index) {
                                final dayData = dailyForecast[index];
                                final date = DateTime.parse(dayData['date']);
                                final dayName = DateFormat('EEEE').format(date);
                                final condition = dayData['day']['condition']['text'];
                                final maxTemp = dayData['day']['maxtemp_c'].toInt().toString();
                                final minTemp = dayData['day']['mintemp_c'].toInt().toString();
                                
                                return _buildDailyForecast(
                                  dayName,
                                  getWeatherIcon(condition),
                                  '$maxTemp°',
                                  '$minTemp°',
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  String getUVDescription(dynamic uvIndex) {
    int uv = 0;
    if (uvIndex is int) {
      uv = uvIndex;
    } else if (uvIndex is double) {
      uv = uvIndex.toInt();
    }
    
    if (uv <= 2) return 'Low risk';
    if (uv <= 5) return 'Moderate risk';
    if (uv <= 7) return 'High risk';
    if (uv <= 10) return 'Very high risk';
    return 'Extreme risk';
  }

  Widget _buildWeatherInfoItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(String time, IconData icon, String temp) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            icon,
            color: Colors.black54,
          ),
          const SizedBox(height: 8),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyForecast(String day, IconData icon, String highTemp, String lowTemp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Icon(
            icon,
            color: Colors.black54,
            size: 24,
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  highTemp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  lowTemp,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}