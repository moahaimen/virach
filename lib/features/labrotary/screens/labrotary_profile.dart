// lib/features/labrotary/screens/labrotary_profile.dart

import 'dart:convert';
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
import '../../../widgets/dashboard_widget/common/center_info_tab.dart';
import '../../../widgets/dashboard_widget/common/top_profile_card.dart';
import '../../../widgets/dashboard_widget/common/labeled_text_field.dart';

class LabrotaryProfile extends StatefulWidget {
  const LabrotaryProfile({Key? key}) : super(key: key);

  @override
  State<LabrotaryProfile> createState() => _LabrotaryProfileState();
}

class _LabrotaryProfileState extends State<LabrotaryProfile>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isEditMode = false;
  Map<String, dynamic>? _meData;

  late TabController _tabController;

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _labNameCtrl = TextEditingController();
  final _availableTestsCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _availabilityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _selectedGender = 'ذكر';
  final List<String> _genderOptions = ['ذكر', 'انثى'];
  String _selectedCity = 'بغداد';
  String _selectedDistrict = 'الأعظمية';
  LatLng? _location;
  final LatLng _defaultLocation = LatLng(33.3152, 44.3661);

  File? _profileImage;
  String? _currentProfileImageUrl;

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
    _labNameCtrl.dispose();
    _availableTestsCtrl.dispose();
    _bioCtrl.dispose();
    _availabilityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await ProfileService.fetchMeData(
        prefsKey: 'laboratory_profile_data',
        endpointUrl: 'https://racheeta.pythonanywhere.com/me/',
      );
      _assignMeData(rawData);
    } catch (e) {
      debugPrint('Error loading profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل جلب البيانات')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _assignMeData(Map<String, dynamic> data) {
    _meData = data;
    final user = (data['user'] as Map<String, dynamic>?) ?? {};
    _fullNameCtrl.text = user['full_name'] ?? '';
    _emailCtrl.text = user['email'] ?? '';
    _phoneCtrl.text = user['phone_number'] ?? '';
    _selectedGender =
    (user['gender']?.toLowerCase() == 'f') ? 'انثى' : 'ذكر';

    final rawImg = (user['profile_image']?.toString() ?? '');
    _currentProfileImageUrl = rawImg.isNotEmpty
        ? (rawImg.startsWith('http')
        ? rawImg
        : 'https://racheeta.pythonanywhere.com$rawImg')
        : null;

    final details = (data['role']?['details'] as Map<String, dynamic>?) ?? {};
    _labNameCtrl.text = details['laboratory_name'] ?? '';
    _availableTestsCtrl.text = details['available_tests'] ?? '';
    _bioCtrl.text = details['bio'] ?? '';
    _availabilityCtrl.text = details['availability_time'] ?? '';
    _addressCtrl.text = details['address'] ?? '';

    if (_addressCtrl.text.contains('-')) {
      final parts = _addressCtrl.text.split('-');
      if (parts.length >= 2) {
        _selectedCity = parts[0].trim();
        _selectedDistrict = parts[1].trim();
      }
    }

    final gps = user['gps_location']?.toString() ?? '';
    if (gps.contains(',')) {
      final parts = gps.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        _location = LatLng(lat, lng);
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _selectImage(ImageSource src) async {
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
        _uploadProfileImage(file, userId);
      }
    } catch (e) {
      debugPrint('Image error: $e');
    }
  }

  Future<void> _pickImage() => _selectImage(ImageSource.gallery);
  Future<void> _takePhoto() => _selectImage(ImageSource.camera);

  Future<void> _uploadProfileImage(File img, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('Login_access_token') ?? '';
      final dio = Dio()..options.headers['Authorization'] = 'JWT $token';
      final form = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          img.path,
          filename: img.path.split('/').last,
        ),
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

  Future<void> _saveProfile() async {
    if (_meData == null) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      await SaveProfileService.saveProfile(
        meData: _meData!,
        fullName: _fullNameCtrl.text,
        email: _emailCtrl.text,
        phoneNumber: _phoneCtrl.text,
        selectedGender: _selectedGender,
        gpsLocation: _location,
        centerName: _labNameCtrl.text,
        bio: _bioCtrl.text,
        availabilityTime: _availabilityCtrl.text,
        city: _selectedCity,
        district: _selectedDistrict,
        customCenterFields: {
          'available_tests': _availableTestsCtrl.text
        },
        updateEndpoint: 'laboratories',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحفظ بنجاح')),
      );
      await _loadProfileData();
    } catch (e) {
      debugPrint('Save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل الحفظ')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        title: const Text('ملف المختبر'),
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
            centerDetails: (_meData!['role']?['details'] ?? {}) as Map<String, dynamic>,
            profileImage: _profileImage,
            currentProfileImageUrl: _currentProfileImageUrl,
            isEditMode: _isEditMode,
            onPickImage: _pickImage,
            onTakePhoto: _takePhoto,
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'المعلومات الأساسية'),
              Tab(text: 'معلومات المختبر'),
              Tab(text: 'معلومات التواصل'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
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
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    LabeledTextField(
                      label: 'اسم المختبر',
                      controller: _labNameCtrl,
                      enabled: _isEditMode,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      label: 'الفحوصات المتوفرة',
                      controller: _availableTestsCtrl,
                      enabled: _isEditMode,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      label: 'نبذة عن المختبر',
                      controller: _bioCtrl,
                      enabled: _isEditMode,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      label: 'أوقات التوفر',
                      controller: _availabilityCtrl,
                      enabled: _isEditMode,
                    ),
                  ],
                ),
                ContactInfoTab(
                  selectedCity: _selectedCity,
                  selectedDistrict: _selectedDistrict,
                  addressController: _addressCtrl,
                  location: _location,
                  defaultLocation: _defaultLocation,
                  isEditMode: _isEditMode,
                  onCityChanged: (val) => setState(() => _selectedCity = val),
                  onDistrictChanged: (val) => setState(() => _selectedDistrict = val),
                  onLocationChanged: (loc) => setState(() => _location = loc),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
