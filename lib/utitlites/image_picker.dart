import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('كاميرا'),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
              // Handle the picked image
              if (pickedFile != null) {
                print('Image selected: ${pickedFile.path}');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('معرض الصور'),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile =
                  await _picker.pickImage(source: ImageSource.gallery);
              // Handle the picked image
              if (pickedFile != null) {
                print('Image selected: ${pickedFile.path}');
              }
            },
          ),
        ],
      ),
    );
  }
}
