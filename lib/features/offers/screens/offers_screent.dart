// lib/features/offers/screens/offers_screen.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constansts/constants.dart';
import '../../../models/offer_model.dart';
import '../models/offers_model.dart';
import '../providers/offers_provider.dart';
import '../widgets/offer_carasoul_widget.dart';
import '../widgets/offer_section_widget.dart';
import '../widgets/offeritem_widget.dart';
import 'offer_details_screen.dart';

/* ───────── DTO ⮕ UI ───────── */
Offer _toOffer(OffersModel m) => Offer(
  id: m.id,
  name: m.offerTitle ?? '—',
  image: (m.offerImage?.isNotEmpty ?? false)
      ? m.offerImage!
      : 'assets/banner1.jpg',
  discount: '${m.discountPercentage ?? '0'}%',
  price: m.discountedPrice ?? '0',
  oldPrice: m.originalPrice ?? '0',
  rating: 4.5,
  reviews: 0,
  location: '—',
  doctorName: m.serviceProviderType ?? '—',
  description: m.offerDescription,
  offerType: m.offerType,
  periodOfTime: m.periodOfTime,
  startDateFormatted: m.startDate?.split('T').first,
  endDateFormatted: m.endDate?.split('T').first,
);

/* ───────── Screen ───────── */
class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  late TabController _tabs;

  /* buckets helpers */
  bool _isFifty(Offer o) => o.discount.startsWith('50');
  bool _isDoctor(Offer o) {
    final t = (o.offerType ?? '').toLowerCase();
    final p = o.doctorName.toLowerCase();
    return t.contains('طبيب') || t.contains('doctor') || p.contains('doctor');
  }

  bool _isHospital(Offer o) => (o.offerType ?? '').contains('مستشف');
  bool _isBeauty(Offer o) => (o.offerType ?? '').contains('تجميل');
  bool _isCenter(Offer o) => (o.offerType ?? '').contains('مركز');

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this); // الكل + 5 buckets
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _loading = true);
      await context.read<OffersRetroDisplayGetProvider>().getOffers();
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /* ------------------------------------------------------------------ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<OffersRetroDisplayGetProvider>(
        builder: (_, prov, __) {
          /* --- prep data once --- */
          final dtos = prov.offers
            ..sort((a, b) =>
                (DateTime.tryParse(b.createDate ?? '') ?? DateTime(1970))
                    .compareTo(DateTime.tryParse(a.createDate ?? '') ??
                    DateTime(1970)));
          final all = dtos.map(_toOffer).toList();

          /* buckets */
          final fifty = all.where(_isFifty).toList();
          final doctors = all.where(_isDoctor).toList();
          final hospitals = all.where(_isHospital).toList();
          final beauty = all.where(_isBeauty).toList();
          final centers = all.where(_isCenter).toList();
          /* search filter */
          List<Offer> _filter(List<Offer> src) {
            final q = _searchCtrl.text.trim().toLowerCase();
            if (q.isEmpty) return src;
            return src
                .where((o) =>
            o.name.toLowerCase().contains(q) ||
                (o.offerType ?? '').toLowerCase().contains(q))
                .toList();
          }

          /* “الكل” tab – full classic layout */
          /// ---- “الكل” tab ----------------------------------------------------------
          /// show classic layout **after** applying the current search query
          Widget _allTab() {
            // 1) apply search to the whole list first
            final filtered = _filter(all);          // <-- all = every offer

            // 2) rebuild the same derived slices from that filtered list
            final carousel       = filtered.take(5).toList();
            final mostViewed     = filtered.skip(5).take(5).toList();
            final mostRequested  = filtered.skip(10).take(5).toList();

            // 3) build buckets also from the filtered list
            final fifty     = filtered.where(_isFifty).toList();
            final doctors   = filtered.where(_isDoctor).toList();
            final hospitals = filtered.where(_isHospital).toList();
            final beauty    = filtered.where(_isBeauty).toList();
            final centers   = filtered.where(_isCenter).toList();

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                /* ---- carousel ---- */
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: OfferCarouselWidget(offers: carousel),
                ),
                /* ---- horizontal ribbons ---- */
                OfferSection(title: 'خصومات %50',     offers: fifty),
                OfferSection(title: 'خصومات الأطباء', offers: doctors),
                OfferSection(title: 'المستشفيات',     offers: hospitals),
                OfferSection(title: 'مراكز التجميل',  offers: beauty),
                OfferSection(title: 'مراكز طبية',     offers: centers),

                /* ---- bottom lists ---- */
                OfferSection(title: 'الأكثر مشاهدة', offers: mostViewed),
                OfferSection(
                  title: 'الأكثر طلباً',
                  offers: mostRequested,
                  scrollDirection: Axis.vertical,
                ),
              ],
            );
          }

          /* other tabs – vertical list only */
          Widget _bucketTab(List<Offer> bucket) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                OfferSection(
                  title: '',                    // لا عنوان
                  offers: bucket,               // كل عروض الفئة
                  scrollDirection: Axis.vertical,
                ),
              ],
            );
          }


          /* ------------------------------------------------------------------ */
          return NestedScrollView(
            headerSliverBuilder: (c, i) => [
            SliverAppBar(
            pinned: true,
            elevation: 0,
            toolbarHeight: MediaQuery.sizeOf(context).height * .08,
            backgroundColor: Colors.transparent,

            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/offer_header.png', fit: BoxFit.cover),
                Container(color: Colors.black.withOpacity(.25)),

                /* شريط الأدوات */
                Positioned(
                  top: MediaQuery.of(context).padding.top + 6,
                  left: 0,
                  right: 0,
                  child: Directionality(
                    textDirection: TextDirection.ltr,   // إجبار LTR ليبقى زرّ البحث يميناً
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /* زرّ البحث / الإغلاق */
                        IconButton(
                          icon: Icon(
                            _showSearch ? Icons.close : Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () => setState(() {
                            _showSearch = !_showSearch;
                            if (!_showSearch) _searchCtrl.clear();
                          }),
                        ),

                        /* العنوان أو حقل البحث بعرض وارتفاع مضبوطان */
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * .60 > 300
                                ? 300
                                : MediaQuery.of(context).size.width * .60,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (w, a) =>
                                FadeTransition(opacity: a, child: w),
                            child: _showSearch
                                ? SizedBox(
                              height: 40,            // ارتفاع مُصغَّر للحقل
                              child: TextField(
                                key: const ValueKey('searchField'),
                                controller: _searchCtrl,
                                autofocus: true,
                                maxLines: 1,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.right,
                                decoration: const InputDecoration(
                                  isDense: true,                     // يقلّل الفراغات
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 10), // تحكّم بالهوامش
                                  hintText: 'ابحث هنا…',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white24,        // خلفية خفيفة
                                ),
                                onChanged: (_) => setState(() {}),  // فلترة فوريّة
                              ),
                            )
                                : const Text(
                              'تطبيق راجيتة – قسم العروض',
                              key: ValueKey('titleText'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 28), // مساحة تعويضية للزر الأيسر المحذوف
                      ],
                    ),
                  ),
                ),
              ],
            ),


          /* تبويبات الأقسام */
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabs,
                      isScrollable: true,
                      indicatorColor: const Color(0xFF007BFF),
                      labelColor: const Color(0xFF007BFF),
                      unselectedLabelColor: Colors.grey.shade600,
                      tabs: const [
                        Tab(text: 'الكل'),
                        Tab(text: '%50'),
                        Tab(text: 'الأطباء'),
                        Tab(text: 'المستشفيات'),
                        Tab(text: 'التجميل'),
                        Tab(text: 'المراكز الطبية'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _allTab(),
                _bucketTab(fifty),
                _bucketTab(doctors),
                _bucketTab(hospitals),
                _bucketTab(beauty),
                _bucketTab(centers),
              ],
            ),
          );
        },
      ),
    );
  }
}
