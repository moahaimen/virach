// lib/features/therapists/screens/therapist_profile_page.dart
// نسخة مُبسَّطة تُعيد استعمال الـ widgets المُجرَّدة التي صنعناها سابقاً
// BasicInfoTab – TopProfileCard – ContactInfoTab – TherapistInfoTab – SaveChangesButton

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/profile_service.dart';
import '../../../services/save_profile_service.dart';
import '../../../widgets/dashboard_widget/common/basic_info_tab.dart';
import '../../../widgets/dashboard_widget/common/contact_info_tab.dart';
import '../../../widgets/dashboard_widget/common/therapist_info_tab.dart';
import '../../../widgets/dashboard_widget/common/top_profile_card.dart';
import '../../../widgets/dashboard_widget/common/save_changes_button.dart';

class TherapistSingleProfilePage extends StatefulWidget {
  const TherapistSingleProfilePage({Key? key}) : super(key: key);

  @override
  State<TherapistSingleProfilePage> createState() => _TherapistSingleProfilePageState();
}

class _TherapistSingleProfilePageState extends State<TherapistSingleProfilePage>
    with SingleTickerProviderStateMixin {
  // ------------------------------------------------------------------
  // STATE & CONTROLLERS
  // ------------------------------------------------------------------
  bool _isLoading = false;
  bool _isEditMode = false;
  Map<String, dynamic>? _meData;

  late TabController _tabController;

  // USER
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedGender = 'ذكر';
  final _genderOptions = ['ذكر', 'انثى'];

  // THERAPIST‑specific
  final _bioCtrl = TextEditingController();
  final _availabilityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedSpecialty = 'علاج طبيعي';
  String _selectedDegree = 'بكلريوس';
  String _selectedCountry = 'العراق';

  final _specialties = [
    {'icon': Icons.medical_services, 'label': 'علاج طبيعي'},
    {'icon': Icons.healing, 'label': 'اخرى'},
  ];
  final _degreeOptions = ['اعدادية', 'دبلوم', 'بكلريوس', 'ماستر', 'دكتوراة'];
  final _countries = [
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
  ];

  bool _voiceCall = false;
  bool _videoCall = false;

  // ADDRESS + MAP
  String _selectedCity = 'بغداد';
  String _selectedDistrict = 'الأعظمية';
  final _districts = [
    'الأعظمية',
    'الأمين',
    '(حي أور)',
    'الإعلام (حي الإعلام)',
    'العامرية',
    'العبيدي',
    'العطيفية',
    'حي العدل',
    'باب المعظم',
    'البتاوين',
    'حي البنوك',
    'البياع',
    'البلديات',
    'بغداد الجديدة',
    'الجادرية',
    'حي الجهاد',
    'جميلة',
    'الحارثية',
    'حي الحسين',
    'الحرية',
    'حي العامل',
    'حي الجامعة',
    'حي حطين',
    'حي تونس',
    'حي جميلة',
    'الخضراء',
    'الدورة',
    'حي الرسالة',
    'زيونة',
    'سبع أبكار',
    'حي السلام',
    'السيدية',
    'الشعب',
    'الشرطة (حي الشرطة)',
    'شارع فلسطين',
    'مدينة الصدر',
    'الصليخ',
    'الطالبية',
    'الغدير',
    'الغزالية',
    'الفرات',
    'حي القاهرة',
    'القادسية',
    'الكاظمية',
    'الكرادة',
    'الكفاح',
    'المأمون (حي المأمون)',
    'المثنى (حي المثنى)',
    'المستنصرية (حي المستنصرية)',
    'المعالف',
    'المنصور',
    'المواصلات (حي المواصلات)',
    'الوزيرية',
    'الوشاش',
    'اليرموك',
  ];

  LatLng? _location;
  final _defaultLocation = LatLng(33.3152, 44.3661);

  // IMAGE
  File? _profileImage;
  String? _currentProfileImageUrl;

  // ------------------------------------------------------------------
  // INIT / DISPOSE
  // ------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _priceCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // LOAD & ASSIGN
  // ------------------------------------------------------------------
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await ProfileService.fetchMeData(
        prefsKey: 'therapist_profile_data',
        endpointUrl: 'https://racheeta.pythonanywhere.com/me/',
      );
      _assignMeData(rawData);
    } catch (e) {
      debugPrint('Error loading therapist profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل جلب البيانات')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _assignMeData(Map<String, dynamic> data) {
    _meData = data;

    // USER
    final user = (data['user'] ?? {}) as Map<String, dynamic>;
    _fullNameCtrl.text = user['full_name'] ?? '';
    _emailCtrl.text = user['email'] ?? '';
    _phoneCtrl.text = user['phone_number'] ?? '';
    _selectedGender = (user['gender']?.toLowerCase() == 'f') ? 'انثى' : 'ذكر';

    final rawImg = user['profile_image']?.toString() ?? '';
    _currentProfileImageUrl = rawImg.isNotEmpty
        ? (rawImg.startsWith('http')
        ? rawImg
        : 'https://racheeta.pythonanywhere.com$rawImg')
        : null;

    final gps = user['gps_location']?.toString() ?? '';
    if (gps.contains(',')) {
      final parts = gps.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) _location = LatLng(lat, lng);
    }

    // THERAPIST details
    final details = (data['role']?['details'] ?? {}) as Map<String, dynamic>;
    _bioCtrl.text = details['bio'] ?? '';
    _availabilityCtrl.text = details['availability_time'] ?? '';
    _priceCtrl.text = (details['price']?.toString() ?? '');

    _selectedSpecialty = details['specialty'] ?? _selectedSpecialty;
    _selectedDegree = details['degrees'] ?? _selectedDegree;
    _selectedCountry = details['country'] ?? _selectedCountry;

    _voiceCall = details['voice_call'] ?? false;
    _videoCall = details['video_call'] ?? false;

    // Address "City - District"
    final addr = details['address']?.toString() ?? '';
    if (addr.contains('-')) {
      final parts = addr.split('-');
      if (parts.length >= 2) {
        _selectedCity = parts[0].trim();
        _selectedDistrict = parts[1].trim();
      }
    }

    if (mounted) setState(() {});
  }

  // ------------------------------------------------------------------
  // IMAGE PICK / UPLOAD
  // ------------------------------------------------------------------
  Future<void> _selectImage(ImageSource src) async {
    if (!_isEditMode) return;
    try {
      final picked = await ImagePicker().pickImage(source: src);
      if (picked == null) return;
      final file = File(picked.path);
      if (await file.length() > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حجم الصورة أكبر من 2MB')),
        );
        return;
      }
      setState(() => _profileImage = file);
      if (_meData != null) {
        final userId = (_meData!['user'] as Map)['id'].toString();
        await _uploadProfileImage(file, userId);
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<void> _uploadProfileImage(File img, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('Login_access_token') ?? '';
      final dio = Dio()..options.headers['Authorization'] = 'JWT $token';
      final form = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(img.path,
            filename: img.path.split('/').last),
      });
      final res = await dio.patch(
        'https://racheeta.pythonanywhere.com/users/$userId/',
        data: form,
      );
      if (res.statusCode == 200) {
        setState(() {
          _currentProfileImageUrl = res.data['profile_image'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة')),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
  }

  // ------------------------------------------------------------------
  // SAVE
  // ------------------------------------------------------------------
  Future<void> _saveProfile() async {
    if (_meData == null) return;
    setState(() => _isLoading = true);
    try {
      await SaveProfileService.saveProfile(
        meData: _meData!,
        fullName: _fullNameCtrl.text,
        email: _emailCtrl.text,
        phoneNumber: _phoneCtrl.text,
        selectedGender: _selectedGender,
        gpsLocation: _location,
        // therapist‑specific
        bio: _bioCtrl.text,
        availabilityTime: _availabilityCtrl.text,
        city: _selectedCity,
        district: _selectedDistrict,
        customCenterFields: {
          'specialty': _selectedSpecialty,
          'degrees': _selectedDegree,
          'country': _selectedCountry,
          'price': _priceCtrl.text,
          'voice_call': _voiceCall,
          'video_call': _videoCall,
        },
        updateEndpoint: 'therapists', centerName: '',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحفظ بنجاح')),
        );
      }
      await _loadProfileData();
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الحفظ')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------------
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
        title: const Text('الملف الشخصي للمعالج'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: () async {
              if (_isEditMode) await _saveProfile();
              setState(() => _isEditMode = !_isEditMode);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TopProfileCard(
            user: _meData!['user'] ?? {},
            centerDetails: _meData!['role']?['details'] ?? {},
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
              Tab(text: 'معلومات المعالج'),
              Tab(text: 'معلومات التواصل'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Basic
                BasicInfoTab(
                  fullNameController: _fullNameCtrl,
                  emailController: _emailCtrl,
                  phoneController: _phoneCtrl,
                  selectedGender: _selectedGender,
                  genderOptions: _genderOptions,
                  isEditMode: _isEditMode,
                  onGenderChanged: (val) {
                    if (val != null) setState(() => _selectedGender = val);
                  },
                ),

                // 2. Therapist info
                TherapistInfoTab(
                  selectedSpecialty: _selectedSpecialty,
                  specialties: _specialties,
                  onSpecialtyChanged: (val) =>
                      setState(() => _selectedSpecialty = val),
                  selectedDegree: _selectedDegree,
                  degreeOptions: _degreeOptions,
                  onDegreeChanged: (val) =>
                      setState(() => _selectedDegree = val),
                  selectedCountry: _selectedCountry,
                  countryOptions: _countries,
                  onCountryChanged: (val) =>
                      setState(() => _selectedCountry = val),
                  priceController: _priceCtrl,
                  availabilityController: _availabilityCtrl,
                  voiceCall: _voiceCall,
                  videoCall: _videoCall,
                  onVoiceChanged: (v) => setState(() => _voiceCall = v),
                  onVideoChanged: (v) => setState(() => _videoCall = v),
                  isEditMode: _isEditMode,
                ),

                // 3. Contact info
                ContactInfoTab(
                  selectedCity: _selectedCity,
                  selectedDistrict: _selectedDistrict,
                  addressController:
                  TextEditingController(text: '$_selectedCity - $_selectedDistrict'),
                  location: _location,
                  defaultLocation: _defaultLocation,
                  isEditMode: _isEditMode,
                  onCityChanged: (val) => setState(() => _selectedCity = val),
                  onDistrictChanged: (val) =>
                      setState(() => _selectedDistrict = val),
                  onLocationChanged: (loc) => setState(() => _location = loc),
                ),
              ],
            ),
          ),
          SaveChangesButton(
            visible: _isEditMode,
            onPressed: () async {
              await _saveProfile();
              setState(() => _isEditMode = false);
            },
          ),
        ],
      ),
    );
  }
}
