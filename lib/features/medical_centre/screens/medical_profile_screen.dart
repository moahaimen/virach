import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class MedicalCentreProfile extends StatefulWidget {
  const MedicalCentreProfile({Key? key}) : super(key: key);

  @override
  _MedicalCentreProfileState createState() => _MedicalCentreProfileState();
}

class _MedicalCentreProfileState extends State<MedicalCentreProfile>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isEditMode = false;
  Map<String, dynamic>? _meData;

  late TabController _tabController;

  // Common user fields (from user object)
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  // Gender: backend sends 'f' for female and 'm' for male.
  String _selectedGender = 'ذكر'; // default is 'ذكر'
  final List<String> _genderOptions = ['ذكر', 'انثى'];

  // Medical Center–specific fields (from role.details)
  final TextEditingController _centerNameCtrl = TextEditingController();
  final TextEditingController _directorNameCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _availabilityCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  // For address dropdowns
  String _selectedCity = 'بغداد';
  String _selectedDistrict = 'الأعظمية';
  final List<String> districts = [
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

  // Map and location
  LatLng? _location;
  final LatLng _defaultLocation = LatLng(33.3152, 44.3661);
  final MapController _mapController = MapController();

  // Profile image
  File? _profileImage;
  String? _currentProfileImageUrl;

  // For voice/video calls if needed (not specified in payload)
  bool _voiceCall = false;
  bool _videoCall = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");
      if (token == null || token.isEmpty) {
        throw Exception("No token found in SharedPreferences");
      }
      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";

      final response = await dio.get("https://racheeta.pythonanywhere.com/me/");
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _assignMeData(response.data);
          _isLoading = false;
        });
        // Optionally cache data
        await prefs.setString(
            'medical_center_profile_data', json.encode(response.data));
      } else {
        throw Exception(
            "Failed to fetch /me/ data: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      debugPrint("Error fetching medical center profile data: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء جلب البيانات")),
      );
    }
  }

  void _assignMeData(Map<String, dynamic> data) {
    // Expected structure: { "user": {...}, "role": { "role": "medical_center", "details": {...} } }
    _meData = data;
    try {
      // Assign common user fields.
      final user = data["user"] ?? {};
      _fullNameCtrl.text = user["full_name"] ?? '';
      _emailCtrl.text = user["email"] ?? '';
      _phoneCtrl.text = user["phone_number"] ?? '';

      // Process gender: if backend value is 'f' then display "انثى", otherwise "ذكر"
      final rawGender =
          (user["gender"]?.toString() ?? 'm').trim().toLowerCase();
      _selectedGender = (rawGender == 'f') ? 'انثى' : 'ذكر';
      debugPrint("Assigned gender: $_selectedGender");

      // Process profile image.
      final rawProfile = user["profile_image"]?.toString() ?? '';
      if (rawProfile.isNotEmpty) {
        // If the string already starts with http, use it; else prepend base URL.
        _currentProfileImageUrl = rawProfile.startsWith("http")
            ? rawProfile
            : "https://racheeta.pythonanywhere.com$rawProfile";
      } else {
        _currentProfileImageUrl = null;
      }

      // Process GPS location.
      final rawGps = user["gps_location"]?.toString();
      if (rawGps != null && rawGps.isNotEmpty) {
        final parts = rawGps.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            _location = LatLng(lat, lng);
          }
        }
      }

      // Assign medical center–specific fields.
      final details = data["role"]?["details"] ?? {};
      _centerNameCtrl.text = details["center_name"] ?? '';
      _directorNameCtrl.text = details["director_name"] ?? '';
      _bioCtrl.text = details["bio"] ?? '';
      _availabilityCtrl.text = details["availability_time"] ?? '';
      _addressCtrl.text = details["address"] ?? '';

      // Process address for dropdowns.
      final rawAddress = details["address"]?.toString() ?? '';
      if (rawAddress.contains('-')) {
        final parts = rawAddress.split('-');
        if (parts.length >= 2) {
          _selectedCity = parts[0].trim();
          _selectedDistrict = parts[1].trim();
        }
      }
    } catch (e) {
      debugPrint("Error assigning medical center data: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        // Check file size (2MB limit)
        final size = await imageFile.length();
        if (size > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("حجم الصورة أكبر من 2 ميجابايت. اختر صورة أصغر.")),
          );
          return;
        }
        setState(() {
          _profileImage = imageFile;
        });
        if (_meData != null && _meData!["user"]?["id"] != null) {
          await _uploadProfileImage(imageFile, _meData!["user"]["id"]);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final size = await imageFile.length();
        if (size > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("حجم الصورة أكبر من 2 ميجابايت. اختر صورة أصغر.")),
          );
          return;
        }
        setState(() {
          _profileImage = imageFile;
        });
        if (_meData != null && _meData!["user"]?["id"] != null) {
          await _uploadProfileImage(imageFile, _meData!["user"]["id"]);
        }
      }
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  Future<bool> _uploadProfileImage(File imageFile, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token") ?? '';
      if (token.isEmpty) return false;
      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";

      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        "profile_image":
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await dio.patch(
          "https://racheeta.pythonanywhere.com/users/$userId/",
          data: formData);
      if (response.statusCode == 200) {
        final newUrl = response.data["profile_image"]?.toString() ?? '';
        setState(() {
          _currentProfileImageUrl = newUrl.startsWith("http")
              ? newUrl
              : "https://racheeta.pythonanywhere.com$newUrl";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث الصورة بنجاح!")),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error uploading profile image: $e");
      return false;
    }
  }

  Future<void> _saveProfile() async {
    if (_meData == null) return;
    final userId = _meData!["user"]?["id"];
    final centerId = _meData!["role"]?["details"]?["id"];
    if (userId == null || centerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("لا يمكن حفظ التغييرات: معرف المستخدم أو المركز مفقود.")),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token") ?? '';
      if (token.isEmpty) throw Exception("No token found");
      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";

      // Build user payload.
      final userPayload = {
        "full_name": _fullNameCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "phone_number": _phoneCtrl.text.trim(),
        "gender": _selectedGender == 'انثى' ? 'f' : 'm',
      };

      // Build medical center payload.
      final centerPayload = {
        "center_name": _centerNameCtrl.text.trim(),
        "director_name": _directorNameCtrl.text.trim(),
        "bio": _bioCtrl.text.trim(),
        "availability_time": _availabilityCtrl.text.trim(),
        "address": "$_selectedCity - $_selectedDistrict",
      };

      final userResp = await dio.patch(
          "https://racheeta.pythonanywhere.com/users/$userId/",
          data: userPayload);
      debugPrint("User update response: ${userResp.data}");

      final centerResp = await dio.patch(
          "https://racheeta.pythonanywhere.com/medical_centers/$centerId/",
          data: centerPayload);
      debugPrint("Medical center update response: ${centerResp.data}");

      await _loadProfileData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حفظ التغييرات بنجاح!")),
      );
    } catch (e) {
      debugPrint("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ عند حفظ البيانات")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _saveProfile();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _centerNameCtrl.dispose();
    _directorNameCtrl.dispose();
    _bioCtrl.dispose();
    _availabilityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // --- UI Building ---

  Widget _buildTopProfileCard() {
    final user = _meData!["user"] ?? {};
    final centerDetails = _meData!["role"]?["details"] ?? {};

    final fullName = user["full_name"] ?? "اسم غير متوفر";
    final centerName = centerDetails["center_name"] ?? "";
    final directorName = centerDetails["director_name"] ?? "";
    final bio = centerDetails["bio"] ?? "لا يوجد وصف";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!) as ImageProvider
                : (_currentProfileImageUrl != null &&
                        _currentProfileImageUrl!.isNotEmpty)
                    ? NetworkImage(_currentProfileImageUrl!)
                    : const AssetImage("assets/images/default_profile.png")
                        as ImageProvider,
          ),
          const SizedBox(height: 16),
          if (_isEditMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('اختيار من المعرض'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('التقاط صورة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "$centerName - $directorName",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildTextField('الاسم الكامل', _fullNameCtrl, enabled: _isEditMode),
          const SizedBox(height: 12),
          _buildDropdownField(
            'الجنس',
            _selectedGender,
            _genderOptions,
            (val) => setState(() => _selectedGender = val),
            enabled: _isEditMode,
          ),
          const SizedBox(height: 12),
          _buildTextField('البريد الإلكتروني', _emailCtrl,
              keyboardType: TextInputType.emailAddress, enabled: _isEditMode),
          const SizedBox(height: 12),
          _buildTextField('رقم الهاتف', _phoneCtrl,
              keyboardType: TextInputType.phone, enabled: _isEditMode),
        ],
      ),
    );
  }

  Widget _buildCenterInfoTab() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildTextField('اسم المركز', _centerNameCtrl, enabled: _isEditMode),
          const SizedBox(height: 12),
          _buildTextField('اسم المدير', _directorNameCtrl,
              enabled: _isEditMode),
          const SizedBox(height: 12),
          _buildTextField('نبذة عن المركز', _bioCtrl,
              maxLines: 3, enabled: _isEditMode),
          const SizedBox(height: 12),
          _buildTextField('أوقات التوفر', _availabilityCtrl,
              enabled: _isEditMode),
        ],
      ),
    );
  }

  Widget _buildContactInfoTab() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildDistrictSelection(),
          const SizedBox(height: 12),
          _buildTextField('العنوان (نص كامل)', _addressCtrl,
              maxLines: 2, enabled: _isEditMode),
          const SizedBox(height: 12),
          _buildLocationMap(),
        ],
      ),
    );
  }

  // Reusable text field builder
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
        ),
      ],
    );
  }

  // Reusable dropdown builder
  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged, {
    bool enabled = true,
  }) {
    final dropdownValue = items.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey[100],
          ),
          child: DropdownButton<String>(
            value: dropdownValue,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: !enabled
                ? null
                : (String? newVal) {
                    if (newVal != null) onChanged(newVal);
                  },
            items: items.map<DropdownMenuItem<String>>((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // District (city + district) dropdown builder.
  Widget _buildDistrictSelection() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: _selectedCity.isNotEmpty ? _selectedCity : 'بغداد',
            decoration: const InputDecoration(
              labelText: 'المدينة',
              border: OutlineInputBorder(),
            ),
            items: const ['بغداد'].map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: !_isEditMode
                ? null
                : (val) {
                    if (val != null) setState(() => _selectedCity = val);
                  },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            value: districts.contains(_selectedDistrict)
                ? _selectedDistrict
                : districts.first,
            decoration: const InputDecoration(
              labelText: 'الحي',
              border: OutlineInputBorder(),
            ),
            items: districts.map((d) {
              return DropdownMenuItem(value: d, child: Text(d));
            }).toList(),
            onChanged: !_isEditMode
                ? null
                : (val) {
                    if (val != null) setState(() => _selectedDistrict = val);
                  },
          ),
        ),
      ],
    );
  }

  // Map preview builder
  Widget _buildLocationMap() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _location ?? _defaultLocation,
          initialZoom: 13.0,
          onMapReady: () {
            if (_location != null) {
              _mapController.move(_location!, 13.0);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (_location != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _location!,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_meData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("ملف المركز الطبي")),
        body: const Center(child: Text("لا توجد بيانات لعرضها.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("ملف المركز الطبي"),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopProfileCard(),
            const SizedBox(height: 20),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "المعلومات الأساسية"),
                  Tab(text: "معلومات المركز"),
                  Tab(text: "معلومات التواصل"),
                ],
              ),
            ),
            Container(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(),
                  _buildCenterInfoTab(),
                  _buildContactInfoTab(),
                ],
              ),
            ),
            if (_isEditMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _saveProfile();
                    setState(() {
                      _isEditMode = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "احفظ التعديلات",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
