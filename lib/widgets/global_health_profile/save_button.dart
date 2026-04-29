import 'package:flutter/material.dart';
import 'package:racheeta/constansts/constants.dart';

class SaveButton extends StatelessWidget {
  final Function onSave;

  const SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: kRedElevatedButtonStyle,
        onPressed: () => onSave(),
        child: const Text('احفظ المعلومات', style: kButtonTextStyle),
      ),
    );
  }
}
