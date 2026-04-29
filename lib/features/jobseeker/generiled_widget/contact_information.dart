import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInformation extends StatelessWidget {
  final Map<String, dynamic> jobSeeker;

  ContactInformation({required this.jobSeeker});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل الاتصال',
          style: TextStyle(color: Colors.blue, fontSize: 20),
        ),
        const SizedBox(height: 10),
        _buildInfoRow(
          icon: Icons.phone,
          label: 'رقم الهاتف',
          value: jobSeeker['phone'] ?? 'No phone number',
          onTap: () => _makePhoneCall(jobSeeker['phone'] ?? ''),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.chat,
          label: 'اعمل محادثة',
          value: 'اضغط للمحادثة',
          onTap: () => _startChat(context),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(launchUri);
    }
  }

  void _startChat(BuildContext context) {
    // Implement chat functionality here
  }
}
