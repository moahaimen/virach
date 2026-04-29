import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common_screens/signup_login/health_service_registration/city_district_selection_page.dart';
import '../../../jobposting/screens/alljob_postings_screen.dart';
import '../../../jobseeker/models/jobseeker_model.dart';
import '../../../jobseeker/providers/jobseeker_provider.dart';

class JobSeekerRegistrationProfileFormPage extends StatefulWidget {
  final Map<String, String>?
      userCredentials; // contains phoneNumber and optionally uid/email

  const JobSeekerRegistrationProfileFormPage({
    Key? key,
    this.userCredentials,
  }) : super(key: key);

  @override
  State<JobSeekerRegistrationProfileFormPage> createState() =>
      _JobSeekerRegistrationProfileFormPageState();
}

class _JobSeekerRegistrationProfileFormPageState
    extends State<JobSeekerRegistrationProfileFormPage> {
  // Stepper state
  int _currentStep = 0;
  bool _isLoading = false;

  // Determine registration type: phone vs Gmail
  bool _isPhoneRegistration = false;
  bool _isGmailRegistration = false;

  // Two forms for validation
  final GlobalKey<FormState> _formKeyStep1 =
      GlobalKey<FormState>(); // Basic user
  final GlobalKey<FormState> _formKeyStep2 =
      GlobalKey<FormState>(); // JobSeeker info

  // Basic user fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Step 2: Jobseeker info (using dropdowns for specialty, degree, district)
  String _selectedGender = "m";
  bool _wantsProfessionalCourses = false;
  String? _gpsLocation;
  String _selectedSpecialty = 'Other';
  String _selectedDegree = 'اخرى';
  String _selectedDistrict = '';

  // Dropdown options
  final List<String> specialties = [
    'ممرض',
    'معالج طبيعي',
    'طبيب',
    'مهندس',
    'مبرمج حاسبات',
    'اخرى',
    'Other'
  ];
  final List<String> degrees = [
    'اخرى',
    'اعدادية',
    'دبلوم',
    'بكلرويوس',
    'ماستر ',
    'دكتوراة'
  ];

  // Images
  File? _profileImage;
  File? _degreeImageFile;
  bool isLoading = false;
  // Password strength
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();

    // Try to get phone from either 'phoneNumber' or (for phone auth) from 'email'
    final phoneFromAuth = widget.userCredentials?['phoneNumber'] ??
        widget.userCredentials?['email'];
    final uidFromAuth = widget.userCredentials?['uid'];
    final emailFromAuth = widget.userCredentials?['email'];

    // If we detect a phone number (which should start with '+964'), mark as phone registration
    if (phoneFromAuth != null &&
        phoneFromAuth.isNotEmpty &&
        phoneFromAuth.startsWith('+964')) {
      _isPhoneRegistration = true;
      _phoneNumberController.text = phoneFromAuth;
      debugPrint("Phone-based registration detected: $phoneFromAuth");
    }

    // For Gmail-based registration: if uid and a proper email exist
    if (uidFromAuth != null &&
        uidFromAuth.isNotEmpty &&
        emailFromAuth != null &&
        emailFromAuth.contains('@')) {
      _isGmailRegistration = true;
      debugPrint("Gmail-based registration detected: $emailFromAuth");
    }

    _passwordController.addListener(() {
      setState(() {
        _passwordStrength =
            _calculatePasswordStrength(_passwordController.text);
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (RegExp(r'[A-Za-z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;
    return strength / 4;
  }

  String _getPasswordStrengthLabel(double strength) {
    if (strength <= 0.25)
      return "Weak";
    else if (strength <= 0.5)
      return "Medium";
    else if (strength <= 0.75)
      return "Strong";
    else
      return "Very Strong";
  }

  // Image picking functions
  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _takeProfilePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _pickDegreeImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _degreeImageFile = File(pickedFile.path));
    }
  }

  Future<void> _takeDegreePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _degreeImageFile = File(pickedFile.path));
    }
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    final userConsent = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Allow Location Access"),
          content: const Text(
              "The app needs to access your location to proceed. Do you allow?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Deny"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Allow"),
            ),
          ],
        );
      },
    );
    if (userConsent == false) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enable location services to proceed.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Location permission denied. Please allow access.")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Location access is permanently denied. Please enable it in settings.")),
      );
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        // Store the location string (latitude,longitude)
        // ADDED: Using _gpsLocation variable for later use.
        // Also, you might want to store it in shared prefs after registration.
        // For now, we store it locally.
        // _gpsLocation is nullable and used later.
        // You could also store it in SharedPreferences here if desired.
        _gpsLocation = "${position.latitude},${position.longitude}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Location: ${position.latitude}, ${position.longitude}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch location.")),
      );
    }
  }

  Future<void> _uploadProfileImage(File imageFile, String userId) async {
    // Your existing function to upload profile image (omitted for brevity)
  }

  Future<void> _uploadDegreeImage(File imageFile, String jobSeekerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      if (token == null) {
        debugPrint("No token found - can't upload degree image");
        return;
      }
      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";
      final formData = FormData.fromMap({
        "degree_image": await MultipartFile.fromFile(imageFile.path),
      });
      final response = await dio.patch(
        "https://racheeta.pythonanywhere.com/jobseekers/$jobSeekerId/",
        data: formData,
      );
      if (response.statusCode == 200) {
        debugPrint("Degree image uploaded: ${response.data}");
      } else {
        debugPrint(
          "Failed to upload degree image: ${response.statusCode} => ${response.data}",
        );
      }
    } catch (e) {
      debugPrint("Error uploading degree image: $e");
    }
  }

  bool _isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^\+964\d{10}$');
    return regex.hasMatch(phone);
  }

  /// Generates a unique dummy email based on the provided phone number.
  String generateUniqueDummyEmail(String phone) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomInt =
        Random().nextInt(1000000); // random number between 0 and 999999
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    return "phoneuser_${cleanPhone}_$timestamp$randomInt@dummy.com";
  }

  /// ================= MAIN SAVE PROFILE ================///

// ────────────────────────────────────────────────────────────
// JobSeekerRegistrationProfileFormPage.dart
// Replace the ENTIRE _saveProfile() method with this version
// ────────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────
//  JobSeekerRegistrationProfileFormPage.dart
//  REPLACE the entire _saveProfile() method with this version
// ─────────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1) Build the user payload
    final String payloadEmail = _emailController.text.trim();
    final String payloadPassword = _passwordController.text.trim();

    final Map<String, dynamic> userMap = {
      "email": payloadEmail,
      "password": payloadPassword,
      "full_name": _fullNameController.text.trim(),
      "role": "patient",
      "gps_location": _gpsLocation ?? "37.4219983,-122.084",
      "phone_number": "+964${_phoneNumberController.text.trim()}",
      "gender": _selectedGender,
      "firebase_uid": null,
    };

    debugPrint("User payload: $userMap");

    // 2) Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider =
          Provider.of<JobSeekerRetroDisplayGetProvider>(context, listen: false);

      // 3) Create the user
      final Map<String, dynamic> userResp =
          await provider.saveUserProfile(userMap) as Map<String, dynamic>;
      final String userId = userResp["id"];
      debugPrint("New user ID: $userId");

      // 4) Log‑in with SAME password
      final String? token =
          await provider.authenticateUser(payloadEmail, payloadPassword);
      if (token == null) throw Exception("Authentication failed.");

      // 5) Create the JobSeeker (JSON only)
      final JobSeekerModel? jobSeeker = await provider.createJobSeeker(
        userId: userId,
        specialty: _selectedSpecialty,
        degree: _selectedDegree,
        address: _selectedDistrict,
        gpsLocation: _gpsLocation ?? "33.3152 44.3661",
      );

      // 6) Upload degree image (if any)
      if (jobSeeker != null &&
          _degreeImageFile != null &&
          jobSeeker.id != null &&
          jobSeeker.id!.isNotEmpty) {
        await _uploadDegreeImage(_degreeImageFile!, jobSeeker.id!);
      }

      // 7) Persist EVERYTHING in SharedPreferences
      await prefs.clear(); // wipe old session
      await prefs.setString("access_token", token);
      await prefs.setString("user_id", userId);
      await prefs.setBool("isRegistered", true);

      await prefs.setString("full_name", _fullNameController.text.trim());
      await prefs.setString("email", payloadEmail);
      await prefs.setString(
          "phone_number", "+964${_phoneNumberController.text.trim()}");
      await prefs.setString("gps_location", _gpsLocation ?? "33.3152 44.3661");
      await prefs.setString("gender", _selectedGender);

      await prefs.setString("specialty", _selectedSpecialty);
      await prefs.setString("degree", _selectedDegree);
      await prefs.setString("address", _selectedDistrict);

      if (jobSeeker != null && jobSeeker.id != null) {
        await prefs.setString("jobseeker_id", jobSeeker.id!);
        await prefs.setString("degree_image",
            jobSeeker.degreeImage ?? ""); // empty string if null
      }

      // 8) Close loader & navigate
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AllJobPostingsPage(userData: {
            "full_name": _fullNameController.text.trim(),
            "email": payloadEmail,
            "phone_number": "+964${_phoneNumberController.text.trim()}",
            "gps_location": _gpsLocation ?? "33.3152 44.3661",
            "gender": _selectedGender,
            "degree": _selectedDegree,
            "specialty": _selectedSpecialty,
            "address": _selectedDistrict,
          }),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint("❌ _saveProfile error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الحفظ: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اكمل ملفك الشخصي"),
        centerTitle: true,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () async {
          if (_currentStep == 0) {
            if (_profileImage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("الرجاء اختيار صورة شخصية")),
              );
              return;
            }
            setState(() => _currentStep++);
          } else if (_currentStep == 1) {
            if (_formKeyStep1.currentState?.validate() ?? false) {
              setState(() => _currentStep++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("رجاء املىء الحقول المطلوبة")),
              );
            }
          } else if (_currentStep == 2) {
            if (_formKeyStep2.currentState?.validate() ?? false) {
              await _saveProfile();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("رجاء املىء الحقول المطلوبة")),
              );
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          // Step 0: Profile Image
          Step(
            title: const Text("الصورة"),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
            content: Column(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/icons/doctor_icon.png')
                            as ImageProvider,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _takeProfilePhoto,
                      child: const Text("التقط صورة"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _pickProfileImage,
                      child: const Text("اختر صورة"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Step 1: Basic Info (Only show email/pwd if not phone-based)
          Step(
            title: const Text("المعلومات"),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
            content: Form(
              key: _formKeyStep1,
              child: Column(
                children: [
                  if (!_isPhoneRegistration && !_isGmailRegistration)
                    Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return "ادخل ايميل مناسب";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "كلمة السر",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "كلمة السر ضرورية";
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "قوة كلمة السر: ${_getPasswordStrengthLabel(_passwordStrength)}",
                            style: TextStyle(
                              color: _passwordStrength <= 0.25
                                  ? Colors.red
                                  : _passwordStrength <= 0.5
                                      ? Colors.orange
                                      : _passwordStrength <= 0.75
                                          ? Colors.yellow
                                          : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: "الاسم الكامل مطلوب",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الاسم الكامل مطلوب";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Gender toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        isSelected: [
                          _selectedGender == "m",
                          _selectedGender == "f",
                        ],
                        onPressed: (index) {
                          setState(() {
                            _selectedGender = index == 0 ? "m" : "f";
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: Colors.blue,
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          minHeight: 50,
                        ),
                        children: const [
                          Text("ذكر", style: TextStyle(fontSize: 16)),
                          Text("أنثى", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Step 2: Jobseeker Info
          Step(
            title: const Text("اكمال التسجيل"),
            isActive: _currentStep >= 2,
            state: StepState.editing,
            content: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKeyStep2,
              child: Column(
                children: [
                  if (!_isPhoneRegistration)
                    TextFormField(
                      textAlign: TextAlign.right,
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        labelText: 'رقم المحمول',
                        prefixText: '+964 ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                      ),
                      validator: (value) {
                        if (value == null || value.length != 10) {
                          return "يرجى إدخال رقم مكون من 10 أرقام بدون رمز البلد";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        String cleaned =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleaned.startsWith('0')) {
                          cleaned = cleaned.substring(1);
                        }
                        if (cleaned.length > 10) {
                          cleaned = cleaned.substring(0, 10);
                        }
                        _phoneNumberController.value = TextEditingValue(
                          text: cleaned,
                          selection:
                              TextSelection.collapsed(offset: cleaned.length),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    items: specialties.map((spec) {
                      return DropdownMenuItem(
                        value: spec,
                        child: Text(spec),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSpecialty = val!),
                    decoration: const InputDecoration(
                      labelText: "التخصص",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يرجى اختيار التخصص";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedDegree,
                    items: degrees.map((deg) {
                      return DropdownMenuItem(
                        value: deg,
                        child: Text(deg),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDegree = val!),
                    decoration: const InputDecoration(
                      labelText: "الشهادة (Degree)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يرجى اختيار الشهادة";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CityDistrictSelection(
                    selectedCity: 'بغداد',
                    selectedDistrict: _selectedDistrict,
                    onCityChanged: (city) {},
                    onDistrictChanged: (dist) {
                      setState(() => _selectedDistrict = dist);
                    },
                  ),
                  if (_selectedDistrict.isEmpty)
                    const Text("يرجى اختيار الحي",
                        style: TextStyle(color: Colors.red, fontSize: 14)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickDegreeImage,
                          child: const Text("اختر صورة الشهادة"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _takeDegreePhoto,
                          child: const Text("التقط صورة للشهادة"),
                        ),
                      ),
                    ],
                  ),
                  if (_degreeImageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.file(
                        _degreeImageFile!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text("هل ترغب بكورسات احترافية؟"),
                      const SizedBox(width: 10),
                      Switch(
                        value: _wantsProfessionalCourses,
                        onChanged: (val) {
                          setState(() {
                            _wantsProfessionalCourses = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _getCurrentLocation(context),
                    child: const Text("حدد موقعك بالGPS"),
                  ),
                  if (_gpsLocation != null)
                    Text(
                      "موقعك الحالي: $_gpsLocation",
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
