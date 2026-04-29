import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final Function(File) onImagePicked; // Add the required onImagePicked callback

  const ProfileImagePicker({required this.onImagePicked}); // Make it required

  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Call the onImagePicked callback to pass the picked image back
      widget.onImagePicked(_profileImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 100,
          backgroundImage:
              _profileImage != null ? FileImage(_profileImage!) : null,
          child: _profileImage == null
              ? Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        TextButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text('رفع صورة'),
          onPressed: _pickImage, // Call the image picker method
        ),
      ],
    );
  }
}
