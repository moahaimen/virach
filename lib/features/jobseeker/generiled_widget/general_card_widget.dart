import 'package:flutter/material.dart';
import 'package:racheeta/constansts/constants.dart';

class GeneralCardWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onPressed;
  final String buttonText;

  GeneralCardWidget({
    required this.data,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(data['profileImage']),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text('التخصص: ${data['specialty']}'),
                  Text('الشهادة: ${data['degree']}'),
                  Text('العنوان: ${data['address']}'),
                ],
              ),
            ),
            ElevatedButton(
              style: kRedButtonStyle,
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: kButtonTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
