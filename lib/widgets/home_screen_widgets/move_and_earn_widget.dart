import 'package:flutter/material.dart';

class MoveAndEarnSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading:
                  Image.network('https://via.placeholder.com/80', height: 80),
              title: const Text(
                'اهتم بصحتك اليوم حتى لاتتعب غدا راجع طبيب التغذية واهتم بالرياضة',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('ابدأ الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
