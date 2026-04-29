import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For handling geographical coordinates

class PatientHistoryPage extends StatelessWidget {
  final Map<String, dynamic> patient;

  PatientHistoryPage({required this.patient});

  @override
  Widget build(BuildContext context) {
    // Assuming the patient's location is stored in 'latitude' and 'longitude' fields
    final double latitude =
        patient['latitude'] ?? 33.3152; // Default value for latitude
    final double longitude =
        patient['longitude'] ?? 44.3661; // Default value for longitude

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient History: ${patient['patientName']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment Date: ${patient['date']} at ${patient['time']}'),
            const SizedBox(height: 10),
            Text('Status: ${patient['status']}'),
            const SizedBox(height: 10),
            const Text('Contact'),
            const Row(
              children: [
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 10),
                Icon(Icons.message, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            const Text('History',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Previous Visits:'),
            const Text('1. 01/01/2021 - Checkup'),
            const Text('2. 02/15/2021 - Follow-up'),
            const SizedBox(height: 20),
            const Text('Patient Location',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Expanded widget for the map
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                      latitude, longitude), // Center map on patient's location
                  initialZoom: 13.0, // Initial zoom level
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(latitude, longitude),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
