import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/models/offer_model.dart';

import '../models/offers_model.dart';
import '../providers/offers_provider.dart';
import '../widgets/offer_carasoul_widget.dart';
import '../widgets/offer_section_widget.dart';

Offer _toOffer(OffersModel m) => Offer(
      id: m.id,
      name: m.offerTitle ?? '—',
      image: (m.offerImage?.isNotEmpty ?? false) ? m.offerImage! : 'assets/banner1.jpg',
      discount: '${m.discountPercentage ?? '0'}%',
      price: m.discountedPrice ?? '0',
      oldPrice: m.originalPrice ?? '0',
      rating: 4.8,
      reviews: 12,
      location: 'العراق',
      doctorName: m.serviceProviderType ?? '—',
      description: m.offerDescription,
      offerType: m.offerType,
      periodOfTime: m.periodOfTime,
      startDateFormatted: m.startDate?.split('T').first,
      endDateFormatted: m.endDate?.split('T').first,
    );

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  bool _loading = false;
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  late TabController _tabs;

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
    _tabs = TabController(length: 6, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
            : Consumer<OffersRetroDisplayGetProvider>(
                builder: (_, prov, __) {
                  final dtos = prov.offers
                    ..sort((a, b) => (DateTime.tryParse(b.createDate ?? '') ?? DateTime(1970))
                        .compareTo(DateTime.tryParse(a.createDate ?? '') ?? DateTime(1970)));
                  final all = dtos.map(_toOffer).toList();

                  List<Offer> filter(List<Offer> src) {
                    final q = _searchCtrl.text.trim().toLowerCase();
                    if (q.isEmpty) return src;
                    return src
                        .where((o) => o.name.toLowerCase().contains(q) || (o.offerType ?? '').toLowerCase().contains(q))
                        .toList();
                  }

                  Widget allTab() {
                    final filtered = filter(all);
                    final carousel = filtered.take(5).toList();
                    final fifty = filtered.where(_isFifty).toList();
                    final doctors = filtered.where(_isDoctor).toList();
                    final beauty = filtered.where(_isBeauty).toList();
                    final others = filtered.where((o) => !_isFifty(o) && !_isDoctor(o) && !_isBeauty(o)).toList();

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        if (carousel.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          OfferCarouselWidget(offers: carousel),
                        ],
                        OfferSection(title: 'خصومات مميزة 50%', offers: fifty),
                        OfferSection(title: 'عروض الأطباء', offers: doctors),
                        OfferSection(title: 'تجميل وليزر', offers: beauty),
                        if (others.isNotEmpty)
                          OfferSection(
                            title: 'عروض أخرى',
                            offers: others,
                            scrollDirection: Axis.vertical,
                          ),
                      ],
                    );
                  }

                  Widget bucketTab(List<Offer> bucket) {
                    final filtered = filter(bucket);
                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        OfferSection(
                          title: '',
                          offers: filtered,
                          scrollDirection: Axis.vertical,
                          maxToShow: 99,
                        ),
                      ],
                    );
                  }

                  return NestedScrollView(
                    headerSliverBuilder: (c, i) => [
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: 180,
                        backgroundColor: RacheetaColors.primary,
                        centerTitle: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset('assets/images/offer_header.png', fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: _showSearch
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: _searchCtrl,
                                    autofocus: true,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                    decoration: const InputDecoration(
                                      hintText: 'ابحث عن عرض...',
                                      hintStyle: TextStyle(color: Colors.white70),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                )
                              : const Text(
                                  'عروض راجيتة',
                                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(_showSearch ? Icons.close : Icons.search, color: Colors.white),
                            onPressed: () => setState(() {
                              _showSearch = !_showSearch;
                              if (!_showSearch) _searchCtrl.clear();
                            }),
                          ),
                        ],
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(48),
                          child: Container(
                            color: Colors.white,
                            child: TabBar(
                              controller: _tabs,
                              isScrollable: true,
                              indicatorColor: RacheetaColors.primary,
                              indicatorWeight: 3,
                              labelColor: RacheetaColors.primary,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              unselectedLabelColor: RacheetaColors.textSecondary,
                              tabs: const [
                                Tab(text: 'الكل'),
                                Tab(text: '50%'),
                                Tab(text: 'أطباء'),
                                Tab(text: 'مستشفيات'),
                                Tab(text: 'تجميل'),
                                Tab(text: 'مراكز'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      controller: _tabs,
                      children: [
                        allTab(),
                        bucketTab(all.where(_isFifty).toList()),
                        bucketTab(all.where(_isDoctor).toList()),
                        bucketTab(all.where(_isHospital).toList()),
                        bucketTab(all.where(_isBeauty).toList()),
                        bucketTab(all.where(_isCenter).toList()),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
