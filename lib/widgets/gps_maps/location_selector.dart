// lib/widgets/gps_maps/location_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../utitlites/map_picker.dart';

/// A widget that displays a small map and two buttons:
/// - “Use My Location”
/// - “Pick From Map”
///
/// If [enabled] is false, both buttons are disabled.
class LocationSelectorMap extends StatefulWidget {
  final LatLng initialLocation;
  final void Function(LatLng) onLocationChanged;
  final bool enabled;

  const LocationSelectorMap({
    Key? key,
    required this.initialLocation,
    required this.onLocationChanged,
    this.enabled = true, // default to enabled
  }) : super(key: key);

  @override
  State<LocationSelectorMap> createState() => _LocationSelectorMapState();
}

class _LocationSelectorMapState extends State<LocationSelectorMap> {
  late LatLng _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  Future<void> _useCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("صلاحية الموقع مرفوضة")),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedLocation, 13);
      });

      widget.onLocationChanged(_selectedLocation);
    } catch (e) {
      debugPrint("❌ Error fetching current location: $e");
    }
  }

  Future<void> _pickLocationFromMap() async {
    final picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialPosition: _selectedLocation),
      ),
    );

    if (picked != null && picked is LatLng) {
      setState(() {
        _selectedLocation = picked;
        _mapController.move(_selectedLocation, 13);
      });

      widget.onLocationChanged(_selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "موقعك الجغرافي",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.racheeta.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: widget.enabled ? _useCurrentLocation : null,
              icon: const Icon(Icons.my_location),
              label: const Text("استخدم موقعي الحالي"),
            ),
            ElevatedButton.icon(
              onPressed: widget.enabled ? _pickLocationFromMap : null,
              icon: const Icon(Icons.map),
              label: const Text("اختر من الخريطة"),
            ),
          ],
        ),
      ],
    );
  }
}
