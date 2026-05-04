import 'package:flutter/material.dart';
import 'package:racheeta/models/offer_model.dart';
import 'package:racheeta/features/offers/screens/offer_details_screen.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

ImageProvider _imgProvider(String path) =>
    (path.startsWith('http') || path.startsWith('https'))
        ? NetworkImage(path)
        : AssetImage(path);

class OfferItem extends StatelessWidget {
  const OfferItem({
    super.key,
    required this.offer,
    this.onTap,
  });

  final Offer offer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return RacheetaCard(
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.zero,
      onTap: onTap ??
          () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfferDetailsScreen(offer: offer),
                ),
              ),
      child: SizedBox(
        width: w * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Discount Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Image(
                    image: _imgProvider(offer.image),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: RacheetaColors.mintLight,
                      child: const Icon(Icons.image_not_supported_outlined, color: RacheetaColors.primary),
                    ),
                  ),
                ),
                if (offer.discount.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: RacheetaColors.danger,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        offer.discount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: RacheetaColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.doctorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${offer.price} د.ع',
                            style: const TextStyle(
                              color: RacheetaColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          if (offer.oldPrice.isNotEmpty)
                            Text(
                              '${offer.oldPrice} د.ع',
                              style: const TextStyle(
                                color: RacheetaColors.textSecondary,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: RacheetaColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 14,
                          color: RacheetaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
