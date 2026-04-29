import 'package:flutter/material.dart';
import 'package:racheeta/models/offer_model.dart';
import 'package:racheeta/features/offers/screens/offer_details_screen.dart';

import '../../constansts/constants.dart';

/// Choose between network and asset images.
ImageProvider _imgProvider(String path) =>
    (path.startsWith('http') || path.startsWith('https'))
        ? NetworkImage(path)
        : AssetImage(path);

class OfferListItem extends StatelessWidget {
  const OfferListItem({
    Key? key,
    required this.offer,
    required this.textStyle,
    this.onTap,
  }) : super(key: key);

  final Offer        offer;
  final TextStyle    textStyle;
  final VoidCallback? onTap;   // optional external handler

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    void _navigate() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
    );

    return GestureDetector(
      onTap: onTap ?? _navigate,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------- IMAGE + DISCOUNT BADGE ----------
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image(
                      image: _imgProvider(offer.image),
                      height: h * 0.20,
                      width : double.infinity,
                      fit   : BoxFit.cover,
                    ),
                  ),
                  if (offer.discount.isNotEmpty)
                    Positioned(
                      top : 8,
                      right: 8,
                      child: Container(
                        padding: kDiscountBadgePadding,
                        decoration: kDiscountBorderPadding,
                        child: Text(
                          offer.discount,               // already contains %
                          style: kOfferDiscountTextStyle,
                        ),
                      ),
                    ),
                  const Positioned(
                    bottom: 8,
                    right : 8,
                    child : CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/offers/doctor.png'),
                    ),
                  ),
                ],
              ),

              // ---------- DETAILS ----------
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // name
                    Text(offer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kOfferNameTextStyle),

                    const SizedBox(height: 4),

                    // provider + location
                    Text(offer.doctorName, style: kDoctorRatingTextStyle),
                    if (offer.location.isNotEmpty)
                      Text(offer.location, style: kDoctorRatingTextStyle),

                    const SizedBox(height: 4),

                    // price
                    Row(
                      children: [
                        Text('${offer.price} دينار',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const SizedBox(width: 8),
                        if (offer.oldPrice.isNotEmpty)
                          Text('${offer.oldPrice} دينار',
                              style: kOfferOldPriceTextStyle),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${offer.rating}',
                            style: const TextStyle(fontSize: 14)),
                        Text(' (${offer.reviews})',
                            style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // reserve button
                    ElevatedButton(
                      onPressed: onTap ?? _navigate,
                      style: kRedRoundedButtonStyle,
                      child: const Text('احجز', style: kOfferReserveButtonTextStyle),
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
