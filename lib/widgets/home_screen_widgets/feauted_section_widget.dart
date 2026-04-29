import 'package:flutter/material.dart';

class FeaturedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: Colors.teal,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'للاعلان اتصل بنا',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'حجوزاتك معنا تضمنلك الحصول على افضل الاطباء والمعالجين ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // ✨ FIX — use Theme-based text style
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge!                // inherit:true
                    .copyWith(fontFamily: 'Cairo'),
              ),
              child: const Text('التفاصيل'),
            ),
          ],
        ),
      ),
    );
  }
}
