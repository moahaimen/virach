import 'package:flutter/material.dart';
import 'package:racheeta/utitlites/phone_call.dart';
import 'package:racheeta/utitlites/pick_image.dart';

class ServiceOptionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ServiceOption(
            icon: Icons.phone, label: 'استشير صيدلي', onTap: callPharmacist),
        ServiceOption(
            icon: Icons.camera_alt, label: 'صورة المنتج', onTap: pickImage),
        ServiceOption(
            icon: Icons.note, label: 'روشتة / موافقة طبية', onTap: pickImage),
      ],
    );
  }
}

class ServiceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function(BuildContext) onTap;

  ServiceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
