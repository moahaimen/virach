import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;
import '../../../../../models/medicals/bagdhad_districts_list.dart';
import 'package:latlong2/latlong.dart';

class HomeVisitScreen extends StatefulWidget {
  @override
  _HomeVisitScreenState createState() => _HomeVisitScreenState();
}

class _HomeVisitScreenState extends State<HomeVisitScreen> {
  String? selectedDistrict; // To store the selected district
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedSpecialty;
  String? _selectedDistrict;
  LatLng? _currentLocation;

  final List<String> specialties = ['تخصص 1', 'تخصص 2', 'تخصص 3'];

  final List<Map<String, dynamic>> hspData = [
    {
      'name': 'HSP1',
      'latitude': 33.3152,
      'longitude': 44.3661,
      'district': 'الكرخ'
    }, // Example HSPs
    {
      'name': 'HSP2',
      'latitude': 33.3182,
      'longitude': 44.3963,
      'district': 'الرصافة'
    },
    {
      'name': 'HSP3',
      'latitude': 33.3416,
      'longitude': 44.3895,
      'district': 'مدينة الصدر'
    },
    // Add more HSPs here with their latitude, longitude, and district
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fetch current location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  // Calculate distance between two lat-long points
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295; // Pi/180
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R * asin...
  }

  // Find nearest HSP based on user's location or district
  Map<String, dynamic>? _findNearestHSP() {
    double minDistance = double.infinity;
    Map<String, dynamic>? nearestHSP;

    if (_currentLocation != null) {
      for (var hsp in hspData) {
        if (_selectedDistrict == null || hsp['district'] == _selectedDistrict) {
          double distance = calculateDistance(_currentLocation!.latitude,
              _currentLocation!.longitude, hsp['latitude'], hsp['longitude']);
          if (distance < minDistance) {
            minDistance = distance;
            nearestHSP = hsp;
          }
        }
      }
    }
    return nearestHSP;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'احجز زيارة منزلية',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'احجز زيارة منزلية الآن من خلال تطبيقنا في رشيطة، يمكنك حجز زيارة منزلية مع دكتور متخصص.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'رقم التليفون',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'التخصص',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSpecialty,
                items: specialties.map((specialty) {
                  return DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'اختر المنطقة',
                  border: OutlineInputBorder(),
                ),
                items: districts.map((district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value; // Store the selected district
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _findNearestHSP();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'تأكيد',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ملاحظة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.right,
              ),
              const Text(
                '  تطبيق راجيتة هو بالاساس يعمل كوسيط بين المريض ومقدم الخدمات الطبية والصحية وغير مسؤول عن اي لقاء مباشر',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'جميع الحقوق محفوظة ٢٠٢٤',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
