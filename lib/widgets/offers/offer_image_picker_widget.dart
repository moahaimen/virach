import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(File?)
      onImageSelected; // Callback for passing the image back to the parent widget

  ImagePickerWidget({required this.onImageSelected});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image; // The selected image file

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Method to pick an image from a specified source (gallery or camera)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path); // Set the selected image
        widget.onImageSelected(
            _image); // Pass the image back to the parent widget
      } else {
        _image = null;
        widget.onImageSelected(null); // Pass null if no image is selected
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the selected image or a placeholder if no image is selected
        if (_image != null)
          Image.file(
            _image!,
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            fit: BoxFit.cover,
          )
        else
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.8,
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        const SizedBox(height: 10),
        // Buttons to pick image from the gallery or camera
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text('معرض الصور'),
              onPressed: () =>
                  _pickImage(ImageSource.gallery), // Pick from gallery
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('الكاميرا'),
              onPressed: () =>
                  _pickImage(ImageSource.camera), // Pick from camera
            ),
          ],
        ),
      ],
    );
  }
}
