import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/features/common_screens/search_filters_pages/doctors/widgets/doctor_map_card.dart';
import 'package:racheeta/features/doctors/models/doctors_model.dart';
import 'package:racheeta/features/doctors/providers/doctors_provider.dart';

class DoctorMapScreen extends StatefulWidget {
  @override
  _DoctorMapScreenState createState() => _DoctorMapScreenState();
}

class _DoctorMapScreenState extends State<DoctorMapScreen> {
  final List<Marker> _markers = [];
  List<DoctorModel> _nearbyDoctors = [];
  // LatLng _currentLocation = LatLng(
  //     33.29527035046401, 44.330616798542515); // Fixed location for emulator
  final double _radius = 30000.0; // 3 km radius
  final MapController _mapController = MapController();
  double _currentZoom = 17.0;
  LatLng _currentLocation = LatLng(0, 0); // Will be updated by GPS
  LatLng _fallbackLocation = LatLng(33.274648, 44.296158); // Your stored location
  bool _useFallback = false; // Track which mode is active

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _getCurrentLocation();

  }

  // Fetch doctors from the backend
// Fetch doctors from the backend
  Future<void> _fetchDoctors() async {
    try {
      final provider =
          Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
      final doctors = await provider.fetchAllDoctors();
      _filterDoctorsByDistance(
          doctors); // Pass the doctors list to the function
    } catch (e) {
      print("Error fetching doctors: $e");
    }
  }

  void _useStoredLocation() {
    setState(() {
      _currentLocation = _fallbackLocation;
      _useFallback = true;
    });
    _mapController.move(_currentLocation, _currentZoom);
    _fetchDoctors(); // Recalculate from stored location
  }


  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _useFallback = false;
      });
      _mapController.move(_currentLocation, _currentZoom);
      _fetchDoctors(); // You can filter based on new location
    } catch (e) {
      print("Failed to get current location: $e");
    }
  }

// Filter doctors by distance from the current location
  void _filterDoctorsByDistance(List<DoctorModel> doctors) {
    print("Filtering doctors by distance...");

    List<DoctorModel> nearby = [];

    for (final doctor in doctors) {
      final gpsLocation = doctor.user?.gpsLocation?.split(',');
      if (gpsLocation == null || gpsLocation.length != 2) continue;

      final double? lat = double.tryParse(gpsLocation[0]);
      final double? lng = double.tryParse(gpsLocation[1]);
      if (lat == null || lng == null) continue;

      final LatLng doctorPos = LatLng(lat, lng);
      final double distance = _calculateDistance(_currentLocation, doctorPos);

      if (distance <= _radius) {
        nearby.add(doctor);
      }
    }

    setState(() {
      _nearbyDoctors = nearby;
    });

    _setMarkers(nearby);
  }

  // Calculate the distance between two locations
  double _calculateDistance(LatLng start, LatLng end) {
    final Distance distance = Distance();
    final calculatedDistance = distance.as(LengthUnit.Meter, start, end);
    return calculatedDistance;
  }

// Set markers on the map for the filtered doctors
  void _setMarkers(List<DoctorModel> doctors) {
    print("Setting markers for ${doctors.length} doctors...");
    _markers.clear();

    for (final doctor in doctors) {
      try {
        // Extract and parse GPS coordinates
        final gpsString = doctor.user?.gpsLocation;
        if (gpsString == null || !gpsString.contains(",")) {
          print("Skipping '${doctor.user?.fullName}' — no valid GPS string.");
          continue;
        }

        final parts = gpsString.split(",");
        if (parts.length != 2) {
          print("Skipping '${doctor.user?.fullName}' — malformed GPS data.");
          continue;
        }

        final double? lat = double.tryParse(parts[0].trim());
        final double? lng = double.tryParse(parts[1].trim());

        if (lat == null || lng == null) {
          print("Skipping '${doctor.user?.fullName}' — invalid lat/lng numbers.");
          continue;
        }

        final LatLng position = LatLng(lat, lng);

        // Determine image to show
        final String imagePath = doctor.user?.profileImage != null &&
            doctor.user!.profileImage!.isNotEmpty
            ? doctor.user!.profileImage!
            : 'assets/icons/doctor_icon.png';

        _markers.add(
          Marker(
            point: position,
            width: 80,
            height: 80,
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );

        print("✅ Added marker: '${doctor.user?.fullName}' at $position");
      } catch (e) {
        print("❌ Error creating marker for '${doctor.user?.fullName}': $e");
      }
    }

    setState(() {}); // Refresh UI with new markers
  }


  // Zoom in on the map
  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
      _mapController.move(_currentLocation, _currentZoom);
    });
  }

  // Zoom out on the map
  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
      _mapController.move(_currentLocation, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors Map'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // Map with markers
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation, // Fixed location
              initialZoom: _currentZoom,
              maxZoom: 19.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          // Zoom controls
          Positioned(
            right: 10,
            top: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "my_location",
                  mini: true,
                  backgroundColor: Colors.green,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "fallback_location",
                  mini: true,
                  backgroundColor: Colors.orange,
                  onPressed: _useStoredLocation,
                  child: const Icon(Icons.location_on),
                ),
                const SizedBox(height: 10),

          FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: Colors.blue,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.blue,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
          // Doctor cards at the bottom
          if (_nearbyDoctors.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _nearbyDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = _nearbyDoctors[index];
                  return DoctorMapCard(
                    doctor: doctor, // Pass the correct doctor object here
                  );
                },
              ),
            )
          else
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: const Center(
                child: Text('No doctors found nearby'),
              ),
            ),
        ],
      ),
    );
  }
}
