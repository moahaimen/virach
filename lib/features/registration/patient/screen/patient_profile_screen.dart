import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/medicals/bagdhad_districts_list.dart';
import '../../../../widgets/gps_maps/location_selector.dart';
import '../../../doctors/models/user_model.dart';
import '../../../jobseeker/models/jobseeker_model.dart';
import '../../../jobseeker/providers/jobseeker_provider.dart';


class JobSeekerJobseekerSideProfilePage extends StatefulWidget {
  const JobSeekerJobseekerSideProfilePage({Key? key}) : super(key: key);

  @override
  _JobSeekerJobseekerSideProfilePageState createState() =>
      _JobSeekerJobseekerSideProfilePageState();
}

class _JobSeekerJobseekerSideProfilePageState
    extends State<JobSeekerJobseekerSideProfilePage> {
  // User fields
  String profileImageUrl = ""; // URL from server for profile image
  String fullName = "";
  String email = "";
  String degree = "";
  String address = "";
  String phoneNumber = "";
  String location = "";
  String gender = "Select Gender";
  bool isLoading = true;
  bool isEditing = false;
  String selectedCity = "بغداد";
  String selectedDistrict = "الأعظمية";
  bool _isLoading = true;
  late Map<String, String> _userData;
  // Jobseeker-specific fields
  String degreeImageUrl = ""; // URL from server for degree image
  // Dropdown selections for specialty and degree.
  String selectedSpecialty = "";
  String selectedDegree = "";

  LatLng? userLatLng;
  final MapController _mapController = MapController();

  // Address is managed via a controller.
  final TextEditingController _addressController = TextEditingController();

  // Options for dropdowns.
  final List<String> specialtiesOptions = [
    'ممرض',
    'معالج طبيعي',
    'طبيب',
    'مهندس',
    'مبرمج حاسبات',
    'اخرى',
    'Other'
  ];
  final List<String> degreeOptions = [
    'اخرى',
    'اعدادية',
    'دبلوم',
    'بكالوريوس',
    'ماستر',
    'دكتوراة'
  ];

  // For images.
  File? _profileImage; // local profile image file
  File? _degreeImageFile; // local degree image file

  // Controllers for user fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = "";
  bool isOtpSent = false;
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    // _loadUserDataFromPrefs();
    _fetchUserProfile();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        if ((await imageFile.length()) > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "حجم الصورة أكبر من 2 ميجابايت. يرجى اختيار صورة أصغر.")),
          );
          return;
        }
        setState(() {
          _profileImage = imageFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking profile image: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        if ((await imageFile.length()) > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "حجم الصورة أكبر من 2 ميجابايت. يرجى اختيار صورة أصغر.")),
          );
          return;
        }
        setState(() {
          _profileImage = imageFile;
        });
      }
    } catch (e) {
      debugPrint("Error taking profile photo: $e");
    }
  }

  Future<void> _pickDegreeImage() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        if ((await imageFile.length()) > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "حجم الصورة أكبر من 2 ميجابايت. يرجى اختيار صورة أصغر.")),
          );
          return;
        }
        setState(() {
          _degreeImageFile = imageFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking degree image: $e");
    }
  }

  Future<void> _takeDegreePhoto() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        if ((await imageFile.length()) > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "حجم الصورة أكبر من 2 ميجابايت. يرجى اختيار صورة أصغر.")),
          );
          return;
        }
        setState(() {
          _degreeImageFile = imageFile;
        });
      }
    } catch (e) {
      debugPrint("Error taking degree photo: $e");
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs   = await SharedPreferences.getInstance();
      final userId  = prefs.getString('user_id');
      if (userId == null || userId.isEmpty) throw 'no user_id';

      // ── 1) fetch user (already present) ─────────────────────────────
      final provider = context.read<JobSeekerRetroDisplayGetProvider>();
      final UserModel? user = await provider.fetchUserById(userId);

      // ── 2) fetch job‑seeker linked to the same user ────────────────
      JobSeekerModel? js = await provider.fetchCurrentJobSeekerByUserID();

      // –––––––––  Map plain USER → screen/state –––––––––
      profileImageUrl = user?.profileImage ?? '';
      fullName  = user?.fullName     ?? '';
      email     = user?.email        ?? '';
      phoneNumber = user?.phoneNumber?? '';
      location  = user?.gpsLocation  ?? '';
      gender    = user?.gender       ?? gender;

      // –––––––––  Map JOB‑SEEKER → screen/state –––––––––
      if (js != null) {
        selectedSpecialty   = js.specialty ?? '';
        selectedDegree      = js.degree    ?? '';
        degreeImageUrl      = js.degreeImage ?? '';
        _addressController.text = js.address ?? '';
        // → also persist to SharedPreferences
        await prefs.setString('jobseeker_id', js.id ?? '');
        await prefs.setString('specialty',     selectedSpecialty);
        await prefs.setString('degree',        selectedDegree);
        await prefs.setString('address',       _addressController.text);
        if (degreeImageUrl.isNotEmpty) {
          await prefs.setString('degree_image_url', degreeImageUrl);
        }
      } else {
        debugPrint('ℹ️ No JobSeeker record for user $userId');
      }
      final locationStr = user?.gpsLocation;
      if (locationStr != null && locationStr.contains(',')) {
        final parts = locationStr.split(',');
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          userLatLng = LatLng(lat, lng);
        }
      }


      // controllers for plain‑user
      _nameController.text     = fullName;
      _emailController.text    = email;
      _phoneController.text    = phoneNumber;
      _locationController.text = location;

    } catch (e) {
      debugPrint('❌ _fetchUserProfile error → $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> _setCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("صلاحية الموقع مرفوضة")),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        userLatLng = LatLng(position.latitude, position.longitude);
        _locationController.text =
        '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
    }
  }


  /// UPDATE PROFILE: Update both user and jobseeker-specific fields.
  Future<void> _updateUserProfile() async {
    // 1) Client‐side validation
    bool isValid = true;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الاسم مطلوب"))
      );
      isValid = false;
    }
    final rawPhone = _phoneController.text.trim();
    final phoneNum = rawPhone.startsWith("+964")
        ? rawPhone.substring(4)
        : rawPhone;
    if (phoneNum.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phoneNum)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("رقم الهاتف يجب أن يكون مكونًا من 10 أرقام"))
      );
      isValid = false;
    }
    if (_emailController.text.trim().isEmpty ||
        !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
            .hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("البريد الإلكتروني غير صالح"))
      );
      isValid = false;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الموقع مطلوب"))
      );
      isValid = false;
    }
    // if (_addressController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("العنوان مطلوب"))
    //   );
    //   isValid = false;
    // }
    if (!isValid) return;

    setState(() => isLoading = true);

    try {
      final prefs       = await SharedPreferences.getInstance();
      final userId      = prefs.getString('user_id');
      final jobSeekerId = prefs.getString('jobseeker_id');
      final token       = prefs.getString('Login_access_token');
      if (userId == null || token == null) {
        throw Exception("Missing user_id or token");
      }

      // 2) JSON PATCH for user fields
      final dio = Dio();
      dio.options.headers['Authorization'] = 'JWT $token';
      dio.options.headers.remove('Content-Type');
      final userPayload = {
        "full_name":    _nameController.text.trim(),
        "email":        _emailController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "gps_location": _locationController.text.trim(),
        "gender":       gender,
      };

      final userResp = await dio.patch(
        'https://racheeta.pythonanywhere.com/users/$userId/',
        data: userPayload,
      );
      debugPrint("🛰️ /users PATCH status: ${userResp.statusCode}");
      debugPrint("🛰️ /users PATCH data:   ${userResp.data}");
      if (userResp.statusCode != 200) {
        throw Exception("User update failed: ${userResp.data}");
      }

      // 2a) Apply server‐returned user data
      final Map<String, dynamic> updatedUser = userResp.data;
      await prefs.setString('full_name',     updatedUser['full_name']);
      await prefs.setString('email',         updatedUser['email']);
      await prefs.setString('phone_number',  updatedUser['phone_number']);
      await prefs.setString('gps_location',  updatedUser['gps_location']);
      await prefs.setString('gender',        updatedUser['gender']);
      await prefs.setString('profile_image_url', updatedUser['profile_image']);

      setState(() {
        fullName        = updatedUser['full_name'];
        email           = updatedUser['email'];
        phoneNumber     = updatedUser['phone_number'];
        location        = updatedUser['gps_location'];
        gender          = updatedUser['gender'];
        profileImageUrl = updatedUser['profile_image'];
        _nameController.text     = fullName;
        _emailController.text    = email;
        _phoneController.text    = phoneNumber;
        _locationController.text = location;
      });

      // 3) Multipart upload for profile image
      if (_profileImage != null) {
        final form = FormData.fromMap({
          "profile_image": await MultipartFile.fromFile(
            _profileImage!.path,
            filename: _profileImage!.path.split('/').last,
          ),
        });
        final imgResp = await dio.patch(
          'https://racheeta.pythonanywhere.com/users/$userId/',
          data: form,
        );
        debugPrint("🛰️ /users image PATCH status: ${imgResp.statusCode}");
        debugPrint("🛰️ /users image PATCH data:   ${imgResp.data}");
        if (imgResp.statusCode == 200) {
          final String url = imgResp.data['profile_image'];
          await prefs.setString('profile_image_url', url);
          setState(() => profileImageUrl = url);
        }
      }

      // 4) JSON PATCH for jobseeker fields
      if (jobSeekerId != null && jobSeekerId.isNotEmpty) {
        final jsPayload = {
          "specialty": selectedSpecialty,
          "degree":    selectedDegree,
          "address":   _addressController.text.trim(),
        };
        final jsResp = await dio.patch(
          'https://racheeta.pythonanywhere.com/jobseekers/$jobSeekerId/',
          data: jsPayload,
        );
        debugPrint("🛰️ /jobseekers PATCH status: ${jsResp.statusCode}");
        debugPrint("🛰️ /jobseekers PATCH data:   ${jsResp.data}");
        if (jsResp.statusCode != 200) {
          throw Exception("Jobseeker update failed: ${jsResp.data}");
        }
        await prefs.setString('specialty', selectedSpecialty);
        await prefs.setString('degree',    selectedDegree);
        await prefs.setString('address',   jsPayload['address']!);

        // 5) Multipart upload for degree image
        if (_degreeImageFile != null) {
          final degForm = FormData.fromMap({
            "degree_image": await MultipartFile.fromFile(
              _degreeImageFile!.path,
              filename: _degreeImageFile!.path.split('/').last,
            ),
          });
          final degResp = await dio.patch(
            'https://racheeta.pythonanywhere.com/jobseekers/$jobSeekerId/',
            data: degForm,
          );
          debugPrint("🛰️ /jobseekers image PATCH status: ${degResp.statusCode}");
          debugPrint("🛰️ /jobseekers image PATCH data:   ${degResp.data}");
          if (degResp.statusCode == 200) {
            final String durl = degResp.data['degree_image'];
            await prefs.setString('degree_image_url', durl);
            setState(() => degreeImageUrl = durl);
          }
        }
      }

      // 6) Final UI commit
      setState(() {
        isEditing = false;
        isLoading = false;
        _addressController.text = address = _addressController.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم تحديث الملف الشخصي بنجاح"))
      );
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ فشل في تحديث الملف الشخصي: $e"))
      );
    }
  }

  /// Upload the profile image and return the URL from the server.
  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    debugPrint("<=== Starting Profile Image Upload ===>");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing.");
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";

      final formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.patch(
        "https://racheeta.pythonanywhere.com/users/$userId/",
        data: formData,
      );

      if (response.statusCode == 200) {
        final uploadedImageUrl = response.data['profile_image'];
        debugPrint("✅ Profile image uploaded successfully: $uploadedImageUrl");
        return uploadedImageUrl;
      } else {
        debugPrint(
            "❌ Failed to upload profile image: ${response.statusCode} - ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error during profile image upload: $e");
      return null;
    } finally {
      debugPrint("<=== Profile Image Upload Process Completed ===>");
    }
  }

  /// Upload the degree image and return the URL from the server.
  Future<String?> _uploadDegreeImage(File imageFile, String jobSeekerId) async {
    debugPrint("<=== Starting Degree Image Upload ===>");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing.");
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";

      final formData = FormData.fromMap({
        "degree_image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.patch(
        "https://racheeta.pythonanywhere.com/jobseekers/$jobSeekerId/",
        data: formData,
      );

      if (response.statusCode == 200) {
        final uploadedImageUrl = response.data['degree_image'];
        debugPrint("✅ Degree image uploaded successfully: $uploadedImageUrl");
        return uploadedImageUrl;
      } else {
        debugPrint(
            "❌ Failed to upload degree image: ${response.statusCode} - ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error during degree image upload: $e");
      return null;
    } finally {
      debugPrint("<=== Degree Image Upload Process Completed ===>");
    }
  }

  // Validators.1
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'الاسم مطلوب';
    if (value.length < 2) return 'الاسم يجب أن يكون أطول من حرفين';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'الايميل مطلوب';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'يرجى إدخال بريد إلكتروني صالح';
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الهاتف مطلوب';
    if (!RegExp(r'^\d{10}$').hasMatch(value))
      return 'رقم الهاتف يجب أن يكون مكونًا من 10 أرقام';
    return null;
  }

  String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) return 'العنوان مطلوب';
    return null;
  }

  /// A unified editable tile widget.
  Widget _buildEditableTile({
    required IconData icon,
    required String label, // e.g., "الاسم", "رقم الهاتف", or "الايميل"
    required TextEditingController controller,
    required bool enabled,
    FormFieldValidator<String>? validator,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.1),
        child: Icon(icon, color: Colors.orange),
      ),
      title: enabled
          ? TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        validator: validator,
      )
          : Text(
        controller.text.isNotEmpty ? controller.text : "غير محدد",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        label,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "الملف الشخصي",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                onPressed: isEditing
                    ? _updateUserProfile
                    : () => setState(() => isEditing = true),
              ),
              GestureDetector(
                onTap: isEditing
                    ? _updateUserProfile
                    : () => setState(() => isEditing = true),
                child: Text(
                  isEditing ? "حفظ" : "تعديل",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Profile image section.
            CircleAvatar(
              radius: 80,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : const AssetImage('assets/icons/patient.png')
              as ImageProvider,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: const Text("التقط صورة"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("اختر صورة من المعرض"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // User Details Card.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildEditableTile(
                        icon: Icons.person,
                        label: "الاسم",
                        controller: _nameController,
                        enabled: isEditing,
                        validator: validateName,
                      ),
                      const Divider(color: Colors.grey),
                      _buildEditableTile(
                        icon: Icons.phone,
                        label: "رقم الهاتف",
                        controller: _phoneController,
                        enabled: isEditing,
                        validator: validatePhoneNumber,
                      ),
                      const Divider(color: Colors.grey),
                      _buildEditableTile(
                        icon: Icons.email,
                        label: "الايميل",
                        controller: _emailController,
                        enabled: isEditing,
                        validator: validateEmail,
                      ),
                      const Divider(color: Colors.grey),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.wc, color: Colors.blue),
                        ),
                        title: DropdownButton<String>(
                          value: gender,
                          items: const [
                            DropdownMenuItem(
                                value: "Select Gender",
                                child: Text("اختر الجنس")),
                            DropdownMenuItem(
                                value: "m", child: Text("ذكر")),
                            DropdownMenuItem(
                                value: "f", child: Text("انثى")),
                          ],
                          onChanged: isEditing
                              ? (value) {
                            setState(() {
                              gender = value!;
                            });
                          }
                              : null,
                        ),
                        subtitle: const Text(
                          "الجنس",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (userLatLng != null)
                        LocationSelectorMap(
                          initialLocation: userLatLng!,
                          onLocationChanged: (LatLng newLocation) {
                            setState(() {
                              userLatLng = newLocation;
                              _locationController.text =
                              '${newLocation.latitude}, ${newLocation.longitude}';
                            });
                          },
                        ),

                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('اذا اردت ان تبحث عن وظيفة عليك ملئ الحقول التالية:'),
            const SizedBox(height: 10),

            // JobSeeker Additional Info Card.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Specialty Dropdown.
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          child:
                          const Icon(Icons.star, color: Colors.green),
                        ),
                        title: isEditing
                            ? DropdownButtonFormField<String>(
                          value: specialtiesOptions
                              .contains(selectedSpecialty)
                              ? selectedSpecialty
                              : specialtiesOptions.first,
                          items: specialtiesOptions.map((spec) {
                            return DropdownMenuItem(
                              value: spec,
                              child: Text(spec),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSpecialty = val!;
                            });
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none),
                        )
                            : Text(
                          selectedSpecialty.isNotEmpty
                              ? selectedSpecialty
                              : "غير محدد",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "التخصص",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      // Degree Dropdown.
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          child: const Icon(Icons.school,
                              color: Colors.orange),
                        ),
                        title: isEditing
                            ? DropdownButtonFormField<String>(
                          value:
                          degreeOptions.contains(selectedDegree)
                              ? selectedDegree
                              : degreeOptions.first,
                          items: degreeOptions.map((deg) {
                            return DropdownMenuItem(
                              value: deg,
                              child: Text(deg),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedDegree = val!;
                            });
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none),
                        )
                            : Text(
                          selectedDegree.isNotEmpty
                              ? selectedDegree
                              : "غير محدد",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "الشهادة",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      // Address Field using city & district dropdowns.
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          child: const Icon(Icons.location_city,
                              color: Colors.purple),
                        ),
                        title: isEditing
                            ? Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // City Dropdown.
                            DropdownButtonFormField<String>(
                              value: selectedCity,
                              items: ['بغداد'].map((city) {
                                return DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: (newCity) {
                                setState(() {
                                  selectedCity = newCity!;
                                  _addressController.text =
                                  "$selectedCity, $selectedDistrict";
                                });
                              },
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                            ),
                            // District Dropdown.
                            DropdownButtonFormField<String>(
                              value: selectedDistrict,
                              items: districts.map((dist) {
                                return DropdownMenuItem(
                                  value: dist,
                                  child: Text(dist),
                                );
                              }).toList(),
                              onChanged: (newDistrict) {
                                setState(() {
                                  selectedDistrict = newDistrict!;
                                  _addressController.text =
                                  "$selectedCity, $selectedDistrict";
                                });
                              },
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                            ),
                          ],
                        )
                            : Text(
                          _addressController.text.isNotEmpty
                              ? _addressController.text
                              : "غير محدد",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "العنوان",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      // Degree Image Section.
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          child:
                          const Icon(Icons.image, color: Colors.red),
                        ),
                        title: isEditing
                            ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _takeDegreePhoto,
                                child: const Text("📸 التقط صورة"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _pickDegreeImage,
                                child: const Text("📂 اختر صورة"),
                              ),
                            ),
                          ],
                        )
                            : degreeImageUrl.isNotEmpty
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(8),
                          child: Image.network(
                            degreeImageUrl,
                            height: 180,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return const Text(
                                  "⚠️ صورة غير متوفرة");
                            },
                          ),
                        )
                            : const Text("⚠️ لا توجد صورة للشهادة"),
                        subtitle: const Text(
                          "صورة الشهادة",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Update Profile Button.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _updateUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "تحديث الملف الشخصي",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying/editing the degree field in a similar style.
class ProfileTile extends StatelessWidget {
  final String degree; // The degree value.
  final bool isEditing;
  final TextEditingController? controller;

  const ProfileTile({
    Key? key,
    required this.degree,
    this.isEditing = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.1),
        child: const Icon(Icons.school, color: Colors.orange),
      ),
      title: isEditing
          ? TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "أدخل الشهادة",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        validator: validateDegree,
      )
          : Text(
        degree.isNotEmpty ? degree : "لا توجد شهادة",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        "الشهادة",
        style: TextStyle(
            color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  static String? validateDegree(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "يجب إدخال الشهادة";
    }
    return null;
  }
}
