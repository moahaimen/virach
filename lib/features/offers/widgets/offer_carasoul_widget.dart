// lib/features/offers/widgets/offer_carousel_widget.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../models/offer_model.dart';
import '../screens/offer_details_screen.dart';

class OfferCarouselWidget extends StatelessWidget {
  const OfferCarouselWidget({super.key, required this.offers});

  final List<Offer> offers;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.width * 0.45;

    return CarouselSlider.builder(
      itemCount: offers.length,
      options: CarouselOptions(
        height: height,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1,   // صور بعرض الشاشة بالكامل
      ),
      itemBuilder: (ctx, index, __) {
        final offer = offers[index];
        final img   = offer.image.startsWith('http')
            ? NetworkImage(offer.image)
            : AssetImage(offer.image) as ImageProvider;

        return GestureDetector(
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
          ),
          child: Container(
            // إجبار العنصر على أخذ عرض الشاشة
            width: MediaQuery.of(ctx).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // الصورة
                  Image(image: img, fit: BoxFit.cover),
                  // تدرّج غامق أسفل الصورة
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  // العنوان والوصف
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان
                        Text(
                          offer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        // الوصف (اختَر الحقل المناسب أو اتركه فارغًا إن لم يوجد)
                        if (offer.location.isNotEmpty)
                          Text(
                            offer.location,          // أو أي حقل وصف تريده
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
