import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/features/labrotary/models/labs_model.dart';
import 'package:racheeta/features/pharmacist/providers/pharma_provider.dart';
import '../common_screens/search_filters_pages/hsp/hsp_card.dart';
// Models
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
  final String hspType; // Type of HSP (Hospital, Clinic, Pharmacy, etc.)

  HSPSearchScreen({required this.hspType});

  @override
  _HSPSearchScreenState createState() => _HSPSearchScreenState();
}

class _HSPSearchScreenState extends State<HSPSearchScreen> {
  List<dynamic> allHSPs = []; // Data from backend
  List<dynamic> filteredHSPs = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _currentSortCriterion = 'none';
  bool _isLoading = true;
  Map<String, dynamic> _currentFilters = {
    'sex_male'          : false,
    'sex_female'        : false,

    'degree_consultant' : false,
    'degree_specialist' : false,

    'price_min'         : null,   // double
    'price_max'         : null,   // double

    'address_kw'        : '',     // substring search

    'min_rating'        : 0.0,
    'available_morning' : false,
    'available_evening' : false,
    'home_visit'        : false,
    'sentinel_only'     : false,
  };



  @override
  void initState() {
    super.initState();
    _fetchHSPs();
    _searchController.addListener(_filterHSPs);
  }
  double _randRating() {
    return (Random().nextDouble() * 1.25 + 3.0).clamp(0.0, 5.0); // Between 3.0 and 4.25
  }


  ///_applyMockReviewsIfNeeded
  void _applyMockReviewsIfNeeded(List<dynamic> hsps) {
    for (final hsp in hsps) {
      if (hsp is DoctorModel) {
        hsp.reviewsAvg ??= _randRating();
        hsp.reviewsCount ??= Random().nextInt(151) + 50;
      } else {
        // Attach mock reviews as map if not present
        final map = _convertModelToMap(hsp);
        map['rating'] ??= _randRating();
        map['numReviews'] ??= Random().nextInt(151) + 50;
      }
    }
  }

///_injectMockRating
  void _injectMockRating(dynamic model) {
    final rand = Random();

    final double mockRating = (rand.nextDouble() * 1.25 + 3.0).clamp(0.0, 5.0);
    final int mockCount = rand.nextInt(151) + 50;

    if (model is Map) {
      model['rating'] ??= mockRating;
      model['numReviews'] ??= mockCount;
    } else {
      try {
        if (model.rating == null || model.rating <= 0) {
          model.rating = mockRating;
        }
        if (model.numReviews == null || model.numReviews <= 0) {
          model.numReviews = mockCount;
        }
      } catch (_) {}
    }
  }

  // The main fetch function
  Future<void> _fetchHSPs() async {
    setState(() {
      isLoading = true;
    });

    print("Fetching data for HSP type: ${widget.hspType}");

    try {
      final type = widget.hspType;

      if (type == 'Hospital') {
        final provider = Provider.of<HospitalRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchHospitals();
        _applyMockReviewsIfNeeded(provider.hospitals); // ✅
        allHSPs = provider.hospitals;
      } else if (type == 'BeautyCenter') {
        final provider = Provider.of<BeautyCentersRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchBeautyCenters();
        _applyMockReviewsIfNeeded(provider.beautyCenters); // ✅
        allHSPs = provider.beautyCenters;
      } else if (type == 'Pharmacy') {
        final provider = Provider.of<PharmaRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchPharmacies();
        _applyMockReviewsIfNeeded(provider.pharmacies); // ✅
        allHSPs = provider.pharmacies;
      } else if (type == 'Therapist') {
        final provider = Provider.of<TherapistRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchTherapists();
        _applyMockReviewsIfNeeded(provider.therapists); // ✅
        allHSPs = provider.therapists;
      } else if (type == 'MedicalCenter') {
        final provider = Provider.of<MedicalCentersRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchMedicalCenters();
        _applyMockReviewsIfNeeded(provider.medicalCenters); // ✅
        allHSPs = provider.medicalCenters;
      } else if (type == 'Nurse') {
        final provider = Provider.of<NurseRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchNurses();
        _applyMockReviewsIfNeeded(provider.nurses); // ✅
        allHSPs = provider.nurses;
      } else if (type == 'Labrotary') {
        final provider = Provider.of<LabsRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchLaboratories();
        _applyMockReviewsIfNeeded(provider.labs); // ✅
        allHSPs = provider.labs;
      } else if (type == 'Dentist') {
        final provider = Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
        await provider.getDoctorsBySpecialty("اسنان");
        _applyMockReviewsIfNeeded(provider.doctors); // ✅
        allHSPs = provider.doctors;
      } else if (type == 'psychologist') {
        final provider = Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
        await provider.getDoctorsBySpecialty("نفسية");
        _applyMockReviewsIfNeeded(provider.doctors); // ✅
        allHSPs = provider.doctors;
      } else if (type == 'xsonarrays') {
        final provider = Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchAllDoctors();

        final targetSpecialties = [
          'اشعة وسونار',
          'اشعة',
          'سونار',
          'رنين',
          'مفراس'
        ];

        final filtered = provider.doctors.where((doctor) {
          return targetSpecialties.any((s) =>
          doctor.specialty?.toLowerCase().contains(s.toLowerCase()) ?? false);
        }).toList();

        _applyMockReviewsIfNeeded(filtered); // ✅
        allHSPs = filtered;
      } else if (type == 'internationaldoctor') {
        final provider = Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
        await provider.fetchInternationalDoctorsLocally();
        _applyMockReviewsIfNeeded(provider.doctors); // ✅
        allHSPs = provider.doctors;
      }

      // Sort: ads on top
      allHSPs.sort((a, b) {
        final aAdv = (a is Map ? a['advertise'] : (a.advertise ?? false)) ? 1 : 0;
        final bAdv = (b is Map ? b['advertise'] : (b.advertise ?? false)) ? 1 : 0;
        return bAdv - aAdv;
      });
      for (var hsp in allHSPs) {
        _injectMockRating(hsp);
      }

    } catch (e) {
      print("❌ Error fetching data: $e");
    }

    _filterHSPs();
    setState(() {
      isLoading = false;
    });
  }




  /// Apply search, rating, address, and gender filters
  void _filterHSPs() {
    final String q = _searchController.text.toLowerCase();
    final double minRating = (_currentFilters['min_rating'] as double?) ?? 0.0;
    final String addrKw = ((_currentFilters['address_kw'] as String?) ?? '').toLowerCase();
    final bool maleOnly = _currentFilters['sex_male'] == true;
    final bool femaleOnly = _currentFilters['sex_female'] == true;

    setState(() {
      filteredHSPs = allHSPs.where((hsp) {
        final m = _convertModelToMap(hsp);

        // 1) Name search
        final String name = _extractName(m).toLowerCase();
        if (!name.contains(q)) return false;

        // 2) Rating filter
        final double r = (m['rating'] as double?) ?? 0.0;
        if (r < minRating) return false;

        // 3) Address filter
        final String addr = (m['address'] as String?)?.toLowerCase() ?? '';
        if (addrKw.isNotEmpty && !addr.contains(addrKw)) return false;

        // 4) Gender filter (if active)
        final String? g = (m['gender'] as String?) ?? (m['user']?['gender'] as String?);
        if (maleOnly   && g != 'm') return false;
        if (femaleOnly && g != 'f') return false;

        // 5) (keep your sentinel_only, home_visit, etc. checks here)

        return true;
      })
      // convert each model to a uniform Map
          .map(_convertModelToMap)
          .toList();

      // re–apply the current sort
      _sortHSPs(_currentSortCriterion);
    });
  }

  /// Turn any of our various model types into a uniform Map and ensure `rating` exists
  Map<String, dynamic> _convertModelToMap(dynamic model) {
    final Map<String, dynamic> m = {};

    if (model is PharmaModel) {
      m.addAll({
        'id'          : model.id,
        'hspType'     : 'Pharmacy',
        'pharmacyName': model.pharmacyName,
        'bio'         : model.bio,
        'address'     : model.address,
        'advertise'   : model.advertise,
        'profileImage': model.profileImage,
        'phoneNumber' : model.user?.phoneNumber,
        'gpsLocation' : model.gpsLocation ?? model.user?.gpsLocation,
        'gender'      : model.user?.gender,
        'degree'      : null,
        'sentinel'    : model.sentinel ?? false,
      });
    }
    else if (model is HospitalModel) {
      m.addAll({
        'id'               : model.id,
        'hspType'          : 'Hospital',
        'hospitalName'     : model.hospitalName,
        'bio'              : model.bio,
        'address'          : model.address,
        'specialty'        : model.specialty,
        'availabilityTime' : model.availabilityTime,
        'advertise'        : model.advertise,
        'profileImage'     : model.profileImage,
        'phoneNumber'      : model.user?.phoneNumber,
        'gpsLocation'      : model.gpsLocation,
        'gender'           : null,
        'degree'           : null,
        'homeVisit'        : false,
      });
    }
    else if (model is BeautyCentersModel) {
      m.addAll({
        'id'              : model.id,
        'hspType'         : 'BeautyCenter',
        'beautyCenterName': model.centerName,
        'bio'             : model.bio,
        'address'         : model.address,
        'advertise'       : model.advertise,
        'profileImage'    : model.profileImage,
        'phoneNumber'     : model.user?.phoneNumber,
        'gpsLocation'     : model.gpsLocation,
        'gender'          : null,
        'degree'          : null,
        'homeVisit'       : false,
      });
    }

    else if (model is TherapistModel) {
      m.addAll({
        'id'               : model.id,
        'hspType'          : 'Therapist',
        'therapistName'    : model.user?.fullName,
        'bio'              : model.bio,
        'specialty'        : model.specialty,
        'address'          : model.address,
        'availabilityTime' : model.availabilityTime,
        'advertise'        : model.advertise,
        'profileImage'     : model.user?.profileImage,
        'phoneNumber'      : model.user?.phoneNumber,
        'gpsLocation'      : model.user?.gpsLocation,
        'gender'           : model.user?.gender,
        'degree'           : null,
        'homeVisit'        : false,
      });
    }
    else if (model is MedicalCentersModel) {
      m.addAll({
        'id'               : model.id,
        'hspType'          : 'MedicalCenter',
        'centerName'       : model.centerName,
        'bio'              : model.bio,
        'address'          : model.address,
        'availabilityTime' : model.availabilityTime,
        'advertise'        : model.advertise,
        'profileImage'     : model.profileImage,
        'phoneNumber'      : model.phoneNumber,
        'gpsLocation'      : model.gpsLocation,
        'gender'           : null,
        'degree'           : null,
        'homeVisit'        : false,
      });
    }
    else if (model is NurseModel) {
      m.addAll({
        'id'               : model.id,
        'hspType'          : 'Nurse',
        'nurseName'        : model.user?.fullName,
        'bio'              : model.bio,
        'address'          : model.address,
        'availabilityTime' : model.availabilityTime,
        'advertise'        : model.advertise,
        'profileImage'     : model.user?.profileImage,
        'phoneNumber'      : model.user?.phoneNumber,
        'gpsLocation'      : model.user?.gpsLocation,
        'gender'           : model.user?.gender,
        'degree'           : null,
        'homeVisit'        : false,
      });
    }
    else if (model is LabsModel) {
      m.addAll({
        'id'               : model.id,
        'hspType'          : 'Labrotary',
        'laboratoryName'   : model.laboratoryName,
        'bio'              : model.bio,
        'address'          : model.address,
        'availabilityTime' : model.availabilityTime,
        'advertise'        : model.advertise,
        'profileImage'     : model.user?.profileImage,
        'phoneNumber'      : model.user?.phoneNumber,
        'gpsLocation'      : model.user?.gpsLocation,
        'gender'           : model.user?.gender,
        'degree'           : null,
        'homeVisit'        : false,
      });
    }
    else if (model is DoctorModel) {
      m.addAll({
        'id'               : model.id,
        'hspType'          : 'Doctor',
        'user'             : {
          'fullName'       : model.user?.fullName,
          'profileImage'   : model.user?.profileImage,
        },
        'bio'              : model.bio,
        'address'          : model.address,
        'specialty'        : model.specialty,
        'availabilityTime' : model.availabilityTime,
        'advertise'        : model.advertise,
        'advertisePrice'   : model.advertisePrice,
        'rating'           : model.reviewsAvg,
        'phoneNumber'      : model.user?.phoneNumber,
        'gpsLocation'      : model.user?.gpsLocation,
        'gender'           : model.user?.gender,
        'degree'           : model.degrees,
        'homeVisit'        : (model.voiceCall == true || model.videoCall == true),
      });
    }
    else {
      // fallback for any other type
      m.addAll({
        'hspType'   : 'Unknown',
        'address'   : '',
        'advertise' : false,
      });
    }

    if (!m.containsKey('rating') || m['rating'] == null) {
      m['rating'] = _randRating(); // double between 3.0 - 4.25
    }
    if (!m.containsKey('numReviews') || m['numReviews'] == null) {
      m['numReviews'] = Random().nextInt(151) + 50; // int between 50 - 200
    }


    return m;
  }


  // Sorting omitted for brevity, but you can keep it if you use it

  void _onMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HspsMapScreen(hspType: widget.hspType),
      ),
    );
  }

  void _onFilter() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HSPFilterPage(
          hspType:        widget.hspType.toLowerCase(),
          currentFilters: _currentFilters,
          onApplyFilters: _onApplyFilters,
        ),
      ),
    );
  }




  void _onApplyFilters(Map<String, dynamic> newFilters) {
    print("✅ Filters applied: $newFilters");
    setState(() {
      _currentFilters = newFilters;
    });
    _filterHSPs();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String translateHspType(String hspType) {
    // For display in AppBar
    final translations = {
      'BeautyCenter': 'مركز تجميل',
      'Hospital': 'مستشفى',
      'Pharmacy': 'صيدلية',
      'Therapist': 'معالج',
      'MedicalCenter': 'مركز طبي',
      'Nurse': 'ممرضة',
      'Labrotary': 'مختبر',
      'Dentist': 'طبيب أسنان',
      'psychologist': 'طبيب نفسي',
      'internationaldoctor': 'طبيب دولي',
      'xsonarrays': 'اختصاصات الأشعة',
      'Doctor': 'طبيب',
    };
    return translations[hspType] ?? hspType;
  }
  // ───────────────────────── NAME HELPER ─────────────────────────
  String _extractName(Map<String, dynamic> hsp) {
    return  hsp['hospitalName']       ??
        hsp['pharmacyName']       ??
        hsp['centerName']         ??
        hsp['beautyCenterName']   ??
        hsp['nurseName']          ??
        hsp['therapistName']      ??
        hsp['laboratoryName']     ??
        hsp['user']?['fullName']  ??
        '';
  }

// ───────────────────────── SORTING CORE ─────────────────────────
  void _sortHSPs(String criterion) {
    _currentSortCriterion = criterion;                // remember choice

    filteredHSPs.sort((a, b) {
      // ── force the correct generic type ──
      final Map<String, dynamic> mapA =
      (a is Map<String, dynamic>) ? a : _convertModelToMap(a);

      final Map<String, dynamic> mapB =
      (b is Map<String, dynamic>) ? b : _convertModelToMap(b);

      switch (criterion) {
        case 'name_asc':
          return _extractName(mapA).toLowerCase()
              .compareTo(_extractName(mapB).toLowerCase());

        case 'name_desc':
          return _extractName(mapB).toLowerCase()
              .compareTo(_extractName(mapA).toLowerCase());

        case 'rating_desc':
          return (mapB['rating'] ?? 0).compareTo(mapA['rating'] ?? 0);

        case 'rating_asc':
          return (mapA['rating'] ?? 0).compareTo(mapB['rating'] ?? 0);

        default: // advertise first
          final aAdv = (mapA['advertise'] ?? false) ? 1 : 0;
          final bAdv = (mapB['advertise'] ?? false) ? 1 : 0;
          return bAdv - aAdv;
      }
    });

    setState(() {});                                   // rebuild UI
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('الاسم (أ → ي)'),
            onTap: () { Navigator.pop(context); _sortHSPs('name_asc'); },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('الاسم (ي → أ)'),
            onTap: () { Navigator.pop(context); _sortHSPs('name_desc'); },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('الأعلى تقييماً'),
            onTap: () { Navigator.pop(context); _sortHSPs('rating_desc'); },
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('الأدنى تقييماً'),
            onTap: () { Navigator.pop(context); _sortHSPs('rating_asc'); },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'البحث عن ${translateHspType(widget.hspType)}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن الاسم',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter/Sort Buttons
          FilterSortButtons(
            onFilter: _onFilter,
            onSort  : _showSortOptions,   // ✅ open the modal
            onMap   : _onMap,
            hspType : widget.hspType,
          ),

          // List or loading
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredHSPs.isEmpty
                    ? Center(
                        child: Text('No ${widget.hspType} available'),
                      )
                    : ListView.builder(
                        itemCount: filteredHSPs.length,
                        itemBuilder: (context, index) {
                          final hsp = filteredHSPs[index];
                          print("Displaying HSP: $hsp");
                          return HSPCard(
                            hsp: hsp,
                            onTap: () {
                              print("HSP Card Tapped: $hsp");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HSPProfileReservationPage(hsp: hsp),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
