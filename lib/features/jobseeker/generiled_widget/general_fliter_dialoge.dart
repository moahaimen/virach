import 'package:flutter/material.dart';

class GeneralFilterDialog extends StatelessWidget {
  final List<String> specialties;
  final List<String> degrees;
  final List<String> addresses;
  final Function(String?, String?, String?) onApplyFilter;
  final String filterTitle;

  GeneralFilterDialog({
    required this.specialties,
    required this.degrees,
    required this.addresses,
    required this.onApplyFilter,
    required this.filterTitle,
  });

  @override
  Widget build(BuildContext context) {
    String? _selectedSpecialty;
    String? _selectedDegree;
    String? _selectedAddress;

    return AlertDialog(
      title: Text(filterTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'التخصص'),
            items: specialties.map((specialty) {
              return DropdownMenuItem(value: specialty, child: Text(specialty));
            }).toList(),
            onChanged: (value) => _selectedSpecialty = value,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'الشهادة'),
            items: degrees.map((degree) {
              return DropdownMenuItem(value: degree, child: Text(degree));
            }).toList(),
            onChanged: (value) => _selectedDegree = value,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'العنوان'),
            items: addresses.map((address) {
              return DropdownMenuItem(value: address, child: Text(address));
            }).toList(),
            onChanged: (value) => _selectedAddress = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('الغاء'),
        ),
        TextButton(
          onPressed: () {
            onApplyFilter(
                _selectedSpecialty, _selectedDegree, _selectedAddress);
            Navigator.of(context).pop();
          },
          child: const Text('تطبيق'),
        ),
      ],
    );
  }
}
