import 'package:flutter/material.dart';
import 'package:racheeta/features/jobposting/screens/alljob_postings_screen.dart';
import 'package:racheeta/theme/app_theme.dart';

import '../feauted_section_widget.dart';
import '../header_widgets/header_section_widget.dart';
import '../offers_item_widget.dart';
import '../service_item_widget.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _HomeHero(),
                  SizedBox(height: 18),
                  _QuickStatsRow(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: HeaderSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(child: FeaturedSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(child: ServiceItem()),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(child: OffersItem()),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          const SliverToBoxAdapter(child: _JobsCtaCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            RacheetaColors.primary,
            RacheetaColors.primaryHover,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: RacheetaColors.primary.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'راجيتة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'سوق الخدمات الصحية العراقي',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'شنو تحتاج اليوم؟',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أطباء، مختبرات، صيدليات، تمريض، عروض صحية ووظائف طبية في مكان واحد.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: RacheetaColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ابحث عن طبيب، خدمة، أو عرض...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RacheetaColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: RacheetaColors.mintLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'قريباً',
                    style: TextStyle(
                      color: RacheetaColors.primaryHover,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      _TrustChipData(Icons.verified_user_outlined, 'مزودون موثوقون'),
      _TrustChipData(Icons.event_available_outlined, 'حجز سريع'),
      _TrustChipData(Icons.local_offer_outlined, 'عروض حصرية'),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                decoration: BoxDecoration(
                  color: RacheetaColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: RacheetaColors.border),
                ),
                child: Column(
                  children: [
                    Icon(item.icon, color: RacheetaColors.primary, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: RacheetaColors.textPrimary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TrustChipData {
  const _TrustChipData(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _JobsCtaCard extends StatelessWidget {
  const _JobsCtaCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RacheetaColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: RacheetaColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.work_outline,
                color: RacheetaColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'وظائف القطاع الصحي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'قدّم على فرص عمل منشورة من مزودي الخدمات الصحية.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: RacheetaColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AllJobPostingsPage()),
                );
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ],
        ),
      ),
    );
  }
}
