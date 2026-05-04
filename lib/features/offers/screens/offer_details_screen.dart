import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/models/offer_model.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'package:provider/provider.dart';
import '../services/coupon_services.dart';
import '../widgets/coupon_sheet_widget.dart';

class OfferDetailsScreen extends StatelessWidget {
  final Offer offer;
  const OfferDetailsScreen({super.key, required this.offer});

  ImageProvider _img(String path) =>
      (path.startsWith('http') || path.startsWith('https'))
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;

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

  int? _daysLeft(String? isoEnd) {
    if (isoEnd == null) return null;
    final end = DateTime.tryParse(isoEnd);
    if (end == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = end.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysLeft(offer.endDateFormatted);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: RacheetaColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: _img(offer.image),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: RacheetaColors.mintLight),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black26,
                            Colors.transparent,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Card
                    RacheetaCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RacheetaStatusChip(
                                label: offer.discount,
                                color: RacheetaColors.danger,
                              ),
                              if (daysLeft != null)
                                Text(
                                  daysLeft == 0 ? 'انتهى العرض' : 'باقي $daysLeft يوم',
                                  style: TextStyle(
                                    color: daysLeft == 0 ? RacheetaColors.danger : RacheetaColors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            offer.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: RacheetaColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.storefront_outlined, size: 18, color: RacheetaColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                _providerAr(offer.doctorName),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text('${offer.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Card
                    RacheetaCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('سعر العرض', style: TextStyle(color: RacheetaColors.textSecondary, fontSize: 12)),
                              Text(
                                '${offer.price} د.ع',
                                style: const TextStyle(
                                  color: RacheetaColors.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          if (offer.oldPrice.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('السعر الأصلي', style: TextStyle(color: RacheetaColors.textSecondary, fontSize: 12)),
                                Text(
                                  '${offer.oldPrice} د.ع',
                                  style: const TextStyle(
                                    color: RacheetaColors.textSecondary,
                                    fontSize: 18,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Card
                    if (offer.description?.isNotEmpty ?? false) ...[
                      RacheetaCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('تفاصيل العرض', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 12),
                            Text(
                              offer.description!,
                              style: const TextStyle(fontSize: 15, height: 1.6, color: RacheetaColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Info Card
                    RacheetaCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.category_outlined, 'نوع العرض', offer.offerType ?? '—'),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.schedule_outlined, 'مدة العرض', offer.periodOfTime ?? '—'),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.calendar_today_outlined, 'صلاحية العرض',
                              'من ${offer.startDateFormatted ?? "—"} إلى ${offer.endDateFormatted ?? "—"}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final userName = prefs.getString('full_name') ?? 'غير محدد';
              if (!context.mounted) return;
              final coupon = await context.read<CouponService>().create(offer: offer, userName: userName);

              if (!context.mounted) return;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                builder: (_) => CouponSheet(offer: offer, coupon: coupon),
              );
            },
            child: const Text('احصل على العرض الآن'),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: RacheetaColors.mintLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: RacheetaColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: RacheetaColors.textSecondary, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
