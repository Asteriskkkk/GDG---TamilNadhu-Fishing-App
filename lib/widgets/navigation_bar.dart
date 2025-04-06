import 'package:flutter/material.dart';
import 'package:google_maps_demo/features/map/presentation/screens/map_screen.dart';
import 'package:google_maps_demo/features/weather/presentation/screens/weather_screen.dart';
import 'package:google_maps_demo/pages/home_page.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int currentPageIndex = 0;

  final List<Widget> _pages = [
    FishingAppHomePage(),
    MapPage(),
    WeatherScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.blue[100],

        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.map), label: "Map"),
          NavigationDestination(icon: Icon(Icons.cloud), label: "Weather"),
          // NavigationDestination(
          //   icon: Icon(Icons.notifications),
          //   label: "Alerts",
          // ),
        ],
      ),

      body: _pages[currentPageIndex],
    );
  }
}
