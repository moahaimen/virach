import 'package:flutter/material.dart';
import '../models/offers_model.dart';

class PriceInfo extends StatelessWidget {
  const PriceInfo({super.key, required this.offer});

  final OffersModel offer;

  @override
  Widget build(BuildContext context) {
    final discount   = offer.discountPercentage ?? '0';
    final original   = offer.originalPrice      ?? '0';
    final discounted = offer.discountedPrice    ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Text('نسبة الخصم: '), Text('$discount%')]),
        Row(children: [const Text('السعر الأصلي: '), Text('$original ريال')]),
        Row(children: [const Text('السعر بعد الخصم: '), Text('$discounted ريال')]),
        if (offer.startDate?.isNotEmpty == true)
          Text('تاريخ البدء: ${offer.startDate!}', style: const TextStyle(fontSize: 12)),
        if (offer.endDate?.isNotEmpty == true)
          Text('تاريخ الانتهاء: ${offer.endDate!}', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
