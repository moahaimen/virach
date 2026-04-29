import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> jobSeeker;

  ProfileHeader({required this.jobSeeker});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              jobSeeker['profileImage'] ?? 'https://via.placeholder.com/150',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            jobSeeker['name'] ?? 'No Name Provided',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            jobSeeker['specialty'] ?? 'Job Seeker',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
