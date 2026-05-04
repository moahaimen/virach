// 🔹 specialty_doctors_screen.dart
// استبدِل كل محتوى الملف بهذا

import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:racheeta/core/config/app_config.dart';
import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../../common_screens/search_filters_pages/doctors/screens/filter_page.dart';
import '../../common_screens/search_filters_pages/doctors/widgets/filter_sort_buttons.dart';
import '../../common_screens/search_filters_pages/doctors/widgets/doctor_card.dart';
import '../../common_screens/search_filters_pages/doctors/screens/doctor_map_screen.dart';
import '../../doctors/screens/dr_profile_reservation_screen.dart';
import '../../doctors/models/doctors_model.dart';

class SpecialtyDoctorsPage extends StatefulWidget {
  final String specialty;
  final bool? isInternational;
  const SpecialtyDoctorsPage({
    super.key,
    required this.specialty,
    this.isInternational,
  });

  @override
  State<SpecialtyDoctorsPage> createState() => _SpecialtyDoctorsPageState();
}

class _SpecialtyDoctorsPageState extends State<SpecialtyDoctorsPage> {
/*──────────── متغيّرات البحث/الفلترة/الفرز ────────────*/
  final TextEditingController _search = TextEditingController();

  List<DoctorModel> _allDoctors     = [];   // القائمة الأصلية من الـ API
  List<DoctorModel> _visibleDoctors = [];   // الناتج بعد الفلاتر

  Map<String, dynamic> _filters = {
    /* الجنس */
    'sex_male'          : false,
    'sex_female'        : false,

    /* الدرجة العلمية */
    'degree_consultant' : false,
    'degree_specialist' : false,

    /* السعر */
    'price_min'         : null,   // double؟
    'price_max'         : null,

    /* العنوان */
    'address_kw'        : '',

    /* خيارات إضافية */
    'rating_min'        : 0.0,
    'voice_call'        : false,
    'video_call'        : false,
  };

  String _sortCriterion = 'none';
  bool   _loading       = true;
/*────────────────────────────────────────────────────────*/

/* 🔹 توليد تقييم عشوائى بين 3.0 → 4.25 */
  double _randRating() =>
      double.parse((Random().nextDouble() * 1.25 + 3.0).toStringAsFixed(1));

  String _normalizeSpecialty(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  List<String> _specialtyAliases(String specialty) {
    final normalized = _normalizeSpecialty(specialty);
    const aliasMap = <String, List<String>>{
      'اشعة وسونار': ['اشعة وسونار', 'اشعات و رنين', 'اشعة', 'سونار', 'رنين', 'مفراس'],
      'اشعات و رنين': ['اشعة وسونار', 'اشعات و رنين', 'اشعة', 'سونار', 'رنين', 'مفراس'],
      'طب نفسي': ['طب نفسي', 'نفسية'],
      'نفسية': ['طب نفسي', 'نفسية'],
      'اورام': ['اورام', 'أورام'],
      'امراض دم': ['امراض دم', 'أمراض الدم'],
      'امراض الدم': ['امراض دم', 'أمراض الدم'],
      'علاج طبيعي': ['علاج طبيعي', 'العلاج الطبيعي'],
      'النسائية والتوليد': ['النسائية والتوليد', 'نسائية'],
    };

    return aliasMap[normalized] ?? [specialty];
  }

  bool _matchesSpecialty(DoctorModel doctor, List<String> aliases) {
    final doctorSpecialty = _normalizeSpecialty(doctor.specialty ?? '');
    return aliases.any((alias) {
      final normalizedAlias = _normalizeSpecialty(alias);
      return doctorSpecialty == normalizedAlias ||
          doctorSpecialty.contains(normalizedAlias) ||
          normalizedAlias.contains(doctorSpecialty);
    });
  }

  String get _pageTitle {
    if (widget.isInternational == true) return 'طبيب دولي';
    if (widget.specialty == 'xsonarrays') return 'أشعة وسونار';
    return widget.specialty;
  }

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

/*──────────── جلب الأطباء ────────────*/
/*────────────────── جلب الأطباء من الـ API ──────────────────*/
  Future<void> _fetchDoctors() async {
    setState(() => _loading = true);

    try {
      List<DoctorModel> docs;

      // ➊ مصفاة التخصصات المحلّية (سونار، رنين…)
      if (widget.specialty == 'xsonarrays') {
        docs = await _fetchDoctorRows();
        docs = docs.where((d) {
          final s = (d.specialty ?? '').toLowerCase();
          return ['اشعة', 'سونار', 'رنين', 'مفراس'].any((kw) => s.contains(kw));
        }).toList();
      }
      // ➋ أطباء دوليون
      else if (widget.isInternational == true) {
        docs = (await _fetchDoctorRows())
            .where((doc) => doc.isInternational == true)
            .toList();
      }
      // ➌ التخصص العادى
      else {
        docs = await _fetchDoctorRows(specialty: widget.specialty);
        if (docs.isEmpty) {
          final aliases = _specialtyAliases(widget.specialty);
          final allDoctors = await _fetchDoctorRows();
          docs = allDoctors
              .where((doctor) => _matchesSpecialty(doctor, aliases))
              .toList();
        }
      }

      /* ▸ توليد تقييم ومراجعات افتراضيّة إذا لم يأتِ شىء من الـ API */
      for (final d in docs) {
        // إذا كان المتوسط غير موجود أو ≤ 0، نفعلّله قيمة عشوائية بين 3.0 و 4.25
        if (d.reviewsAvg == null || (d.reviewsAvg ?? 0) <= 0) {
          d.reviewsAvg = _randRating();
        }
        // إذا كان عدد المراجعات غير موجود أو ≤ 0، نعطيه رقم عشوائي بين 50 و 200
        if (d.reviewsCount == null || (d.reviewsCount ?? 0) <= 0) {
          d.reviewsCount = Random().nextInt(151) + 50;
        }
      }

      /* ▸ الإعلانات فى الأعلى */
      docs.sort((a, b) =>
          (b.advertise == true ? 1 : 0).compareTo(a.advertise == true ? 1 : 0));

      _allDoctors = docs;
      _refreshVisible();        // يُحدّث الفلترة والفرز ثم setState()
    } catch (e) {
      debugPrint('❌ fetch error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<DoctorModel>> _fetchDoctorRows({String? specialty}) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('access_token') ??
        prefs.getString('Login_access_token') ??
        '';

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: token.isEmpty
            ? null
            : {'Authorization': '${AppConfig.authorizationPrefix} $token'},
      ),
    );

    final response = await dio.get<List<dynamic>>(
      'doctor/',
      queryParameters: specialty == null ? null : {'specialty': specialty},
    );
    final rows = response.data ?? const [];
    debugPrint(
      '🩺 [SpecialtyDoctorsPage] specialty=${specialty ?? 'all'} rows=${rows.length}',
    );

    return rows
        .map((row) => DoctorModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

/*──────────── شروط البحث والفلترة ────────────*/
  bool _passesSearch(DoctorModel d) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return (d.user?.fullName ?? '').toLowerCase().contains(q) ||
        (d.specialty ?? '').toLowerCase().contains(q);
  }

  bool _passesFilters(DoctorModel d) {
    /* الجنس */
    if (_filters['sex_male']   == true && d.user?.gender != 'm') return false;
    if (_filters['sex_female'] == true && d.user?.gender != 'f') return false;

    /* الدرجة العلمية (إن كانت متوفرة فى الـ API) */
    final degree = (d.degrees ?? '').toLowerCase();
    if (_filters['degree_consultant'] == true && !degree.contains('استشاري')) return false;
    if (_filters['degree_specialist'] == true && !degree.contains('اخصائي'))  return false;

    /* السعر */
    final p = d.price ?? 0;
    if (_filters['price_min'] != null && p < _filters['price_min']) return false;
    if (_filters['price_max'] != null && p > _filters['price_max']) return false;

    /* العنوان */
    final addrKw = (_filters['address_kw'] as String).toLowerCase();
    if (addrKw.isNotEmpty &&
        !(d.address ?? '').toLowerCase().contains(addrKw)) {
      return false;
    }

    /* أقل تقييم */
    if ((d.reviewsAvg ?? 0) < (_filters['rating_min'] ?? 0.0)) return false;

    /* مكالمة صوتية/فيديو */
    if (_filters['voice_call'] == true && d.voiceCall != true) return false;
    if (_filters['video_call'] == true && d.videoCall != true) return false;

    return true;
  }

/*──────────── الفرز ────────────*/
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

/*──────────── تجميع التغييرات ────────────*/
  void _refreshVisible() {
    _visibleDoctors = _allDoctors
        .where(_passesSearch)
        .where(_passesFilters)
        .toList();
    _sort(_visibleDoctors);
    setState(() => _loading = false);
  }

/*──────────── التفاعل مع صفحة الفلاتر ────────────*/
  void _onApplyFilters(Map<String, dynamic> f) {
    _filters = f;
    _refreshVisible();
  }

/*──────────── اختيار الفرز ────────────*/
  void _sortDoctors(String c) {
    _sortCriterion = c;
    _refreshVisible();
  }

/*──────────── واجهة المستخدم ────────────*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(_pageTitle),
        leading: const BackButton(),
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

          /* أزرار فلتر/فرز/خريطة */
          FilterSortButtons(
            onFilter: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FilterPage(
                    currentFilters: _filters,
                    onApplyFilters: _onApplyFilters,
                  ),
                ),
              );
            },
            onSort: _showSortOptions,
            onMap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DoctorMapScreen()),
            ),
          ),

          /* القائمة */
          Expanded(
            child: _visibleDoctors.isEmpty
                ? const Center(child: Text('لا يوجد أطباء متاحون'))
                : ListView.builder(
              itemCount: _visibleDoctors.length,
              itemBuilder: (_, i) {
                final d = _visibleDoctors[i];
                return DoctorCard(
                  doctor: d,
                  onTap: () async {
                    final prefs =
                    await SharedPreferences.getInstance();
                    if (!context.mounted) return;
                    if (!prefs.containsKey('user_id')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                            Text('يرجى تسجيل الدخول أولاً')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DrProfileReservationPage(
                          doctor: d,
                          userData: const {}, // لو احتجتها
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: const MainBottomNavBar(currentIndex: 0),
    );
  }

/*──────────── Bottom-Sheet للفرز ────────────*/
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('الأعلى تقييمًا ⭐'),
            onTap: () {
              Navigator.pop(context);
              _sortDoctors('highest_rating');
            },
          ),
          ListTile(
            title: const Text('الأغلى سعرًا 💰'),
            onTap: () {
              Navigator.pop(context);
              _sortDoctors('highest_price');
            },
          ),
          ListTile(
            title: const Text('الأقل سعرًا 💸'),
            onTap: () {
              Navigator.pop(context);
              _sortDoctors('lowest_price');
            },
          ),
          ListTile(
            title: const Text('الاسم من أ → ي'),
            onTap: () {
              Navigator.pop(context);
              _sortDoctors('name_az');
            },
          ),
          ListTile(
            title: const Text('الاسم من ي → أ'),
            onTap: () {
              Navigator.pop(context);
              _sortDoctors('name_za');
            },
          ),
        ],
      ),
    );
  }
}
