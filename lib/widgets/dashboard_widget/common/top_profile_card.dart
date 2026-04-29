import 'dart:io';
import 'package:flutter/material.dart';

/// A reusable widget that displays avatar + “pick”/“camera” buttons.
/// Now allows nullable async callbacks: Future<void> Function()?
class TopProfileCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> centerDetails;
  final File? profileImage;
  final String? currentProfileImageUrl;
  final bool isEditMode;

  /// Changed type from `VoidCallback` to `Future<void> Function()?`
  final Future<void> Function()? onPickImage;
  final Future<void> Function()? onTakePhoto;

  const TopProfileCard({
    Key? key,
    required this.user,
    required this.centerDetails,
    required this.profileImage,
    required this.currentProfileImageUrl,
    required this.isEditMode,
    this.onPickImage,
    this.onTakePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullName = user['full_name'] ?? 'اسم غير متوفر';
    final centerName = centerDetails['center_name'] ?? '';
    final bio = centerDetails['bio'] ?? 'لا يوجد وصف';

    ImageProvider avatarImage;
    if (profileImage != null) {
      avatarImage = FileImage(profileImage!) as ImageProvider;
    } else if (currentProfileImageUrl != null &&
        currentProfileImageUrl!.isNotEmpty) {
      avatarImage = NetworkImage(currentProfileImageUrl!) as ImageProvider;
    } else {
      avatarImage =
      const AssetImage('assets/images/default_profile.png') as ImageProvider;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatarImage,
          ),
          const SizedBox(height: 16),
          if (isEditMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (onPickImage != null) ? () => onPickImage!() : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('اختيار من المعرض'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (onTakePhoto != null) ? () => onTakePhoto!() : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('التقاط صورة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            centerName,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
