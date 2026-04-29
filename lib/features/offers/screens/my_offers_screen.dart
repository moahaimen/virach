// lib/features/offers/screens/my_offers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_screens/AddOfferForm.dart';
import '../models/offers_model.dart';
import '../providers/offers_provider.dart';
import '../widgets/offer_card.dart';
import '../widgets/edit_offers_widget.dart';

class MyOffersPage extends StatefulWidget {
  const MyOffersPage({
    super.key,
    required this.userType,
    required this.userId,            // service_provider_id
  });

  final String userType;
  final String userId;

  @override
  State<MyOffersPage> createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;                 // حالة التحميل الأولى
  bool _hasFetched = false;             // نتأكّد أن الجلب يتم مرّة واحدة

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);

    /// بعد أول frame نستطيع استخدام context بأمان
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchOffersOnce();
    });
  }

  Future<void> _fetchOffersOnce() async {
    if (_hasFetched) return;
    _hasFetched = true;

    final prov = context.read<OffersRetroDisplayGetProvider>();
    await prov.getOffersForCurrentUser(widget.userId);
    if (mounted) setState(() => _loading = false);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isExpired(OffersModel o) {
    try {
      return o.endDate != null &&
          DateTime.parse(o.endDate!).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Iterable<OffersModel> _current(List<OffersModel> all) =>
      all.where((o) => !(o.isArchived ?? false) && !_isExpired(o));

  Iterable<OffersModel> _old(List<OffersModel> all) =>
      all.where((o) => (o.isArchived ?? false) || _isExpired(o));

  Future<void> _deleteOffer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العرض؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<OffersRetroDisplayGetProvider>().deleteOffer(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحذف بنجاح')),
        );
      }
    }
  }

  void _editOffer(OffersModel offer) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditOfferPage(offer: offer)));

  void _addNewOffer() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => AddOfferForm(userId: widget.userId)));

  Widget _offersList(Iterable<OffersModel> offers, {required bool isOld}) {
    final list = offers.toList();
    if (list.isEmpty) return const Center(child: Text('لا توجد عروض حالياً'));

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final offer = list[i];
        return OfferCard(
          offer: offer,
          onEdit  : isOld ? null : () => _editOffer(offer),
          onDelete: ()     => _deleteOffer(offer.id!),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final offers = context.watch<OffersRetroDisplayGetProvider>().offers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('عروضي'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'الحالية'), Tab(text: 'المنتهية')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _offersList(_current(offers), isOld: false),
          _offersList(_old(offers)    , isOld: true ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewOffer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
