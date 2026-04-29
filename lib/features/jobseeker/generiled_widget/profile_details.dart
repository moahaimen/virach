import 'package:flutter/material.dart';

class ProfileDetails extends StatelessWidget {
  final Map<String, dynamic> jobSeeker;

  ProfileDetails({required this.jobSeeker});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileDetail('التخصص:', jobSeeker['specialty']),
        _buildProfileDetail('الشهادة', jobSeeker['degree']),
        _buildProfileDetail('العنوان:', jobSeeker['address']),
        _buildProfileDetail('العمر:', '${jobSeeker['age'] ?? 'N/A'} years'),
      ],
    );
  }

  Widget _buildProfileDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black54),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
