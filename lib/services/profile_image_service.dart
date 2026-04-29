import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A static helper for picking an image (with a 2 MB size check) and uploading it
/// to the `/users/{userId}/` endpoint. Returns the new image URL (or null on failure).
class ProfileImageService {
  /// Opens the gallery or camera to let the user pick a single image.
  /// If the chosen file is larger than 2 MB, shows a SnackBar and returns null.
  /// Otherwise returns the picked File.
  static Future<File?> pickAndValidateImage(BuildContext context, ImageSource src) async {
    try {
      final picked = await ImagePicker().pickImage(source: src);
      if (picked == null) return null; // user cancelled

      final file = File(picked.path);
      final bytes = await file.length();
      if (bytes > 2 * 1024 * 1024) {
        // file too big, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حجم الصورة أكبر من 2 ميجابايت')),
        );
        return null;
      }
      return file;
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة')),
      );
      return null;
    }
  }

  /// Uploads [imgFile] to `PATCH https://racheeta.pythonanywhere.com/users/{userId}/`
  /// with a multipart field `profile_image`. Returns the server’s `"profile_image"` URL
  /// if HTTP 200, or null on any error.
  static Future<String?> uploadProfileImage(File imgFile, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('Login_access_token') ?? '';
      if (token.isEmpty) return null;

      final dio = Dio()
        ..options.headers['Authorization'] = 'JWT $token';

      final form = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          imgFile.path,
          filename: imgFile.path.split('/').last,
        ),
      });

      final response = await dio.patch<Map<String, dynamic>>(
        'https://racheeta.pythonanywhere.com/users/$userId/',
        data: form,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The server should return a JSON with "profile_image": "<new_url>"
        final newUrl = response.data?['profile_image']?.toString();
        return newUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }
}
