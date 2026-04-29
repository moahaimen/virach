import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HspProfileImagePicker extends StatelessWidget {
  final XFile? imageFile;
  final Function(XFile?) onImagePicked;

  const HspProfileImagePicker({
    Key? key,
    required this.imageFile,
    required this.onImagePicked,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    onImagePicked(pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: CircleAvatar(
        radius: 60,
        backgroundImage: imageFile == null
            ? const AssetImage('assets/profile_placeholder.png')
                as ImageProvider
            : FileImage(File(imageFile!.path)),
        child: imageFile == null
            ? const Icon(
                Icons.camera_alt,
                size: 50,
                color: Colors.grey,
              )
            : null,
      ),
    );
  }
}
