// lib/features/doctor/screens/doctor_profile.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/dashboard_widget/common/basic_info_tab.dart';
import '../../../widgets/dashboard_widget/common/contact_info_tab.dart';
import '../../../widgets/dashboard_widget/common/labeled_dropdown.dart';
import '../../../widgets/dashboard_widget/common/labeled_text_field.dart';
import '../../../widgets/dashboard_widget/common/save_changes_button.dart';
import '../../../widgets/dashboard_widget/common/top_profile_card.dart';
import '../../reservations/providers/reservations_provider.dart';

class DoctorSingleProfilePage extends StatefulWidget {
  const DoctorSingleProfilePage({Key? key}) : super(key: key);

  @override
  State<DoctorSingleProfilePage> createState() => _DoctorSingleProfilePageState();
}

class _DoctorSingleProfilePageState extends State<DoctorSingleProfilePage>
    with SingleTickerProviderStateMixin {
  /* ───────── flags / controllers ───────── */
  bool _isLoading = false;
  bool _isEditMode = false;
  Map<String, dynamic>? _meData;

  late final TabController _tab = TabController(length: 3, vsync: this);

  // user
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  String _selectedGender = 'ذكر';

  // doctor
  final _bioCtrl          = TextEditingController();
  final _availabilityCtrl = TextEditingController();
  final _priceCtrl        = TextEditingController();

  // location
  String _selectedCity     = 'بغداد';
  String _selectedDistrict = 'الأعظمية';
  LatLng? _location;
  final _defaultLocation = const LatLng(33.3152, 44.3661);

  // dropdown data
  static const _genderOptions = ['ذكر', 'انثى'];

  // specialty (icons + label) ➜ نستخرج اللابل فقط للـ Dropdown
  static const _specialties = [
    {'icon': Icons.medical_services, 'label': 'اشعة وسونار'},
    {'icon': Icons.healing,          'label': 'باطنية'},
    {'icon': Icons.favorite,         'label': 'cardio'},
    {'icon': Icons.accessibility,    'label': 'bones'},
    {'icon': Icons.psychology,       'label': 'sycho'},
    {'icon': Icons.woman,            'label': 'breasts'},
    {'icon': Icons.bloodtype,        'label': 'امراض دم'},
    {'icon': Icons.coronavirus,      'label': 'اورام'},
    {'icon': Icons.hearing,          'label': 'انف واذن وحنجرة'},
    {'icon': Icons.pregnant_woman,   'label': 'النسائية والتوليد'},
    {'icon': Icons.restaurant_menu,  'label': 'تغذية'},
    {'icon': Icons.face,             'label': 'جلدية'},
    {'icon': Icons.water_drop,       'label': 'المجاري البولية'},
    {'icon': Icons.face_retouching_natural,'label': 'تجميل'},
    {'icon': Icons.medical_services, 'label': 'اسنان'},
    {'icon': Icons.remove_red_eye,   'label': 'عيون'},
    {'icon': Icons.family_restroom,  'label': 'عقم'},
    {'icon': Icons.pregnant_woman,   'label': 'نسائية'},
    {'icon': Icons.medical_services, 'label': 'جراحة عامة'},
    {'icon': Icons.bloodtype,        'label': 'أمراض الدم'},
    {'icon': Icons.sports,           'label': 'الطب الرياضي'},
    {'icon': Icons.accessibility_new,'label': 'العلاج الطبيعي'},
    {'icon': Icons.child_care,       'label': 'أطفال'},
    {'icon': Icons.medical_information,'label': 'أمراض الكلى'},
    {'icon': Icons.medical_services, 'label': 'الغدد الصماء'},
    {'icon': Icons.coronavirus,      'label': 'أورام'},
    {'icon': Icons.accessibility,    'label': 'مفاصل'},
    {'icon': Icons.favorite,         'label': 'قلبية'},
    {'icon': Icons.psychology,       'label': 'مخ واعصاب'},
    {'icon': Icons.psychology,       'label': 'طب نفسي'},
    {'icon': Icons.pets,             'label': 'بيطري'},
  ];
  static final _specialtyLabels =
  _specialties.map((e) => e['label'] as String).toList();
  String? _selectedSpecialty; // قد تكون null لو لم يطابق الـ backend

  // degree / country
  static const _degreeOptions = [
    'اعدادية',
    'دبلوم',
    'بكلريوس',
    'ماستر',
    'دكتوراة'
  ];
  String _selectedDegree  = 'بكلريوس';

  static const _countries = [
    'العراق',
    'سوريا',
    'لبنان',
    'الأردن',
    'مصر',
    'السعودية',
    'الإمارات',
    'الكويت',
    'قطر',
    'البحرين',
    'عمان',
    'اليمن',
    'فلسطين',
    'ليبيا',
    'تونس',
    'الجزائر',
    'المغرب',
    'السودان',
    'France',      // لأن الـ backend قد يعيد أسماء إنجليزية
  ];
  String _selectedCountry = 'العراق';

  // extra flags
  bool _voiceCall = false;
  bool _videoCall = false;

  // image
  File?   _profileImage;
  String? _currentProfileImageUrl;

  /* ───────── lifecycle ───────── */
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _tab.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _availabilityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  /* ───────── data ───────── */
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final provider =
      Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false);
      if (provider.meData != null) _assignMeData(provider.meData!);
      await _fetchMe();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Login_access_token') ?? '';
    if (token.isEmpty) return;

    final dio = Dio()..options.headers['Authorization'] = 'JWT $token';
    final res = await dio.get('https://racheeta.pythonanywhere.com/me/');

    if (res.statusCode == 200 && res.data != null) {
      _assignMeData(res.data);
      Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false)
          .setMeData(res.data);
      await prefs.setString('doctor_profile_data', jsonEncode(res.data));
    }
  }

  /* ───────── parsing ───────── */
  void _assignMeData(Map<String, dynamic> data) {
    _meData = data;

    final user = (data['user'] ?? {}) as Map<String, dynamic>;
    _fullNameCtrl.text = user['full_name'] ?? '';
    _emailCtrl.text    = user['email'] ?? '';
    _phoneCtrl.text    = user['phone_number'] ?? '';
    _selectedGender    =
    (user['gender']?.toString().toLowerCase() == 'f') ? 'انثى' : 'ذكر';

    final rawImg = user['profile_image']?.toString() ?? '';
    _currentProfileImageUrl = rawImg.isEmpty
        ? null
        : rawImg.startsWith('http')
        ? rawImg
        : 'https://racheeta.pythonanywhere.com$rawImg';

    final gps = user['gps_location']?.toString() ?? '';
    if (gps.contains(',')) {
      final parts = gps.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) _location = LatLng(lat, lng);
    }

    final details = (data['role']?['details'] ?? {}) as Map<String, dynamic>;
    _bioCtrl.text          = details['bio'] ?? '';
    _availabilityCtrl.text = details['availability_time'] ?? '';
    _priceCtrl.text        = details['price']?.toString() ?? '';

    // specialty
    final rawSpec = details['specialty']?.toString();
    _selectedSpecialty = _specialtyLabels.contains(rawSpec) ? rawSpec : null;

    // degree
    final rawDeg = details['degrees']?.toString() ?? '';
    _selectedDegree =
    _degreeOptions.contains(rawDeg) ? rawDeg : _degreeOptions.first;

    // country
    final rawCountry = details['country']?.toString() ?? '';
    _selectedCountry =
    _countries.contains(rawCountry) ? rawCountry : _countries.first;

    // address → city-district
    final address = details['address']?.toString() ?? '';
    if (address.contains('-')) {
      final parts = address.split('-');
      if (parts.length >= 2) {
        _selectedCity     = parts[0].trim();
        _selectedDistrict = parts[1].trim();
      }
    }

    _voiceCall = details['voice_call'] ?? false;
    _videoCall = details['video_call'] ?? false;

    setState(() {});
  }

  /* ───────── image ───────── */
  Future<void> _selectImage(ImageSource src) async {
    if (!_isEditMode) return;
    final picked = await ImagePicker().pickImage(source: src);
    if (picked == null) return;
    final file = File(picked.path);
    if (await file.length() > 2 * 1024 * 1024) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('حجم الصورة أكبر من 2MB')));
      return;
    }
    setState(() => _profileImage = file);
    if (_meData == null) return;
    await _uploadProfileImage(file, (_meData!['user'] as Map)['id']);
  }

  Future<void> _uploadProfileImage(File img, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Login_access_token') ?? '';

    final dio = Dio()..options.headers['Authorization'] = 'JWT $token';
    final form = FormData.fromMap({
      'profile_image':
      await MultipartFile.fromFile(img.path, filename: img.path.split('/').last),
    });
    final res = await dio.patch(
      'https://racheeta.pythonanywhere.com/users/$userId/',
      data: form,
    );

    if (res.statusCode == 200) {
      setState(() => _currentProfileImageUrl = res.data['profile_image']);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم تحديث الصورة')));
    }
  }

  /* ───────── save ───────── */
  Future<void> _saveProfile() async {
    if (_meData == null) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Login_access_token') ?? '';
    final dio   = Dio()..options.headers['Authorization'] = 'JWT $token';

    final userId  = (_meData!['user']           as Map)['id'];
    final doctorId= (_meData!['role']['details'] as Map)['id'];

    final userPayload = {
      'full_name'   : _fullNameCtrl.text.trim(),
      'email'       : _emailCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'gender'      : _selectedGender == 'انثى' ? 'f' : 'm',
      if (_location != null)
        'gps_location': '${_location!.latitude}, ${_location!.longitude}',
    };

    final priceDouble =
    _priceCtrl.text.trim().isEmpty ? null : double.tryParse(_priceCtrl.text);

    final doctorPayload = {
      'bio'            : _bioCtrl.text.trim(),
      'specialty'      : _selectedSpecialty,
      'degrees'        : _selectedDegree,
      'country'        : _selectedCountry,
      'address'        : '$_selectedCity - $_selectedDistrict',
      'availability_time': _availabilityCtrl.text.trim(),
      'price'          : priceDouble,
      'voice_call'     : _voiceCall,
      'video_call'     : _videoCall,
    }..removeWhere((_, v) => v == null);

    await dio.patch('https://racheeta.pythonanywhere.com/users/$userId/',   data: userPayload);
    await dio.patch('https://racheeta.pythonanywhere.com/doctor/$doctorId/',data: doctorPayload);

    await _fetchMe();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));

    setState(() {
      _isEditMode = false;
      _isLoading  = false;
    });
  }

  /* ───────── ui: Doctor info tab ───────── */
  Widget _doctorInfoTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // specialty dropdown مع أيقونات
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('التخصص',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: _isEditMode ? Colors.white : Colors.grey[100],
            ),
            child: DropdownButton<String>(
              value: _specialtyLabels.contains(_selectedSpecialty)
                  ? _selectedSpecialty
                  : null,
              isExpanded: true,
              underline: const SizedBox(),
              onChanged: !_isEditMode
                  ? null
                  : (v) => setState(() => _selectedSpecialty = v),
              items: _specialties.map((spec) {
                return DropdownMenuItem<String>(
                  value: spec['label'] as String,
                  child: Row(
                    children: [
                      Icon(spec['icon'] as IconData, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(spec['label'] as String),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      LabeledDropdown(
        label   : 'الشهادات',
        value   : _selectedDegree,
        items   : _degreeOptions,
        enabled : _isEditMode,
        onChanged: (v) => setState(() => _selectedDegree = v ?? _selectedDegree),
      ),
      const SizedBox(height: 12),
      LabeledDropdown(
        label   : 'الدولة',
        value   : _selectedCountry,
        items   : _countries,
        enabled : _isEditMode,
        onChanged: (v) => setState(() => _selectedCountry = v ?? _selectedCountry),
      ),
      const SizedBox(height: 12),
      // العنوان + الخريطة مدمج داخل ContactInfoTab لذلك لا نكرره هنا
      LabeledTextField(
        label     : 'سعر الكشفية',
        controller: _priceCtrl,
        keyboardType: TextInputType.number,
        enabled   : _isEditMode,
      ),
      const SizedBox(height: 12),
      LabeledTextField(
        label     : 'أوقات التوفر',
        controller: _availabilityCtrl,
        enabled   : _isEditMode,
      ),
      const SizedBox(height: 12),
      // voice / video checkboxes
      if (_isEditMode) ...[
        CheckboxListTile(
          title: const Text('المكالمات الصوتية'),
          value: _voiceCall,
          onChanged: (v) => setState(() => _voiceCall = v ?? false),
        ),
        CheckboxListTile(
          title: const Text('المكالمات المرئية'),
          value: _videoCall,
          onChanged: (v) => setState(() => _videoCall = v ?? false),
        ),
      ] else ...[
        ListTile(
          leading: Icon(
            _voiceCall ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.grey,
          ),
          title: const Text('المكالمات الصوتية'),
        ),
        ListTile(
          leading: Icon(
            _videoCall ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.grey,
          ),
          title: const Text('المكالمات المرئية'),
        ),
      ],
    ],
  );

  /* ───────── build ───────── */
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_meData == null) {
      return const Scaffold(body: Center(child: Text('لا توجد بيانات')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف الطبيب'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed:
            _isEditMode ? _saveProfile : () => setState(() => _isEditMode = true),
          ),
        ],
      ),
      body: Column(
        children: [
          TopProfileCard(
            user: _meData!['user'] ?? {},
            centerDetails: {'center_name': '', 'bio': _bioCtrl.text},
            profileImage: _profileImage,
            currentProfileImageUrl: _currentProfileImageUrl,
            isEditMode: _isEditMode,
            onPickImage: () => _selectImage(ImageSource.gallery),
            onTakePhoto: () => _selectImage(ImageSource.camera),
          ),
          TabBar(
            controller: _tab,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'المعلومات الأساسية'),
              Tab(text: 'معلومات الطبيب'),
              Tab(text: 'معلومات التواصل'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // 1️⃣ Basic
                BasicInfoTab(
                  fullNameController: _fullNameCtrl,
                  emailController   : _emailCtrl,
                  phoneController   : _phoneCtrl,
                  selectedGender    : _selectedGender,
                  genderOptions     : _genderOptions,
                  isEditMode        : _isEditMode,
                  onGenderChanged   : (v) => setState(() => _selectedGender = v ?? _selectedGender),
                ),
                // 2️⃣ Doctor specific
                _doctorInfoTab(),
                // 3️⃣ Contact
                ContactInfoTab(
                  selectedCity     : _selectedCity,
                  selectedDistrict : _selectedDistrict,
                  addressController: TextEditingController(text: '$_selectedCity - $_selectedDistrict'),
                  location         : _location,
                  defaultLocation  : _defaultLocation,
                  isEditMode       : _isEditMode,
                  onCityChanged    : (v) => setState(() => _selectedCity = v),
                  onDistrictChanged: (v) => setState(() => _selectedDistrict = v),
                  onLocationChanged: (loc) => setState(() => _location = loc),
                ),
              ],
            ),
          ),
          SaveChangesButton(visible: _isEditMode, onPressed: _saveProfile),
        ],
      ),
    );
  }
}
