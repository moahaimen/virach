// // lib/features/offers/widgets/offer_group_section.dart
// import 'package:flutter/material.dart';
//
// import 'package:racheeta/features/offers/models/offers_model.dart';
// import 'package:racheeta/models/offer_model.dart'; // for OffersModel
//
// import 'offer_card_widget.dart';
//
// OffersModel convertOffersModelToOffer(OffersModel model) {
//   return OffersModel(
//     name: model.offerTitle ?? 'بدون عنوان',
//     image: model.offerImage?.isNotEmpty == true
//         ? model.offerImage!
//         : 'assets/banner1.jpg',
//     discount: model.discountPercentage ?? '0%',
//     price: model.discountedPrice ?? '0',
//     oldPrice: model.originalPrice ?? '0',
//     rating: 4.5,
//     reviews: 300,
//     location: 'لم يتم تحديد الموقع',
//     doctorName: 'مزود الخدمة',
//   );
// }
//
// class OfferGroupSection extends StatelessWidget {
//   final String title;
//   final List<OffersModel> offers;
//
//   const OfferGroupSection({super.key, required this.title, required this.offers});
//
//   @override
//   Widget build(BuildContext context) {
//     final textStyle = const TextStyle(
//       color: Color(0xFF007BFF),
//       fontWeight: FontWeight.bold,
//       fontSize: 18,
//     );
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: textStyle),
//           const SizedBox(height: 6),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: offers.length,
//             itemBuilder: (_, index) {
//               final offer = convertOffersModelToOffer(offers[index]);
//               return OfferCardItem(offer: offer);
//             },
//           )
//         ],
//       ),
//     );
//   }
// }
