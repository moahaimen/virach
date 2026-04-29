// ---------------------------------------------
// lib/features/offers/widgets/offer_section_widget.dart
// ---------------------------------------------
import 'package:flutter/material.dart';
import '../../../constansts/constants.dart';
import '../../../models/offer_model.dart';
import '../../../widgets/offers/offerlistitem.dart';
import 'offeritem_widget.dart';
import '../screens/offer_details_screen.dart';

class OfferSection extends StatelessWidget {
  const OfferSection({
    super.key,
    required this.title,
    required this.offers,
    this.scrollDirection = Axis.horizontal,
    int maxToShow = 3,
  }) : _maxToShow = maxToShow;

  final String title;
  final List<Offer> offers;
  final Axis scrollDirection;
  final int _maxToShow; // عدد العناصر الظاهرة فى الصفحة الرئيسية

  //--------------------------------------------------------------------------------
  // كارت “عرض المزيد”
  //--------------------------------------------------------------------------------
  Widget _seeMoreCard(BuildContext ctx, bool isHorizontal, double h) => GestureDetector(
    onTap: () => Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => AllOffersScreen(title: title, offers: offers),
      ),
    ),
    child: Container(
      width: isHorizontal ? h * .8 : double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_back, color: Colors.blue, size: 18),
            const SizedBox(width: 6),
            Text(
              'عرض المزيد (${offers.length - _maxToShow})',
              style: kDoctorCardsblueTextStyle,
            ),
          ],
        ),
      ),
    ),
  );

  //--------------------------------------------------------------------------------
  // عنصر العرض (يحمِل onTap إلى التفاصيل)
  //--------------------------------------------------------------------------------
  Widget _item(BuildContext ctx, Offer o, {required bool isHorizontal}) =>
      isHorizontal
          ? OfferItem(
        offer: o,
        textStyle: kDoctorCardsblueTextStyle,
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: o)),
        ),
      )
          : OfferListItem(
        offer: o,
        textStyle: kDoctorCardsblueTextStyle,
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: o)),
        ),
      );

  //--------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final isH = scrollDirection == Axis.horizontal;
    final hasMore = offers.length > _maxToShow;
    final visible = offers.take(_maxToShow).toList();
    final sectionH = MediaQuery.of(context).size.height * .28;

    //-------------- الـ ListView ---------------//
    Widget list = ListView.builder(
      scrollDirection: scrollDirection,
      physics: isH ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      shrinkWrap: !isH,
      itemCount: visible.length + (hasMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        // آخر عنصر = كارت المزيد
        if (hasMore && i == visible.length) {
          return _seeMoreCard(ctx, isH, sectionH);
        }
        return _item(ctx, visible[i], isHorizontal: isH);
      },
    );

    if (isH) list = SizedBox(height: sectionH, child: list);

    //-------------- المخرَج ---------------//
    return Padding(
      padding: kSectionPadding.copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(title, style: kDoctorCardsblueTextStyle.copyWith(fontSize: 18)),
          ),
          list,
          // للأقسام العمودية: زرّ نصى أسفل القائمة (اختياري)
          if (!isH && hasMore)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllOffersScreen(title: title, offers: offers),
                  ),
                ),
                child: const Text('عرض الكل'),
              ),
            ),
        ],
      ),
    );
  }
}

/* ───────── شاشة تعرض كل عروض القسم ───────── */
class AllOffersScreen extends StatelessWidget {
  const AllOffersScreen({super.key, required this.title, required this.offers});

  final String title;
  final List<Offer> offers;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView.builder(
      itemCount: offers.length,
      itemBuilder: (_, i) => OfferListItem(
        offer: offers[i],
        textStyle: kDoctorCardsblueTextStyle,
      ),
    ),
  );
}
