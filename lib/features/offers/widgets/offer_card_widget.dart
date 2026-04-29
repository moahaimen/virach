// lib/features/offers/widgets/offer_card_item.dart
import 'package:flutter/material.dart';
import '../../../models/offer_model.dart';
import '../screens/offer_details_screen.dart';

class OfferCardItem extends StatelessWidget {
  final Offer offer;

  const OfferCardItem({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: offer.image.startsWith('http')
                      ? NetworkImage(offer.image)
                      : AssetImage(offer.image) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    const SizedBox(height: 4),
                    Text("${offer.discount}% خصم", style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 4),
                    Text("السعر: ${offer.price} د.ع", style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
