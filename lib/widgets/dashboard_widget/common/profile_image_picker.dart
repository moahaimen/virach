// lib/widgets/profile_image_picker.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final String userId;
  final bool enabled;
  final void Function(String newImageUrl) onUploadSuccess;

  const ProfileImagePicker({
    Key? key,
    required this.initialImageUrl,
    required this.userId,
    required this.onUploadSuccess,
    this.enabled = false,      // NEW: default to disabled
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _pickedFile;

  Future<void> _selectImage(ImageSource src) async {
    if (!widget.enabled) return;
    try {
      final picked = await ImagePicker().pickImage(source: src);
      if (picked == null) return;
      final file = File(picked.path);

      if (await file.length() > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حجم الصورة أكبر من 2MB')),
        );
        return;
      }

      setState(() => _pickedFile = file);
      await _uploadProfileImage(file, widget.userId);
    } catch (e) {
      debugPrint('Image error: $e');
    }
  }

  Future<void> _uploadProfileImage(File img, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('Login_access_token') ?? '';
      final dio = Dio()
        ..options.headers['Authorization'] = 'JWT $token';
      final form = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          img.path,
          filename: img.path.split('/').last,
        ),
      });

      final res = await dio.patch(
        'https://racheeta.pythonanywhere.com/users/$userId/',
        data: form,
      );

      if (res.statusCode == 200) {
        final newUrl = res.data['profile_image']?.toString() ?? '';
        widget.onUploadSuccess(newUrl);
        setState(() {
          _pickedFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة')),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // “اختيار من المعرض” Button
        ElevatedButton.icon(
          onPressed: widget.enabled
              ? () => _selectImage(ImageSource.gallery)
              : null,
          icon: const Icon(Icons.photo_library),
          label: const Text('اختيار من المعرض'),
        ),
        const SizedBox(width: 12),
        // “التقاط صورة” Button
        ElevatedButton.icon(
          onPressed:
          widget.enabled ? () => _selectImage(ImageSource.camera) : null,
          icon: const Icon(Icons.camera_alt),
          label: const Text('التقاط صورة'),
        ),
      ],
    );
  }
}
