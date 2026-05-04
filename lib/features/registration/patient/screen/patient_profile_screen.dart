import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'package:racheeta/core/config/app_config.dart';

import '../../../../models/medicals/bagdhad_districts_list.dart';
import '../../../../widgets/gps_maps/location_selector.dart';
import '../../../doctors/models/user_model.dart';
import '../../../jobseeker/models/jobseeker_model.dart';
import '../../../jobseeker/providers/jobseeker_provider.dart';

class JobSeekerJobseekerSideProfilePage extends StatefulWidget {
  const JobSeekerJobseekerSideProfilePage({super.key});

  @override
  State<JobSeekerJobseekerSideProfilePage> createState() => _JobSeekerJobseekerSideProfilePageState();
}

class _JobSeekerJobseekerSideProfilePageState extends State<JobSeekerJobseekerSideProfilePage> {
  String profileImageUrl = "";
  String fullName = "";
  String email = "";
  String phoneNumber = "";
  String location = "";
  String gender = "m";
  bool isLoading = true;
  bool isEditing = false;
  String selectedCity = "بغداد";
  String selectedDistrict = "الأعظمية";
  
  String degreeImageUrl = "";
  String selectedSpecialty = "";
  String selectedDegree = "";

  LatLng? userLatLng;
  final TextEditingController _addressController = TextEditingController();
  final List<String> specialtiesOptions = ['ممرض', 'معالج طبيعي', 'طبيب', 'مهندس', 'مبرمج حاسبات', 'اخرى'];
  final List<String> degreeOptions = ['اخرى', 'اعدادية', 'دبلوم', 'بكالوريوس', 'ماستر', 'دكتوراة'];

  File? _profileImage;
  File? _degreeImageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _pickImage(bool isProfile) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) _profileImage = File(pickedFile.path);
        else _degreeImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return;

      final provider = context.read<JobSeekerRetroDisplayGetProvider>();
      final UserModel? user = await provider.fetchUserById(userId);
      JobSeekerModel? js = await provider.fetchCurrentJobSeekerByUserID();

      if (mounted) {
        setState(() {
          profileImageUrl = user?.profileImage ?? '';
          fullName = user?.fullName ?? '';
          email = user?.email ?? '';
          phoneNumber = user?.phoneNumber ?? '';
          location = user?.gpsLocation ?? '';
          gender = user?.gender ?? 'm';

          if (js != null) {
            selectedSpecialty = js.specialty ?? '';
            selectedDegree = js.degree ?? '';
            degreeImageUrl = js.degreeImage ?? '';
            _addressController.text = js.address ?? '';
          }

          _nameController.text = fullName;
          _emailController.text = email;
          _phoneController.text = phoneNumber;
          _locationController.text = location;

          if (location.contains(',')) {
            final parts = location.split(',');
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null) userLatLng = LatLng(lat, lng);
          }
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showError("الاسم مطلوب");
      return;
    }

    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final jobSeekerId = prefs.getString('jobseeker_id');
      final token = prefs.getString('access_token') ?? prefs.getString('Login_access_token');

      final dio = Dio();
      dio.options.headers['Authorization'] = '${AppConfig.authorizationPrefix} $token';

      final userPayload = {
        "full_name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "gps_location": _locationController.text.trim(),
        "gender": gender,
      };

      await dio.patch('${AppConfig.baseUrl}users/$userId/', data: userPayload);

      if (_profileImage != null) {
        final form = FormData.fromMap({
          "profile_image": await MultipartFile.fromFile(_profileImage!.path),
        });
        await dio.patch('${AppConfig.baseUrl}users/$userId/', data: form);
      }

      if (jobSeekerId != null && jobSeekerId.isNotEmpty) {
        final jsPayload = {
          "specialty": selectedSpecialty,
          "degree": selectedDegree,
          "address": _addressController.text.trim(),
        };
        await dio.patch('${AppConfig.baseUrl}jobseekers/$jobSeekerId/', data: jsPayload);

        if (_degreeImageFile != null) {
          final degForm = FormData.fromMap({
            "degree_image": await MultipartFile.fromFile(_degreeImageFile!.path),
          });
          await dio.patch('${AppConfig.baseUrl}jobseekers/$jobSeekerId/', data: degForm);
        }
      }

      _showInfo("تم تحديث الملف الشخصي بنجاح");
      setState(() => isEditing = false);
      _fetchUserProfile();
    } catch (e) {
      _showError("فشل تحديث البيانات");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: RacheetaColors.danger));
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: RacheetaColors.primary));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          actions: [
            TextButton(
              onPressed: isEditing ? _updateUserProfile : () => setState(() => isEditing = true),
              child: Text(isEditing ? 'حفظ' : 'تعديل', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  RacheetaCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildEditableField(Icons.person_outline, 'الاسم الكامل', _nameController),
                        _buildEditableField(Icons.phone_android_outlined, 'رقم الهاتف', _phoneController),
                        _buildEditableField(Icons.email_outlined, 'البريد الإلكتروني', _emailController),
                        _buildGenderSelection(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const RacheetaSectionHeader(title: 'معلومات الباحث عن عمل'),
                  RacheetaCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDropdownField('التخصص', selectedSpecialty, specialtiesOptions, (v) => setState(() => selectedSpecialty = v!)),
                        _buildDropdownField('الشهادة', selectedDegree, degreeOptions, (v) => setState(() => selectedDegree = v!)),
                        _buildEditableField(Icons.location_city_outlined, 'العنوان بالتفصيل', _addressController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                image: DecorationImage(
                  image: _profileImage != null 
                    ? FileImage(_profileImage!) 
                    : (profileImageUrl.startsWith('http') 
                        ? NetworkImage(profileImageUrl) 
                        : const AssetImage('assets/images/default_avatar.png')) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: RacheetaColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditableField(IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: RacheetaColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEditing,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: isEditing ? Colors.white : RacheetaColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: RacheetaColors.border)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الجنس', style: TextStyle(fontSize: 12, color: RacheetaColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _genderButton('ذكر', 'm', Icons.male),
            const SizedBox(width: 12),
            _genderButton('أنثى', 'f', Icons.female),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String label, String value, IconData icon) {
    final isSelected = gender == value;
    return Expanded(
      child: InkWell(
        onTap: isEditing ? () => setState(() => gender = value) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? RacheetaColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? RacheetaColors.primary : RacheetaColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : RacheetaColors.textSecondary),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : RacheetaColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: RacheetaColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: options.contains(value) ? value : null,
            onChanged: isEditing ? onChanged : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEditing ? Colors.white : RacheetaColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: RacheetaColors.border)),
            ),
            items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          ),
        ],
      ),
    );
  }
}
