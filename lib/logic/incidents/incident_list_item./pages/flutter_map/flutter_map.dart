import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class IncidentMap extends StatelessWidget {
  final _mapController = MapController();
  final double lat;
  final double long;
  IncidentMap({
    super.key,
    required this.lat,
    required this.long
  });


  @override
  Widget build(BuildContext context) {
    final _currentLocation = LatLng(lat, long);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
          initialCenter: _currentLocation,
          keepAlive: true,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          errorTileCallback: (tile, error, stackTrace) {
            print('Errore tile: $error');
          },
            userAgentPackageName: 'com.example.impaxt_alert',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: _currentLocation,
              child: Icon(
                Icons.location_on,
                size: 48.0,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
