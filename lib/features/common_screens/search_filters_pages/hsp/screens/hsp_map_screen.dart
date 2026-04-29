import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../../../../constansts/constants.dart';
import '../../../../beauty_centers/providers/beauty_centers_provider.dart';
import '../../../../hospitals/providers/hospital_display_provider.dart';
import '../../../../labrotary/providers/labs_provider.dart';
import '../../../../medical_centre/providers/medical_centers_providers.dart';
import '../../../../nurse/providers/nurse_provider.dart';
import '../../../../pharmacist/providers/pharma_provider.dart';
import '../../../../therapist/providers/therapist_provider.dart';
import '../widgets/hsp_map_card.dart';

class HspsMapScreen extends StatefulWidget {
  final String hspType;
  const HspsMapScreen({Key? key, required this.hspType}) : super(key: key);

  @override
  State<HspsMapScreen> createState() => _HspsMapScreenState();
}

class _HspsMapScreenState extends State<HspsMapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  List<Map<String, dynamic>> _nearby = [];

  LatLng _current = const LatLng(33.29527, 44.330616);
  final LatLng _fallback = const LatLng(33.274648, 44.296158);
  double _zoom = 17.0;
  final double _radius = 10000.0;
  bool _usingFallback = true;

  final Map<String, String> _labels = const {
    'BeautyCenter': 'مراكز التجميل',
    'Hospital': 'المستشفيات',
    'Pharmacy': 'الصيدليات',
    'Therapist': 'العلاج الطبيعي',
    'MedicalCenter': 'المراكز الطبية',
    'Nurse': 'الممرضين',
    'Labrotary': 'مختبرات',
    'Dentist': 'أطباء أسنان',
    'psychologist': 'أطباء نفسي',
    'internationaldoctor': 'الأطباء الدوليين',
    'xsonarrays': 'اختصاصات الأشعة',
  };
  /// مفاتيح اسم المنشأة لكل نوع
  static const Map<String, List<String>> _nameFields = {
    'Hospital'     : ['hospital_name','hospitalName'],
    'Pharmacy'     : ['pharmacy_name','pharmacyName'],
    'BeautyCenter' : ['center_name','beauty_center_name','centerName'],
    'MedicalCenter': ['center_name','medical_center_name','centerName'],
    'Labrotary'    : ['laboratory_name','labrotary_name','laboratoryName'],
    'Nurse'        : ['nurse_name','nurseName'],
    'Therapist'    : ['therapist_name','therapistName'],
    'default'      : ['name','title']
  };
  @override
  void initState() {
    super.initState();
    saveCustomLocation();
    // ننفّذ بعد أول إطار حتى يكون FlutterMap موجود:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useFallbackLocation(); // يبدأ بالفالباك
    });
  }

  // يجلب الموقع ثم البيانات
  Future<void> _getCurrentLocationAndFetch() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _current = LatLng(pos.latitude, pos.longitude);
      _usingFallback = false;
      debugPrint('✅ GPS → $_current');
    } catch (_) {
      debugPrint('⚠️ GPS failed → fallback $_fallback');
      _current = _fallback;
      _usingFallback = true;
    }

    // نزل الخريطة بعد رسمها:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_current, _zoom);
    });

    _fetchHsps();
  }

  // استخدام الموقع المخزن
  void _useFallbackLocation() {
    _current = _fallback;
    _usingFallback = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_current, _zoom);
    });

    _fetchHsps();
  }

  // جلب البيانات
  Future<void> _fetchHsps() async {
    List<dynamic> rawList = [];
    try {
      switch (widget.hspType) {
        case 'Hospital':
          final p = context.read<HospitalRetroDisplayGetProvider>();
          await p.fetchHospitals();
          rawList = p.hospitals;
          break;
        case 'Pharmacy':
          final p = context.read<PharmaRetroDisplayGetProvider>();
          await p.fetchPharmacies();
          rawList = p.pharmacies;
          break;
        case 'BeautyCenter':
          final p = context.read<BeautyCentersRetroDisplayGetProvider>();
          await p.fetchBeautyCenters();
          rawList = p.beautyCenters;
          break;
        case 'MedicalCenter':
          final p = context.read<MedicalCentersRetroDisplayGetProvider>();
          await p.fetchMedicalCenters();
          rawList = p.medicalCenters;
          break;
        case 'Therapist':
          final p = context.read<TherapistRetroDisplayGetProvider>();
          await p.fetchTherapists();
          rawList = p.therapists;
          break;
        case 'Labrotary':
          final p = context.read<LabsRetroDisplayGetProvider>();
          await p.fetchLaboratories();
          rawList = p.labs;
          break;
        case 'Nurse':
          final p = context.read<NurseRetroDisplayGetProvider>();
          await p.fetchNurses();
          rawList = p.nurses;
          break;
        default:
          rawList = [];
      }
    } catch (e) {
      debugPrint('❌ fetch error: $e');
    }

    debugPrint('🗄 fetched ${rawList.length} for ${widget.hspType}');
    _filterByDistance(rawList);
  }

  void _filterByDistance(List<dynamic> raw) {
    final dist = Distance();
    final List<Map<String, dynamic>> nearby = [];

    for (var h in raw) {
      // → أجّل gpsRaw لخورطتين: user.gpsLocation أولاً ثم top-level
      String? gpsRaw;
      try {
        gpsRaw = (h.user as dynamic).gpsLocation as String?;
      } catch (_) {}
      if (gpsRaw == null || gpsRaw.trim().isEmpty) {
        try {
          gpsRaw = h.gpsLocation as String?;
        } catch (_) {}
        try {
          gpsRaw ??= h.gps_location as String?;
        } catch (_) {}
      }

      if (gpsRaw == null || !gpsRaw.contains(',')) {
        debugPrint('❌ no valid gps for $h');
        continue;
      }
      debugPrint('🔍 using gpsRaw="$gpsRaw"');

      final parts = gpsRaw.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat == null || lng == null) continue;

      final d = dist.as(LengthUnit.Meter, _current, LatLng(lat, lng));
      debugPrint('   ↪ distance = ${d.toStringAsFixed(0)} m');

      if (d <= _radius) {
        final map = _modelToMap(h, gpsRaw);
        if (map != null) nearby.add(map);
      }
    }

    setState(() {
      _nearby = nearby;
      _setMarkers();
    });
    debugPrint('🎯 nearby count ${_nearby.length}');
  }

  Future<void> saveCustomLocation() async {
    final prefs = await SharedPreferences.getInstance();
    const gpsLocation = '33.274486, 44.295742';
    await prefs.setString('gps_location', gpsLocation);
    print('📍 GPS location saved: $gpsLocation');
  }

// helper: يرجّع أول قيمة غير فارغة من قائمة مفاتيح
  dynamic _firstKey(Map m, List<String> keys) {
    for (final k in keys) {
      if (m[k] != null && m[k].toString().trim().isNotEmpty) return m[k];
    }
    return null;
  }

  Map<String, dynamic> _modelToMap(dynamic h, String gpsRaw) {
    // حوّل إلى Map
    final Map<String,dynamic> m   = (h is Map) ? h : jsonDecode(jsonEncode(h));
    final Map user                = m['user'] is Map ? m['user'] : {};

    /* -------- الاسم -------- */
    final List<String> keys       = _nameFields[widget.hspType] ?? _nameFields['default']!;
    String? name                  = _firstKey(m, keys)?.toString();
    name ??= user['full_name']?.toString();
    name  = (name==null || name.trim().isEmpty) ? 'اسم غير متوفر' : name;

    /* -------- الهاتف والعنوان -------- */
    final phone   = _firstKey(m, ['phoneNumber','phone_number']) ??
        user['phone_number'] ?? '';
    final address = (m['address'] ?? '').toString();

    /* -------- باقى الحقول كما هى -------- */
    final bio   = (m['bio'] ?? m['description'] ?? '').toString();
    final img   = (m['profileImage'] ?? m['image'] ?? m['logo'] ??
        user['profile_image'] ?? 'assets/images/default_avatar.png')
        .toString();
    final avail = (m['availabilityTime'] ?? m['availability_time'] ?? '').toString();


    double rating = (m['reviewsAvg'] ?? m['reviews_avg']) is num
        ? (m['reviewsAvg'] ?? m['reviews_avg']).toDouble()
        : (Random().nextDouble() * 1.25 + 3.0); // بين 3.0 و 4.25

    return {
      'id'             : m['id'],                 // يفيد لاحقاً فى الحجز
      'hspType'        : widget.hspType,          // 👈 نضيف النوع
      'name'           : name,
      'bio'            : bio,
      'profileImage'   : img,
      'availabilityTime': avail,
      'reviewsAvg'     : rating,
      'phone'          : phone,
      'address'        : address,
      'gps_location'   : gpsRaw,
      'fullModel'      : m,                       // الموديل الأصلى كما هو
    };

  }

  void _setMarkers() {
    _markers.clear();
    for (var m in _nearby) {
      final parts = (m['gps_location'] as String).split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      _markers.add(Marker(
        point: LatLng(lat, lng),
        width: 50,
        height: 50,
        child: ClipOval(
          child: Container(
            color: Colors.red.shade400,
            child: const Icon(Icons.local_hospital, color: Colors.white),
          ),
        ),
      ));
    }
    debugPrint('📌 markers set ${_markers.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خريطة ${_labels[widget.hspType] ?? widget.hspType}',
            style: kAppBarDoctorsTextStyle),
        backgroundColor: Colors.blue,
      ),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _current,
            initialZoom: _zoom,
            maxZoom: 19,
          ),
          children: [
            TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
            MarkerLayer(markers: _markers),
          ],
        ),
        // الأزرار
        Positioned(
          right: 10,
          top: 100,
          child: Column(children: [
            FloatingActionButton(
              heroTag: 'gps_${widget.hspType}',
              mini: true,
              backgroundColor: Colors.green,
              onPressed: _getCurrentLocationAndFetch,
              child: const Icon(Icons.my_location),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'fb_${widget.hspType}',
              mini: true,
              backgroundColor: Colors.orange,
              onPressed: _useFallbackLocation,
              child: const Icon(Icons.location_on),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'zi_${widget.hspType}',
              mini: true,
              backgroundColor: Colors.blue,
              onPressed: () {
                setState(() => _zoom = (_zoom + 1).clamp(1, 19));
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.move(_current, _zoom);
                });
              },
              child: const Icon(Icons.zoom_in),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'zo_${widget.hspType}',
              mini: true,
              backgroundColor: Colors.blue,
              onPressed: () {
                setState(() => _zoom = (_zoom - 1).clamp(1, 19));
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.move(_current, _zoom);
                });
              },
              child: const Icon(Icons.zoom_out),
            ),
          ]),
        ),
        // البطاقات
        _nearby.isEmpty
            ? const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('لا توجد خدمات قريبة'),
                )),
              )
            : Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _nearby.length,
                  itemBuilder: (_, i) => HspsMapCard(hsp: _nearby[i]),
                ),
              ),
      ]),
    );
  }
}
