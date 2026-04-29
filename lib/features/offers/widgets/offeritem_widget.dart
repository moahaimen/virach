import 'package:flutter/material.dart';
import 'package:racheeta/models/offer_model.dart';
import 'package:racheeta/features/offers/screens/offer_details_screen.dart';

import '../../../constansts/constants.dart';

/// Decide whether a path is a network or asset image.
ImageProvider _imgProvider(String path) =>
    (path.startsWith('http') || path.startsWith('https'))
        ? NetworkImage(path)
        : AssetImage(path);

class OfferItem extends StatelessWidget {
  const OfferItem({
    Key?    key,
    required this.offer,
    required this.textStyle,
    this.onTap,
  }) : super(key: key);

  final Offer       offer;
  final TextStyle   textStyle;
  final VoidCallback? onTap;        // optional external tap handler

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap ??
              () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OfferDetailsScreen(offer: offer),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: w * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- image + discount badge ----------------
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image(
                      image: _imgProvider(offer.image),
                      height: w * 0.4,
                      width : double.infinity,
                      fit   : BoxFit.cover,
                    ),
                  ),
                  if (offer.discount.isNotEmpty)
                    Positioned(
                      top : 8,
                      left: 8,
                      child: Container(
                        padding: kDiscountBadgePadding,
                        decoration: kDiscountBorderPadding,
                        child: Text(
                          offer.discount,                // discount already contains %
                          style: kOfferDiscountTextStyle,
                        ),
                      ),
                    ),
                ],
              ),

              // ---------------- details ----------------
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('${offer.price} دينار',
                            style: textStyle.copyWith(fontSize: 14)),
                        const SizedBox(width: 8),
                        if (offer.oldPrice.isNotEmpty)
                          Text(
                            '${offer.oldPrice} دينار',
                            style: kOfferOldPriceTextStyle,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
