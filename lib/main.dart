import 'package:flutter/material.dart';
import 'package:google_maps_demo/widgets/navigation_bar.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavigationMenu(),
    );
  }
}
