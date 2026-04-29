import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  final String imagePath;
  final String text;

  SplashContent({required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 50),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ],
    );
  }
}
