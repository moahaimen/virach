import 'package:flutter/material.dart';
import 'package:racheeta/models/offer_model.dart';
import 'package:racheeta/features/offers/screens/offer_details_screen.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

ImageProvider _imgProvider(String path) =>
    (path.startsWith('http') || path.startsWith('https'))
        ? NetworkImage(path)
        : AssetImage(path);

class OfferListItem extends StatelessWidget {
  const OfferListItem({
    super.key,
    required this.offer,
    this.onTap,
  });

  final Offer offer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    void _navigate() => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
        );

    return RacheetaCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      onTap: onTap ?? _navigate,
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
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: RacheetaColors.mintLight,
                    child: const Icon(Icons.image_not_supported_outlined, color: RacheetaColors.primary),
                  ),
                ),
              ),
              if (offer.discount.isNotEmpty)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: RacheetaColors.danger,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      offer.discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: RacheetaColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: RacheetaColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${offer.doctorName} • ${offer.location.isNotEmpty ? offer.location : "العراق"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${offer.price} د.ع',
                            style: const TextStyle(
                              color: RacheetaColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (offer.oldPrice.isNotEmpty)
                            Text(
                              '${offer.oldPrice} د.ع',
                              style: const TextStyle(
                                color: RacheetaColors.textSecondary,
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.arrow_back_ios_new, color: RacheetaColors.primary, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
