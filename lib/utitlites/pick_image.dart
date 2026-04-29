import 'package:flutter/material.dart';
import 'image_picker.dart';

void pickImage(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ImageSourceSheet();
    },
  );
}
