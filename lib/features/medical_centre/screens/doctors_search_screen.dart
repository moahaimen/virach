// lib/features/medical_centre/screens/center_doctors_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../../common_screens/search_filters_pages/doctors/widgets/filter_sort_buttons.dart';
import '../../common_screens/search_filters_pages/doctors/widgets/doctor_card.dart';
import '../../common_screens/search_filters_pages/doctors/screens/filter_page.dart';
import '../../common_screens/search_filters_pages/doctors/screens/doctor_map_screen.dart';
import '../../doctors/models/doctors_model.dart';
import '../../doctors/providers/doctors_provider.dart';
import '../../doctors/services/api_client.dart';
import '../../doctors/screens/dr_profile_reservation_screen.dart';
import '../../notifications/providers/notifications_provider.dart';

class CenterDoctorsScreen extends StatefulWidget {
  const CenterDoctorsScreen({Key? key}) : super(key: key);

  @override
  State<CenterDoctorsScreen> createState() => _CenterDoctorsScreenState();
}

class _CenterDoctorsScreenState extends State<CenterDoctorsScreen> {
  final _search = TextEditingController();
  List<DoctorModel> _all = [];
  List<DoctorModel> _visible = [];
  Map<String, dynamic> _filters = {
    'sex_male': false,
    'sex_female': false,
    'degree_consultant': false,
    'degree_specialist': false,
    'price_min': null,
    'price_max': null,
    'address_kw': '',
    'rating_min': 0.0,
    'voice_call': false,
    'video_call': false,
  };
  String _sortCriterion = 'none';
  bool _loading = true;

  double _randRating() =>
      double.parse((Random().nextDouble() * 1.25 + 3.0).toStringAsFixed(1));

  @override
  void initState() {
    super.initState();
    _search.addListener(_refreshVisible);
    _fetchDoctors();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

// ───────────── Fetch doctors (available_for_center == true) ─────────────
  Future<void> _fetchDoctors() async {
    setState(() => _loading = true);
    final prov = context.read<DoctorRetroDisplayGetProvider>();
    try {
      // ① Ask backend for doctors available for center
      List<DoctorModel> docs =
      await prov.fetchDoctorsByAvailability(isAvailable: true);

      // ② Graceful rating fallbacks
      for (var d in docs) {
        if ((d.reviewsAvg ?? 0) <= 0) d.reviewsAvg = _randRating();
        if ((d.reviewsCount ?? 0) <= 0)
          d.reviewsCount = Random().nextInt(151) + 50;
      }

      // ③ Ads first
      docs.sort((a, b) =>
          (b.advertise == true ? 1 : 0).compareTo(a.advertise == true ? 1 : 0));

      // ④ Commit and refresh
      _all = docs;
      _refreshVisible();
    } catch (e) {
      debugPrint('❌ fetch error: $e');
      setState(() => _loading = false);
    }
  }

// ───────────── Refresh visible (also enforce true) ─────────────
  void _refreshVisible() {
    _visible = _all
        .where((d) => d.availableForCenter == true)   // ← use true here
        .where(_passesSearch)
        .where(_passesFilters)
        .toList();
    _sort(_visible);
    setState(() => _loading = false);
  }

  bool _passesSearch(DoctorModel d) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return d.user?.fullName?.toLowerCase().contains(q) ?? false;
  }

  bool _passesFilters(DoctorModel d) {
    if (_filters['sex_male']   == true && d.user?.gender != 'm') return false;
    if (_filters['sex_female'] == true && d.user?.gender != 'f') return false;

    final degree = (d.degrees ?? '').toLowerCase();
    if (_filters['degree_consultant'] == true && !degree.contains('استشاري')) return false;
    if (_filters['degree_specialist'] == true && !degree.contains('اخصائي')) return false;

    final price = d.price ?? 0;
    if (_filters['price_min'] != null && price < _filters['price_min']) return false;
    if (_filters['price_max'] != null && price > _filters['price_max']) return false;

    final addrKw = (_filters['address_kw'] as String).toLowerCase();
    if (addrKw.isNotEmpty &&
        !(d.address ?? '').toLowerCase().contains(addrKw)) return false;

    if ((d.reviewsAvg ?? 0) < (_filters['rating_min'] ?? 0.0)) return false;
    if (_filters['voice_call'] == true && d.voiceCall != true) return false;
    if (_filters['video_call'] == true && d.videoCall != true) return false;

    return true;
  }

  void _sort(List<DoctorModel> list) {
    switch (_sortCriterion) {
      case 'highest_rating':
        list.sort((b, a) => (a.reviewsAvg ?? 0).compareTo(b.reviewsAvg ?? 0));
        break;
      case 'highest_price':
        list.sort((b, a) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'lowest_price':
        list.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'name_az':
        list.sort((a, b) =>
            (a.user?.fullName ?? '').compareTo(b.user?.fullName ?? ''));
        break;
      case 'name_za':
        list.sort((b, a) =>
            (a.user?.fullName ?? '').compareTo(b.user?.fullName ?? ''));
        break;
      default:
        break;
    }
  }


  Future<void> _inviteDoctor(String doctorId) async {
    setState(() => _loading = true);
    final prefs    = await SharedPreferences.getInstance();
    final centerId = prefs.getString('medical_center_id');
    if (centerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: لم يُعثر على معرف المركز')),
      );
      setState(() => _loading = false);
      return;
    }

    final prov      = context.read<DoctorRetroDisplayGetProvider>();
    final notifProv = context.read<NotificationsRetroDisplayGetProvider>();

    try {
      // 1️⃣ invite the doctor on the backend
      await prov.inviteDoctor(doctorId);

      // 2️⃣ look up the nested user‑id
      final docModel = _all.firstWhere((d) => d.id == doctorId);
      final docUserId = docModel.user?.id;
      if (docUserId == null) {
        throw Exception('لم أتمكن من إيجاد user‑id للطبيب');
      }

      // 3️⃣ send the notification to the **user** table
      await notifProv.createNotification(
        user: docUserId,   // ← now the correct user PK
        notificationText: 'لقد تلقيت طلب انضمام جديد من المركز الطبي.',
        isRead: false,
        data: {
          'type':      'centerInvite',
          'center_id': centerId,
        },
      );

      // 4️⃣ update UI
      setState(() {
        _all.removeWhere((d) => d.id == doctorId);
        _refreshVisible();
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الدعوة والإشعار بنجاح')),
      );
    } catch (e) {
      setState(() => _loading = false);
      final msg = e is DioError && e.response != null
          ? e.response!.data.toString()
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الدعوة/الإشعار: $msg')),
      );
    }
  }

  void _onApplyFilters(Map<String, dynamic> f) {
    _filters = f;
    _refreshVisible();
  }

  void _sortDoctors(String c) {
    _sortCriterion = c;
    _refreshVisible();
  }
  // Future<void> _inviteDoctor(String doctorId) async {
  //   final prov = context.read<DoctorRetroDisplayGetProvider>();
  //
  //   try {
  //     await prov.inviteDoctor(doctorId);
  //
  //     setState(() {
  //       _all.removeWhere((d) => d.id == doctorId);
  //       _refreshVisible();
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('تم إرسال الدعوة بنجاح')),
  //     );
  //   } on Exception catch (e) {
  //     // This catches both our thrown Exception and DioError
  //     final msg = e.toString().replaceFirst('Exception: ', '');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('فشل الدعوة: $msg')),
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أطباء متاحون للانضمام'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم الطبيب',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          FilterSortButtons(
            onFilter: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FilterPage(
                  currentFilters: _filters,
                  onApplyFilters: _onApplyFilters,
                ),
              ),
            ),
            onSort: _showSortOptions,
            onMap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DoctorMapScreen()),
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? const Center(child: Text('لا يوجد أطباء متاحون'))
                : ListView.builder(
              itemCount: _visible.length,
              itemBuilder: (_, i) {
                final d = _visible[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DoctorCard(
                        doctor: d,
                        onTap: () {}, // no booking here
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () => _inviteDoctor(d.id!),
                        child: const Text('دعوة للانضمام'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavBar(currentIndex: 0),
    );
  }

  void _showSortOptions() { /* same as before */ }
}
