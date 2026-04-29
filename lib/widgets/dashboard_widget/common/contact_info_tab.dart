import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../gps_maps/location_selector.dart';
import 'labeled_text_field.dart';
import 'city_district_selector.dart';

/// Tab widget that shows contact information: city, district, address, and map picker.
class ContactInfoTab extends StatelessWidget {
  final String? selectedCity;
  final String? selectedDistrict;

  final TextEditingController addressController;
  final LatLng? location;
  final LatLng defaultLocation;
  final bool isEditMode;

  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onDistrictChanged;
  final ValueChanged<LatLng> onLocationChanged;

  const ContactInfoTab({
    Key? key,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.addressController,
    required this.location,
    required this.defaultLocation,
    required this.isEditMode,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          CityDistrictSelector(
            city: selectedCity,
            district: selectedDistrict,
            enabled: isEditMode,
            onCityChanged: (val) => onCityChanged(val),
            onDistrictChanged: (val) => onDistrictChanged(val),
          ),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'العنوان (نص كامل)',
            controller: addressController,
            maxLines: 2,
            enabled: isEditMode,
          ),
          const SizedBox(height: 12),
          LocationSelectorMap(
            initialLocation: location ?? defaultLocation,
            onLocationChanged: onLocationChanged,
            enabled: isEditMode, // disable map buttons until edit mode
          ),
        ],
      ),
    );
  }
}
