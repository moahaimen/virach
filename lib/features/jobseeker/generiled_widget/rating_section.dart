import 'package:flutter/material.dart';

class RatingSection extends StatelessWidget {
  final dynamic rating;

  RatingSection({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: Colors.orange, size: 24),
        const SizedBox(width: 5),
        Text(
          'Rating: ${rating ?? 'N/A'}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
