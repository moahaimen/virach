import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: RacheetaColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: RacheetaColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: RacheetaColors.mintLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.verified_outlined, color: RacheetaColors.primary, size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('حجز صحي أوضح وأسرع', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text('اختر الخدمة، قارن الخيارات، واحجز من مزودي خدمات قريبين منك.', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
