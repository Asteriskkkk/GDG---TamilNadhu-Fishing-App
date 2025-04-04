import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomTileProvider implements TileProvider {
  final String tileFolder = 'assets/tiles/'; // Directory where tiles are stored

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    if (zoom == null) return Future.value(TileProvider.noTile);

    String tilePath = '$tileFolder$zoom/$x/$y.png';

    try {
      final file = File(tilePath);
      if (await file.exists()) {
        Uint8List tileData = await file.readAsBytes();
        return Tile(256, 256, tileData);
      }
    } catch (e) {
      print("Tile not found: $tilePath, Error: $e");
    }

    return Future.value(TileProvider.noTile);
  }
}
