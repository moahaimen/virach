// import '../../../constansts/constants.dart';
// import '../models/offers_model.dart';
// import '../models/ui_offer_model.dart';
//
// /// Convert a backend `OffersModel` into a UI-friendly `Offer`.
// UIOffer toOffer(OffersModel m) => UIOffer(
//   id           : m.id ?? '',
//   name         : m.offerTitle ?? '—',
//   image        : (m.offerImage?.isNotEmpty ?? false)
//       ? (m.offerImage!.startsWith('http')
//       ? m.offerImage!
//       : '$baseUrl${m.offerImage!}')
//       : 'assets/banner1.jpg',
//   discount     : m.discountPercentage ?? '0',
//   price        : m.discountedPrice    ?? '0',
//   oldPrice     : m.originalPrice      ?? '0',
//   providerName : m.providerName       ?? '',
//   location     : m.providerLocation   ?? '',
//   providerType : m.serviceProviderType?? '',
//   offerType    : m.offerType          ?? '',
//   rating       : 4.5,   // TODO replace when backend sends real rating
//   reviews      : 0,     // TODO replace when backend sends review count
// );
