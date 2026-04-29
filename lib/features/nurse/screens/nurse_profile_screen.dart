// lib/features/nurse/screens/nurse_profile.dart
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

class NurseSingleProfilePage extends StatefulWidget {
  const NurseSingleProfilePage({Key? key}) : super(key: key);

  @override
  State<NurseSingleProfilePage> createState() => _NurseSingleProfilePageState();
}

class _NurseSingleProfilePageState extends State<NurseSingleProfilePage>
    with SingleTickerProviderStateMixin {
  // ───────────────────────── flags / controllers ─────────────────────────
  bool _isLoading = false;
  bool _isEditMode = false;
  Map<String, dynamic>? _meData;

  late final TabController _tabController = TabController(length: 3, vsync: this);

  // user
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  String _selectedGender = 'ذكر';

  // nurse
  final _bioCtrl          = TextEditingController();
  final _availabilityCtrl = TextEditingController();
  final _addressCtrl      = TextEditingController();
  String _selectedSpecialty = 'تمريض';

  // location
  String _selectedCity     = 'بغداد';
  String _selectedDistrict = 'الأعظمية';
  LatLng? _location;
  final _defaultLocation = const LatLng(33.3152, 44.3661);

  // dropdown data
  static const _genderOptions = ['ذكر', 'انثى'];
  static const _specialties   = ['تمريض', 'تداوي وعمليات صغرى'];

  // image
  File?   _profileImage;
  String? _currentProfileImageUrl;

  // ───────────────────────── lifecycle ─────────────────────────
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _availabilityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── data loading ─────────────────────────
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ ما هو متوفّر في الـ provider
      final provider =
      Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false);
      if (provider.meData != null) _assignMeData(provider.meData!);

      // 2️⃣ نسخة حديثة من /me/
      await _fetchMe();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMe() async {
    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString('Login_access_token') ?? '';
    if (token.isEmpty) return;

    final dio = Dio()..options.headers['Authorization'] = 'JWT $token';
    final res = await dio.get('https://racheeta.pythonanywhere.com/me/');

    if (res.statusCode == 200 && res.data != null) {
      _assignMeData(res.data);
      Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false)
          .setMeData(res.data);
      await prefs.setString('nurse_profile_data', jsonEncode(res.data));
    }
  }

  void _assignMeData(Map<String, dynamic> data) {
    _meData = data;

    // user
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

    // location
    final gps = user['gps_location']?.toString() ?? '';
    if (gps.contains(',')) {
      final parts = gps.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) _location = LatLng(lat, lng);
    }

    // nurse
    final details = (data['role']?['details'] ?? {}) as Map<String, dynamic>;
    _bioCtrl.text          = details['bio'] ?? '';
    _availabilityCtrl.text = details['availability_time'] ?? '';
    _selectedSpecialty     =
    _specialties.contains(details['specialty']) ? details['specialty'] : 'تمريض';

    _addressCtrl.text = details['address'] ?? '';
    if (_addressCtrl.text.contains('-')) {
      final parts = _addressCtrl.text.split('-');
      if (parts.length >= 2) {
        _selectedCity     = parts[0].trim();
        _selectedDistrict = parts[1].trim();
      }
    }

    setState(() {});
  }

  // ───────────────────────── image helpers ─────────────────────────
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

  // ───────────────────────── save helpers ─────────────────────────
  Future<void> _saveProfile() async {
    if (_meData == null) return;

    setState(() => _isLoading = true);

    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString('Login_access_token') ?? '';
    final dio    = Dio()..options.headers['Authorization'] = 'JWT $token';

    final userId  = (_meData!['user']           as Map)['id'];
    final nurseId = (_meData!['role']['details'] as Map)['id'];

    final userPayload = {
      'full_name'   : _fullNameCtrl.text.trim(),
      'email'       : _emailCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'gender'      : _selectedGender == 'انثى' ? 'f' : 'm',
    };

    final nursePayload = {
      'bio'            : _bioCtrl.text.trim(),
      'specialty'      : _selectedSpecialty,
      'address'        : '$_selectedCity - $_selectedDistrict',
      'availability_time': _availabilityCtrl.text.trim(),
    };

    await dio.patch('https://racheeta.pythonanywhere.com/users/$userId/',  data: userPayload);
    await dio.patch('https://racheeta.pythonanywhere.com/nurses/$nurseId/', data: nursePayload);

    await _fetchMe();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
    setState(() {
      _isEditMode = false;
      _isLoading  = false;
    });
  }

  // ───────────────────────── UI widgets ─────────────────────────
  Widget _nurseInfoTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      LabeledDropdown(
        label : 'التخصص',
        value : _selectedSpecialty,
        items : _specialties,
        enabled: _isEditMode,
        onChanged: (v) => setState(() => _selectedSpecialty = v ?? _selectedSpecialty),
      ),
      const SizedBox(height: 12),
      LabeledTextField(
        label     : 'أوقات التوفر',
        controller: _availabilityCtrl,
        enabled   : _isEditMode,
      ),
    ],
  );

  // ───────────────────────── build ─────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_meData == null) {
      return const Scaffold(
          body: Center(child: Text('لا توجد بيانات')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف الممرضة'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: _isEditMode
                ? _saveProfile
                : () => setState(() => _isEditMode = true),
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
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'المعلومات الأساسية'),
              Tab(text: 'معلومات الممرضة'),
              Tab(text: 'معلومات التواصل'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
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
                // 2️⃣ Nurse specific
                _nurseInfoTab(),
                // 3️⃣ Contact (يحتوي CityDistrictSelector+الخريطة داخل الـ widget المجرد)
                ContactInfoTab(
                  selectedCity     : _selectedCity,
                  selectedDistrict : _selectedDistrict,
                  addressController: _addressCtrl,
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
