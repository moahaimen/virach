import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;

  const MapPickerScreen({Key? key, this.initialPosition}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? pickedLocation;
  final MapController _mapController = MapController();
  double _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    pickedLocation = widget.initialPosition ?? LatLng(33.3128, 44.3615); // Baghdad fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر الموقع من الخريطة')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pickedLocation!,
              initialZoom: _currentZoom,
              onTap: (tapPos, latlng) {
                setState(() {
                  pickedLocation = latlng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.racheeta.app',
              ),

              if (pickedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on,
                          size: 40, color: Colors.red),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  onPressed: () {
                    setState(() {
                      _currentZoom += 1;
                      _mapController.move(pickedLocation!, _currentZoom);
                    });
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  onPressed: () {
                    setState(() {
                      _currentZoom -= 1;
                      _mapController.move(pickedLocation!, _currentZoom);
                    });
                  },
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, pickedLocation),
        label: const Text("تأكيد"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
