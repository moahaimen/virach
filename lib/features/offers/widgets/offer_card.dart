import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:racheeta/features/offers/widgets/price_info.dart';

import '../../../constansts/constants.dart';
import '../models/offers_model.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    this.onEdit,
    this.onDelete,
    this.imageHeight = 150,
  });

  final OffersModel  offer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final double       imageHeight;

  @override
  Widget build(BuildContext context) {
    // قائمة الأزرار تتكوّن ديناميكيًا حسب القيم الممرَّرة
    final List<Widget> _actions = [
      if (onEdit != null)
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('تعديل', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        ),
      if (onDelete != null)
        ElevatedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text('حذف', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
    ];

    return Card(
      margin: kCardMargin,                                 // ← ثابت عالمي
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),  // ← ثابت عالمي
      ),
      elevation: 3,
      child: Padding(
        padding: kCardPadding,                             // ← ثابت عالمي
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offer.offerImage?.isNotEmpty == true)
              ClipRRect(
                borderRadius: BorderRadius.circular(kCardRadius),
                child: CachedNetworkImage(
                  imageUrl: offer.offerImage!,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 50),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              offer.offerTitle ?? 'عنوان العرض',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              offer.offerDescription ?? 'وصف العرض',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            PriceInfo(offer: offer),
            const SizedBox(height: 8),
            // Wrap يسمح بتعدّد الأسطر تلقائيًا إذا ضاق المكان
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _actions,
            ),
          ],
        ),
      ),
    );
  }
}
