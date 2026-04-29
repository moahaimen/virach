// lib/features/offers/screens/offer_details_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/offer_model.dart';
import '../../../constansts/constants.dart';
import '../services/coupon_services.dart';
import '../widgets/coupon_sheet_widget.dart';
import 'package:provider/provider.dart';          //  ← add this line

class OfferDetailsScreen extends StatelessWidget {
  final Offer offer;
  const OfferDetailsScreen({Key? key, required this.offer}) : super(key: key);

  // ---------------------------------------------------------------------------
  ImageProvider _img(String path) =>
      path.startsWith('http') ? NetworkImage(path) : AssetImage(path);

  /// Translate service-provider type to Arabic.
  String _providerAr(String type) {
    switch (type.toLowerCase()) {
      case 'doctor':
        return 'طبيب';
      case 'hospital':
        return 'مستشفى';
      case 'pharmacy':
        return 'صيدلية';
      case 'beauty_center':
        return 'مركز تجميل';
      case 'lab':
        return 'مختبر';
      default:
        return type;
    }
  }

  // days-left helper  🔥
  int? _daysLeft(String? isoEnd) {
    if (isoEnd == null) return null;
    final end = DateTime.tryParse(isoEnd);
    if (end == null) return null;
    final diff = end.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  Widget _iconText(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15)),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final imgHeight = w * 0.55; // responsive height
    final daysLeft = _daysLeft(offer.endDateFormatted); // ⚑ grab once

    return Scaffold(
      appBar: AppBar(
        title: Text(offer.name, style: kAppBarTextStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: kSectionPadding,
        child: Card(
          margin: kCardMargin,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kCardRadius)),
          elevation: 4,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ------------------------- IMAGE -------------------------
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(kCardRadius)),
              child: Image(
                image: _img(offer.image),
                width: w,
                height: imgHeight,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: kCardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------ TITLE ------------------------
                  Text(offer.name, style: kOfferNameTextStyle),

                  // -------------------- PROVIDER TYPE --------------------
                  const SizedBox(height: 6),
                  _iconText(Icons.storefront, _providerAr(offer.doctorName)),

                  // -------------------- DESCRIPTION ----------------------
                  if (offer.description != null &&
                      offer.description!.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text('وصف العرض:',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(offer.description!,
                        style: const TextStyle(fontSize: 16)),
                  ],

                  // -------------------- OFFER TYPE -----------------------
                  const SizedBox(height: 8),
                  _iconText(Icons.category, offer.offerType ?? '—'),

                  // -------------------- PRICE ROW ------------------------
                  const SizedBox(height: 18),
                  Row(children: [
                    // discount badge
                    Container(
                      padding: kDiscountBadgePadding,
                      decoration: kDiscountBorderPadding,
                      child:
                          Text(offer.discount, style: kOfferDiscountTextStyle),
                    ),
                    const SizedBox(width: 10),

                    // prices wrapped so they don't overflow
                    Expanded(
                      child: Row(children: [
                        Flexible(
                          child: Text('${offer.price} د.ع',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ),
                        const SizedBox(width: 6),
                        if (offer.oldPrice.isNotEmpty)
                          Flexible(
                            child: Text('${offer.oldPrice} د.ع',
                                overflow: TextOverflow.ellipsis,
                                style: kOfferOldPriceTextStyle),
                          ),
                      ]),
                    ),
                  ]),

                  // ---------------- PERIOD & DATES ----------------------
                  const SizedBox(height: 18),
                  _iconText(
                      Icons.schedule, 'المدة: ${offer.periodOfTime ?? '—'}'),
                  const SizedBox(height: 4),
                  _iconText(Icons.date_range,
                      'من: ${offer.startDateFormatted ?? '—'}'),
                  const SizedBox(height: 2),
                  _iconText(Icons.date_range,
                      'إلى: ${offer.endDateFormatted ?? '—'}'),
// days left
                  // 🔴 days-left indicator
                  if (daysLeft != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        daysLeft == 0 ? 'انتهى العرض' : 'باقي $daysLeft يوم',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  // ------------------ ACTION BTN -----------------------
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1) read user’s Arabic full-name from prefs
                        final prefs     = await SharedPreferences.getInstance();
                        final userName  = prefs.getString('full_name') ?? 'غير محدد';

                        // 2) create coupon with name + offer
                        final coupon = await context
                            .read<CouponService>()
                            .create(offer: offer, userName: userName);

                        // 3) show the coupon sheet
                        if (!context.mounted) return;
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          builder: (_) => CouponSheet(offer: offer, coupon: coupon),
                        );
                      },

                      style: kBlueButtonStyle,
                      child: const Text('احصل على العرض',
                          style: kReservationButtonTextStyle),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
