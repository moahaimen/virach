import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/save_profile_service.dart';
import '../../../widgets/dashboard_widget/common/basic_info_tab.dart';
import '../../../widgets/dashboard_widget/common/center_info_tab.dart';
import '../../../widgets/dashboard_widget/common/contact_info_tab.dart';
import '../../../widgets/dashboard_widget/common/top_profile_card.dart';
import '../../../services/profile_service.dart'; // << your new service

class BeautyCenterProfile extends StatefulWidget {
  const BeautyCenterProfile({Key? key}) : super(key: key);

  @override
  State<BeautyCenterProfile> createState() => _BeautyCenterProfileState();
}

class _BeautyCenterProfileState extends State<BeautyCenterProfile>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isEditMode = false;
  Map<String, dynamic>? _meData;

  late TabController _tabController;

  // -------------------------------------------------------
  // Controllers & local state
  // -------------------------------------------------------
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedGender = 'ذكر'; // default
  final List<String> _genderOptions = ['ذكر', 'انثى'];

  final _centerNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _availabilityCtrl = TextEditingController();

  final _addressCtrl = TextEditingController();
  String _selectedCity = 'بغداد';
  String _selectedDistrict = 'الأعظمية';

  LatLng? _location;
  final _defaultLocation = LatLng(33.3152, 44.3661);

  File? _profileImage;
  String? _currentProfileImageUrl;

  // -------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData(); // fetch from server / cache
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _centerNameCtrl.dispose();
    _bioCtrl.dispose();
    _availabilityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // Load + assign meData (using the new service)
  // -------------------------------------------------------
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      // Use our shared service instead of copying Dio/prefs code here
      final rawData = await ProfileService.fetchMeData(
        prefsKey: 'beauty_center_profile_data',
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

    // Extract user fields
    final user = (data['user'] as Map<String, dynamic>?) ?? {};
    _fullNameCtrl.text = (user['full_name'] ?? '') as String;
    _emailCtrl.text = (user['email'] ?? '') as String;
    _phoneCtrl.text = (user['phone_number'] ?? '') as String;

    _selectedGender =
    ((user['gender'] ?? 'm').toString().toLowerCase() == 'f') ? 'انثى' : 'ذكر';

    // Extract profile image URL
    final rawImg = (user['profile_image']?.toString() ?? '');
    _currentProfileImageUrl = rawImg.isNotEmpty
        ? (rawImg.startsWith('http')
        ? rawImg
        : 'https://racheeta.pythonanywhere.com$rawImg')
        : null;

    // Extract beauty-center–specific fields
    final details = (data['role'] as Map<String, dynamic>?)?['details']
    as Map<String, dynamic>? ??
        {};
    _centerNameCtrl.text = (details['center_name'] ?? '') as String;
    _bioCtrl.text = (details['bio'] ?? '') as String;
    _availabilityCtrl.text = (details['availability_time'] ?? '') as String;
    _addressCtrl.text = (details['address'] ?? '') as String;

    // If address contains “City - District”, split it
    if (_addressCtrl.text.contains('-')) {
      final parts = _addressCtrl.text.split('-');
      if (parts.length >= 2) {
        _selectedCity = parts[0].trim();
        _selectedDistrict = parts[1].trim();
      }
    }

    // Extract GPS location if present
    final gps = (user['gps_location']?.toString()) ?? '';
    if (gps.contains(',')) {
      final parts = gps.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        _location = LatLng(lat, lng);
      }
    }

    // Force a rebuild
    if (mounted) setState(() {});
  }

  // -------------------------------------------------------
  // Image‐pick / upload helpers (no change needed here)
  // -------------------------------------------------------
  Future<void> _pickImage() => _selectImage(ImageSource.gallery);
  Future<void> _takePhoto() => _selectImage(ImageSource.camera);

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
          _currentProfileImageUrl = res.data['profile_image'] as String?;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة')),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
  }

  // -------------------------------------------------------
  // SAVE logic: call our new ProfileService.saveProfile
  // -------------------------------------------------------
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

        centerName: _centerNameCtrl.text,
        bio: _bioCtrl.text,
        availabilityTime: _availabilityCtrl.text,
        city: _selectedCity,
        district: _selectedDistrict,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحفظ بنجاح')),
      );

      // Refresh local state from server‐side
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

  // -------------------------------------------------------
  // Build UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_meData == null) {
      return const Scaffold(
        body: Center(child: Text('لا توجد بيانات')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف مركز التجميل'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: () async {
              if (_isEditMode) {
                await _saveProfile();
              }
              setState(() => _isEditMode = !_isEditMode);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopProfileCard(
              user: _meData!['user'] as Map<String, dynamic>,
              centerDetails: (_meData!['role'] as Map)['details']
              as Map<String, dynamic>,
              profileImage: _profileImage,
              currentProfileImageUrl: _currentProfileImageUrl,
              isEditMode: _isEditMode,
              onPickImage: _pickImage,
              onTakePhoto: _takePhoto,
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'المعلومات الأساسية'),
                Tab(text: 'معلومات المركز'),
                Tab(text: 'معلومات التواصل'),
              ],
            ),
            SizedBox(
              height: 420,
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
                  CenterInfoTab(
                    centerNameController: _centerNameCtrl,
                    bioController: _bioCtrl,
                    availabilityController: _availabilityCtrl,
                    isEditMode: _isEditMode,
                  ),
                  ContactInfoTab(
                    selectedCity: _selectedCity,
                    selectedDistrict: _selectedDistrict,
                    addressController: _addressCtrl,
                    location: _location,
                    defaultLocation: _defaultLocation,
                    isEditMode: _isEditMode,
                    onCityChanged: (val) {
                      if (val != null) setState(() => _selectedCity = val);
                    },
                    onDistrictChanged: (val) {
                      if (val != null) setState(() => _selectedDistrict = val);
                    },
                    onLocationChanged: (loc) {
                      setState(() => _location = loc);
                    },
                  ),
                ],
              ),
            ),
            if (_isEditMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveProfile();
                    setState(() => _isEditMode = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('احفظ التعديلات'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
