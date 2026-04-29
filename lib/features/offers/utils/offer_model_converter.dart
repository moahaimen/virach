// lib/features/offers/utils/offer_model_converter.dart

import 'package:racheeta/features/offers/models/offers_model.dart';
import 'package:racheeta/models/offer_model.dart'; // for OffersModel

Offer convertOffersModelToOffer(OffersModel m) {
  return Offer(
    name:        m.offerTitle        ?? 'بدون عنوان',
    image:       (m.offerImage?.isNotEmpty ?? false)
        ? m.offerImage!
        : 'assets/banner1.jpg',
    discount:    m.discountPercentage ?? '0%',
    price:       m.discountedPrice    ?? '0',
    oldPrice:    m.originalPrice      ?? '0',
    rating:      4.5,
    reviews:     300,
    location:    'لم يتم تحديد الموقع',
    doctorName:  'مزود الخدمة',
  );
}
