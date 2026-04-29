import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'location_selector.dart'; // Adjust path

class BuildLocationMap extends StatelessWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationChanged;
  final TextEditingController? addressController;
  final bool enabled;

  const BuildLocationMap({
    Key? key,
    required this.initialLocation,
    required this.onLocationChanged,
    this.addressController,
    this.enabled = true, // default to true for backward compatibility
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "الموقع الجغرافي",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: !enabled,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: LocationSelectorMap(
              initialLocation: initialLocation,
              onLocationChanged: (LatLng newLocation) {
                onLocationChanged(newLocation);
                if (addressController != null) {
                  addressController!.text =
                  "${newLocation.latitude}, ${newLocation.longitude}";
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
