import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'package:racheeta/features/labrotary/models/labs_model.dart';
import 'package:racheeta/features/pharmacist/providers/pharma_provider.dart';
import '../common_screens/search_filters_pages/hsp/hsp_card.dart';
import '../beauty_centers/models/beauty_centers_model.dart';
import '../beauty_centers/providers/beauty_centers_provider.dart';
import '../common_screens/search_filters_pages/hsp/screens/filter_page.dart';
import '../common_screens/search_filters_pages/hsp/screens/hsp_map_screen.dart';
import '../common_screens/search_filters_pages/hsp/widgets/filter_sort_buttons.dart';
import '../doctors/models/doctors_model.dart';
import '../doctors/providers/doctors_provider.dart';
import '../hospitals/models/hospitals_model.dart';
import '../hospitals/providers/hospital_display_provider.dart';
import '../labrotary/providers/labs_provider.dart';
import '../medical_centre/models/medical_centers_model.dart';
import '../medical_centre/providers/medical_centers_providers.dart';
import '../nurse/models/nurse_model.dart';
import '../nurse/providers/nurse_provider.dart';
import '../pharmacist/models/pharma_model.dart';
import '../therapist/models/therapist_model.dart';
import '../therapist/providers/therapist_provider.dart';
import 'hsp_profile_reservation_screen.dart';

class HSPSearchScreen extends StatefulWidget {
  final String hspType;
  const HSPSearchScreen({super.key, required this.hspType});

  @override
  State<HSPSearchScreen> createState() => _HSPSearchScreenState();
}

class _HSPSearchScreenState extends State<HSPSearchScreen> {
  List<dynamic> allHSPs = [];
  List<Map<String, dynamic>> filteredHSPs = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _currentSortCriterion = 'none';
  Map<String, dynamic> _currentFilters = {
    'sex_male': false,
    'sex_female': false,
    'degree_consultant': false,
    'degree_specialist': false,
    'price_min': null,
    'price_max': null,
    'address_kw': '',
    'min_rating': 0.0,
    'available_morning': false,
    'available_evening': false,
    'home_visit': false,
    'sentinel_only': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchHSPs();
    _searchController.addListener(_filterHSPs);
  }

  double _randRating() => (Random().nextDouble() * 1.25 + 3.7).clamp(0.0, 5.0);
  int _randReviews() => Random().nextInt(151) + 50;

  Future<void> _fetchHSPs() async {
    setState(() => isLoading = true);
    try {
      final type = widget.hspType;
      if (type == 'Hospital') {
        final p = context.read<HospitalRetroDisplayGetProvider>();
        await p.fetchHospitals();
        allHSPs = p.hospitals;
      } else if (type == 'BeautyCenter') {
        final p = context.read<BeautyCentersRetroDisplayGetProvider>();
        await p.fetchBeautyCenters();
        allHSPs = p.beautyCenters;
      } else if (type == 'Pharmacy') {
        final p = context.read<PharmaRetroDisplayGetProvider>();
        await p.fetchPharmacies();
        allHSPs = p.pharmacies;
      } else if (type == 'Therapist') {
        final p = context.read<TherapistRetroDisplayGetProvider>();
        await p.fetchTherapists();
        allHSPs = p.therapists;
      } else if (type == 'MedicalCenter') {
        final p = context.read<MedicalCentersRetroDisplayGetProvider>();
        await p.fetchMedicalCenters();
        allHSPs = p.medicalCenters;
      } else if (type == 'Nurse') {
        final p = context.read<NurseRetroDisplayGetProvider>();
        await p.fetchNurses();
        allHSPs = p.nurses;
      } else if (type == 'Labrotary') {
        final p = context.read<LabsRetroDisplayGetProvider>();
        await p.fetchLaboratories();
        allHSPs = p.labs;
      } else if (type == 'Dentist') {
        final p = context.read<DoctorRetroDisplayGetProvider>();
        await p.getDoctorsBySpecialty("اسنان");
        allHSPs = p.doctors;
      } else if (type == 'psychologist') {
        final p = context.read<DoctorRetroDisplayGetProvider>();
        await p.getDoctorsBySpecialty("نفسية");
        allHSPs = p.doctors;
      } else if (type == 'xsonarrays') {
        final p = context.read<DoctorRetroDisplayGetProvider>();
        await p.fetchAllDoctors();
        final targets = ['اشعة وسونار', 'اشعة', 'سونار', 'رنين', 'مفراس'];
        allHSPs = p.doctors.where((d) => targets.any((s) => d.specialty?.toLowerCase().contains(s.toLowerCase()) ?? false)).toList();
      } else if (type == 'internationaldoctor') {
        final p = context.read<DoctorRetroDisplayGetProvider>();
        await p.fetchInternationalDoctorsLocally();
        allHSPs = p.doctors;
      } else if (type == 'veterinarian') {
        final p = context.read<DoctorRetroDisplayGetProvider>();
        await p.getDoctorsBySpecialty("بيطري");
        allHSPs = p.doctors;
      }

      allHSPs.sort((a, b) {
        final aAdv = (a is Map ? a['advertise'] : (a.advertise ?? false)) ? 1 : 0;
        final bAdv = (b is Map ? b['advertise'] : (b.advertise ?? false)) ? 1 : 0;
        return bAdv - aAdv;
      });
    } catch (_) {}
    _filterHSPs();
    if (mounted) setState(() => isLoading = false);
  }

  void _filterHSPs() {
    final String q = _searchController.text.toLowerCase();
    final double minRating = (_currentFilters['min_rating'] as double?) ?? 0.0;
    final String addrKw = ((_currentFilters['address_kw'] as String?) ?? '').toLowerCase();
    final bool maleOnly = _currentFilters['sex_male'] == true;
    final bool femaleOnly = _currentFilters['sex_female'] == true;

    if (!mounted) return;
    setState(() {
      filteredHSPs = allHSPs
          .where((hsp) {
            final m = _convertModelToMap(hsp);
            final String name = _extractName(m).toLowerCase();
            if (!name.contains(q)) return false;
            final double r = (m['rating'] as double?) ?? 0.0;
            if (r < minRating) return false;
            final String addr = (m['address'] as String?)?.toLowerCase() ?? '';
            if (addrKw.isNotEmpty && !addr.contains(addrKw)) return false;
            final String? g = (m['gender'] as String?) ?? (m['user']?['gender'] as String?);
            if (maleOnly && g != 'm') return false;
            if (femaleOnly && g != 'f') return false;
            return true;
          })
          .map(_convertModelToMap)
          .toList();
      _sortHSPs(_currentSortCriterion);
    });
  }

  Map<String, dynamic> _convertModelToMap(dynamic model) {
    final Map<String, dynamic> m = {};
    if (model is PharmaModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'Pharmacy',
        'name': model.pharmacyName ?? model.user?.fullName ?? 'اسم غير معروف',
        'specialty': 'صيدلية',
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'advertise': model.advertise ?? false,
        'profileImage': model.profileImage ?? model.user?.profileImage ?? '',
        'phone': model.user?.phoneNumber ?? '',
        'phoneNumber': model.user?.phoneNumber ?? '',
        'gps_location': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'gpsLocation': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'availabilityTime': 'غير متوفر',
        'rating': _randRating(),
        'reviewsCount': _randReviews(),
        'gender': model.user?.gender, 'sentinel': model.sentinel ?? false,
      });
    } else if (model is HospitalModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'Hospital',
        'name': model.hospitalName ?? model.user?.fullName ?? 'اسم غير معروف',
        'specialty': model.specialty ?? 'مستشفى',
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'advertise': model.advertise ?? false,
        'profileImage': model.user?.profileImage ?? '',
        'phone': model.phoneNumber ?? model.user?.phoneNumber ?? '',
        'phoneNumber': model.phoneNumber ?? model.user?.phoneNumber ?? '',
        'gps_location': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'gpsLocation': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'availabilityTime': model.availabilityTime ?? 'غير متوفر',
        'rating': _randRating(),
        'reviewsCount': _randReviews(),
      });
    } else if (model is DoctorModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'Doctor',
        'name': model.user?.fullName ?? 'اسم غير معروف',
        'user': {
          'fullName': model.user?.fullName,
          'profileImage': model.user?.profileImage,
          'phoneNumber': model.user?.phoneNumber,
          'gpsLocation': model.user?.gpsLocation,
          'gender': model.user?.gender,
        },
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'specialty': model.specialty ?? 'طبيب',
        'advertise': model.advertise ?? false,
        'rating': model.reviewsAvg ?? _randRating(),
        'reviewsCount': model.reviewsCount ?? _randReviews(),
        'profileImage': model.user?.profileImage ?? '',
        'phone': model.user?.phoneNumber ?? '',
        'phoneNumber': model.user?.phoneNumber ?? '',
        'gps_location': model.user?.gpsLocation ?? '',
        'gpsLocation': model.user?.gpsLocation ?? '',
        'availabilityTime': model.availabilityTime ?? 'غير متوفر',
        'gender': model.user?.gender,
        'degree': model.degrees,
      });
    } else if (model is BeautyCentersModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'BeautyCenter',
        'name': model.centerName ?? model.user?.fullName ?? 'اسم غير معروف',
        'specialty': 'مركز تجميل',
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'advertise': model.advertise ?? false,
        'profileImage': model.profileImage ?? '',
        'phone': model.user?.phoneNumber ?? '',
        'phoneNumber': model.user?.phoneNumber ?? '',
        'gps_location': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'gpsLocation': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'availabilityTime': model.availabilityTime ?? 'غير متوفر',
        'rating': _randRating(),
        'reviewsCount': _randReviews(),
      });
    } else if (model is MedicalCentersModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'MedicalCenter',
        'name': model.centerName ?? model.fullName ?? 'اسم غير معروف',
        'specialty': 'مركز طبي',
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'advertise': model.advertise ?? false,
        'profileImage': model.profileImage ?? '',
        'phone': model.phoneNumber ?? '',
        'phoneNumber': model.phoneNumber ?? '',
        'gps_location': model.gpsLocation ?? '',
        'gpsLocation': model.gpsLocation ?? '',
        'availabilityTime': model.availabilityTime ?? 'غير متوفر',
        'rating': _randRating(),
        'reviewsCount': _randReviews(),
      });
    } else if (model is NurseModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'Nurse',
        'name': model.user?.fullName ?? 'اسم غير معروف',
        'specialty': model.specialty ?? 'تمريض',
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'advertise': model.advertise ?? false,
        'profileImage': model.user?.profileImage ?? '',
        'phone': model.user?.phoneNumber ?? '',
        'phoneNumber': model.user?.phoneNumber ?? '',
        'gps_location': model.user?.gpsLocation ?? '',
        'gpsLocation': model.user?.gpsLocation ?? '',
        'availabilityTime': model.availabilityTime ?? 'غير متوفر',
        'rating': _randRating(),
        'reviewsCount': _randReviews(),
        'gender': model.user?.gender,
      });
    } else if (model is LabsModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'Labrotary',
        'name': model.laboratoryName ?? model.user?.fullName ?? 'اسم غير معروف',
        'specialty': model.availableTests ?? 'مختبر',
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'advertise': model.advertise ?? false,
        'profileImage': model.profileImage ?? model.user?.profileImage ?? '',
        'phone': model.phoneNumber ?? model.user?.phoneNumber ?? '',
        'phoneNumber': model.phoneNumber ?? model.user?.phoneNumber ?? '',
        'gps_location': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'gpsLocation': model.gpsLocation ?? model.user?.gpsLocation ?? '',
        'availabilityTime': model.availabilityTime ?? 'غير متوفر',
        'rating': _randRating(),
        'reviewsCount': _randReviews(),
      });
    } else if (model is TherapistModel) {
      m.addAll({
        'id': model.id,
        'hspType': 'Therapist',
        'name': model.user?.fullName ?? 'اسم غير معروف',
        'specialty': model.specialty ?? 'علاج طبيعي',
        'bio': model.bio ?? '',
        'address': model.address ?? '',
        'advertise': model.advertise ?? false,
        'profileImage': model.profileImage ?? model.user?.profileImage ?? '',
        'phone': model.user?.phoneNumber ?? '',
        'phoneNumber': model.user?.phoneNumber ?? '',
        'gps_location': model.user?.gpsLocation ?? '',
        'gpsLocation': model.user?.gpsLocation ?? '',
        'availabilityTime': model.availabilityTime ?? 'غير متوفر',
        'rating': _randRating(),
        'reviewsCount': _randReviews(),
        'gender': model.user?.gender,
      });
    } else {
      m.addAll({'hspType': 'Unknown', 'address': '', 'advertise': false});
    }
    m['rating'] ??= _randRating();
    m['reviewsCount'] ??= _randReviews();
    m['numReviews'] ??= m['reviewsCount'];
    return m;
  }

  String _extractName(Map<String, dynamic> hsp) {
    return (hsp['name'] ??
            hsp['hospitalName'] ??
            hsp['pharmacyName'] ??
            hsp['centerName'] ??
            hsp['beautyCenterName'] ??
            hsp['nurseName'] ??
            hsp['therapistName'] ??
            hsp['laboratoryName'] ??
            hsp['user']?['fullName'] ??
            '')
        .toString();
  }

  void _sortHSPs(String criterion) {
    _currentSortCriterion = criterion;
    filteredHSPs.sort((a, b) {
      switch (criterion) {
        case 'name_asc': return _extractName(a).compareTo(_extractName(b));
        case 'name_desc': return _extractName(b).compareTo(_extractName(a));
        case 'rating_desc': return (b['rating'] ?? 0).compareTo(a['rating'] ?? 0);
        case 'rating_asc': return (a['rating'] ?? 0).compareTo(b['rating'] ?? 0);
        default:
          final aAdv = (a['advertise'] ?? false) ? 1 : 0;
          final bAdv = (b['advertise'] ?? false) ? 1 : 0;
          return bAdv - aAdv;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(
          title: Text('البحث عن ${translateHspType(widget.hspType)}'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم...',
                      prefixIcon: const Icon(Icons.search, color: RacheetaColors.primary),
                      fillColor: RacheetaColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilterSortButtons(
                    onFilter: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HSPFilterPage(hspType: widget.hspType.toLowerCase(), currentFilters: _currentFilters, onApplyFilters: (f) { setState(() => _currentFilters = f); _filterHSPs(); }))),
                    onSort: _showSortOptions,
                    onMap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HspsMapScreen(hspType: widget.hspType))),
                    hspType: widget.hspType,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
                  : filteredHSPs.isEmpty
                      ? const RacheetaEmptyState(icon: Icons.search_off_outlined, title: "لا توجد نتائج", subtitle: "جرب تغيير معايير البحث أو التصفية.")
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredHSPs.length,
                          itemBuilder: (context, index) => HSPCard(
                            hsp: filteredHSPs[index],
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HSPProfileReservationPage(hsp: filteredHSPs[index]))),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ترتيب النتائج حسب', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            _sortTile('الاسم (أ → ي)', 'name_asc', Icons.sort_by_alpha_outlined),
            _sortTile('الاسم (ي → أ)', 'name_desc', Icons.sort_by_alpha_outlined),
            _sortTile('الأعلى تقييماً', 'rating_desc', Icons.star_outline),
            _sortTile('الأدنى تقييماً', 'rating_asc', Icons.star_border_outlined),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(String label, String value, IconData icon) {
    final isSelected = _currentSortCriterion == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? RacheetaColors.primary : RacheetaColors.textSecondary),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal, color: isSelected ? RacheetaColors.primary : RacheetaColors.textPrimary)),
      onTap: () { Navigator.pop(context); setState(() => _sortHSPs(value)); },
      trailing: isSelected ? const Icon(Icons.check, color: RacheetaColors.primary) : null,
    );
  }

  String translateHspType(String hspType) {
    final t = {
      'BeautyCenter': 'مركز تجميل', 'Hospital': 'مستشفى', 'Pharmacy': 'صيدلية', 'Therapist': 'معالج',
      'MedicalCenter': 'مركز طبي', 'Nurse': 'ممرضة', 'Labrotary': 'مختبر', 'Dentist': 'طبيب أسنان',
      'psychologist': 'طبيب نفسي', 'internationaldoctor': 'طبيب دولي', 'xsonarrays': 'أشعة ورنين', 'Doctor': 'طبيب',
      'veterinarian': 'بيطري',
    };
    return t[hspType] ?? hspType;
  }
}
