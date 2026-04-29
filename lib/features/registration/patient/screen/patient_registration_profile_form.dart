import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- For inputFormatters
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../token_provider.dart';
import '../../../screens/home_screen.dart';
import '../provider/patient_registration_provider.dart';

class PatientRegistrationProfileFormPage extends StatefulWidget {
  final Map<String, String>? userCredentials;

  const PatientRegistrationProfileFormPage({
    Key? key,
    this.userCredentials,
  }) : super(key: key);

  @override
  _PatientRegistrationProfileFormPageState createState() =>
      _PatientRegistrationProfileFormPageState();
}

class _PatientRegistrationProfileFormPageState
    extends State<PatientRegistrationProfileFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String? _fcmToken;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? _gpsLocation;
  File? _profileImage;
  bool _isLoading = false;
  bool _isPhoneRegistration = false;
  String? _selectedGender = "m";
  bool _isGmailRegistration = false;
  double _passwordStrength = 0.0;


  @override
  void initState() {
    super.initState();

    // Existing code...
    if (widget.userCredentials != null) {
      final creds = widget.userCredentials!;
      _isGmailRegistration = creds['uid'] != null;
      _isPhoneRegistration = creds['phone'] != null;

      if (_isGmailRegistration) {
        _emailController.text = creds['email'] ?? '';
      }
      if (_isPhoneRegistration) {
        final raw = creds['phone']!.replaceFirst('+964', '');
        _phoneNumberController.text = raw;
      }
    }

    // 🔥 Fetch FCM Token
    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint("📲 FCM Token: $token");
      setState(() {
        _fcmToken = token;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _passwordStrength = calculatePasswordStrength(_passwordController.text);
      });
    });
  }
  void _initializeFCM() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("📲 Got FCM Token: $fcmToken");

      // Add to userCredentials map if not null
      if (fcmToken != null) {
        setState(() {
          widget.userCredentials?.putIfAbsent('fcm', () => fcmToken);
        });
      }
    } catch (e) {
      debugPrint("❌ Failed to get FCM token: $e");
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    int strength = 0;
    if (password.length >= 6) strength++; // Length
    if (RegExp(r'[A-Za-z]').hasMatch(password)) strength++; // Letters
    if (RegExp(r'\d').hasMatch(password)) strength++; // Numbers
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++; // Special chars

    // Normalize to a range of 0.0 to 1.0
    return strength / 4;
  }

  String getPasswordStrengthLabel(double strength) {
    if (strength <= 0.25) {
      return "Weak";
    } else if (strength <= 0.5) {
      return "Medium";
    } else if (strength <= 0.75) {
      return "Strong";
    } else {
      return "Very Strong";
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Show a confirmation dialog before requesting location
    final bool userConsent = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Allow Location Access"),
          content: const Text(
              "The app needs to access your location to proceed. Do you allow?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User denied
              child: const Text("Deny"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User accepted
              child: const Text("Allow"),
            ),
          ],
        );
      },
    );

    // If user denies permission, return early
    if (!userConsent) {
      print("User denied location access.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("الدخول للموقع لم يتم السماح به من قبل المستخدم")),
      );
      return;
    }

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء تفعيل خدمة الموقع من الجها.")),
      );
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("تم رفض إذن الوصول إلى الموقع. الرجاء السماح بالوصول.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "تم رفض إذن الوصول إلى الموقع. الرجاء السماح بالوصول من الاعدادات")),
      );
      return;
    }

    // Fetch current location
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _gpsLocation = "${position.latitude},${position.longitude}";
      print("Fetched location: $_gpsLocation");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم الحصول على الموقع $_gpsLocation")),
      );
      setState(() {}); // Refresh the UI to show the updated location
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الحصول على الموقع ")),
      );
    }
  }

  Future<void> _uploadProfileImage(File imageFile, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      if (token == null) {
        debugPrint("No token found - can't upload image");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";

      // Build the form data with just the image
      final formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(imageFile.path),
      });

      // PATCH the user record with the new profile image
      final response = await dio.patch(
        "https://racheeta.pythonanywhere.com/users/$userId/",
        data: formData,
      );

      if (response.statusCode == 200) {
        debugPrint("Image uploaded successfully: ${response.data}");
      } else {
        debugPrint(
            "Failed to upload image: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
  }
// 🔵 Save user info after registration
  Future<void> saveUserInfoLocally(Map<String, dynamic> user, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('access_token', token);
    await prefs.setString('Login_access_token', token);
    await prefs.setBool('isRegistered', true);
    await prefs.setString('user_id', user['id'].toString());
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('full_name', user['full_name'] ?? '');
    await prefs.setString('role', user['role'] ?? '');
    await prefs.setString('phone_number', user['phone_number'] ?? '');
    await prefs.setString('gps_location', user['gps_location'] ?? '');
    await prefs.setString('gender', user['gender'] ?? '');
    await prefs.setString('profile_image', user['profile_image'] ?? '');
    await prefs.setString('firebase_uid', user['firebase_uid'] ?? '');
    await prefs.setString('fcm', user['fcm'] ?? '');

    debugPrint('💾 User info saved locally in SharedPreferences');
  }

// 🔵 Load user info when needed (example: for profile page)
  Future<Map<String, dynamic>> loadUserInfoLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final userInfo = {
      'access_token': prefs.getString('access_token') ?? '',
      'user_id': prefs.getString('user_id') ?? '',
      'email': prefs.getString('email') ?? '',
      'full_name': prefs.getString('full_name') ?? '',
      'role': prefs.getString('role') ?? '',
      'phone_number': prefs.getString('phone_number') ?? '',
      'gps_location': prefs.getString('gps_location') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'profile_image': prefs.getString('profile_image') ?? '',
      'firebase_uid': prefs.getString('firebase_uid') ?? '',
      'fcm': prefs.getString('fcm') ?? '',
    };

    debugPrint('📖 Loaded user info: $userInfo');
    return userInfo;
  }

  Future<void> _saveProfile() async {
    final bool isPhoneRegistration = widget.userCredentials?['phone'] != null;
    final bool isGmailRegistration = widget.userCredentials?['email'] != null && widget.userCredentials?['uid'] != null;
    final bool isFirebaseFlow = widget.userCredentials?['uid'] != null;

    // ——— Email & Password (only for non-Firebase) ———
    if (!isFirebaseFlow) {
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الرجاء إدخال عنوان بريد إلكتروني صالح")),
        );
        return;
      }
      if (_passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("كلمة السر مطلوبة")),
        );
        return;
      }
    }

    // ——— Full name ———
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الاسم الكامل مطلوب")),
      );
      return;
    }

    // ——— Phone cleaning & validation ———
    String rawNumber = _phoneNumberController.text.trim();
    if (rawNumber.startsWith('0')) rawNumber = rawNumber.substring(1);
    if (rawNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء إدخال رقم هاتف من 10 أرقام بدون الصفر في البداية"),
        ),
      );
      return;
    }
    final phoneNumber = "+964$rawNumber";

    // ——— Gender ———
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اختر الجنس")),
      );
      return;
    }

    // ——— GPS location ———
    if (_gpsLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تحديد موقعك باستخدام زر تحديد الموقع بالـ GPS")),
      );
      return;
    }

    // ——— Show loader ———
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<PatientRetroDisplayGetProvider>(context, listen: false);

      // ——— Determine email and password ———
      final email = isGmailRegistration
          ? (widget.userCredentials?['email'] ?? '')
          : isPhoneRegistration
          ? "phonereg${DateTime.now().millisecondsSinceEpoch}@racheeta.app"
          : _emailController.text.trim();

      final password = isFirebaseFlow ? "${DateTime.now().millisecondsSinceEpoch}Rach@!" : _passwordController.text.trim();

      debugPrint('📧 Prepared email: $email');
      debugPrint('🔐 Prepared password: $password');


      // Always fetch FCM token here, especially for Gmail flow
      if (_fcmToken == null) {
        try {
          _fcmToken = await FirebaseMessaging.instance.getToken();
          debugPrint("🔁 [Gmail] Fetched FCM token in _saveProfile(): $_fcmToken");
        } catch (e) {
          debugPrint("❌ Failed to fetch FCM token: $e");
        }
      }

      // ——— Build payload ———
      final userMap = {
        "email": email,
        "password": password,
        "full_name": _fullNameController.text.trim(),
        "role": "patient",
        "gps_location": _gpsLocation,
        "phone_number": phoneNumber,
        "gender": _selectedGender,
        if (widget.userCredentials?['uid'] != null)
          "firebase_uid": widget.userCredentials!['uid'],
        if (_fcmToken != null)
          "fcm": _fcmToken,


        // ❌ don't include profile_image here
      };



      debugPrint("🚀 Sending user data: $userMap");

      // ——— Call your backend to create the profile ———
      final response = await provider.saveUserProfile(userMap) as Map<String, dynamic>;
      debugPrint("✅ User saved: $response");

      if (response.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("خطأ: هذا المستخدم موجود بالفعل"),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(); // dismiss loader
        return;
      }

      final userId = response["id"];
      debugPrint("🆔 New user ID: $userId");

      // ——— Authenticate & store tokens ———
      final token = await provider.authenticateUser(email, password);
      if (token == null) {
        throw Exception("❌ فشل الحصول على توكن بعد التسجيل.");
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs
        ..setString("access_token", token)
        ..setString("Login_access_token", token)
        ..setBool("isRegistered", true)
        ..setString("user_id", userId)
        ..setString("email", email)
        ..setString("full_name", response["full_name"])
        ..setString("role", response["role"])
        ..setString("gps_location", response["gps_location"] ?? "N/A")
        ..setString("phone_number", response["phone_number"])
        ..setString("gender", response["gender"]);
      debugPrint("💾 User info stored locally $prefs");

      provider.setAuthToken(token);
      Provider.of<TokenProvider>(context, listen: false).updateToken(token);

      // ——— Optionally upload avatar ———
      if (userId != null && _profileImage != null) {
        await _uploadProfileImage(_profileImage!, userId);
      }

      // ——— For Google flows only: link Firebase auth on your backend ———
      // ——— FOR GMAIL: link Firebase credentials first ———
      if (isGmailRegistration && !isPhoneRegistration) {
        debugPrint("📡 [Gmail] Linking Firebase user first…");
        await _sendFirebaseAuth(
          email,
          widget.userCredentials!['uid']!,
          password,
          context,
        );
      }

      // ——— Now create the user profile on /users/ ———
      debugPrint("[📤] Creating profile with: $userMap");


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم إنشاء الحساب وتسجيل الدخول بنجاح")),
      );

      Navigator.of(context).pop(); // close loader
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      Navigator.of(context).pop(); // close loader
      debugPrint("❌ Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "فشل إنشاء الحساب. تأكد من صحة البيانات.",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Send Firebase auth data if user used Gmail
  Future<void> _sendFirebaseAuth(
    String email,
    String firebaseUid,
    String password,
    BuildContext context,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        "https://racheeta.pythonanywhere.com/firebase-auth/",
        data: {
          "email": email,
          "firebase_uid": firebaseUid,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("Firebase Auth data sent successfully: $data");

        // Save tokens in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", data["access_token"]);
        await prefs.setString("refresh_token", data["refresh_token"]);
        await prefs.setString("user_id", data["user_id"]);
        await prefs.setBool('isRegistered', true);

        debugPrint("Tokens & userId stored in SharedPreferences");

        // Update the TokenProvider
        final tokenProvider =
            Provider.of<TokenProvider>(context, listen: false);
        tokenProvider.updateToken(data["access_token"]);
      } else {
        throw Exception("Failed to send Firebase Auth data: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error sending Firebase Auth data: $e");
      throw e;
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
        // dddddd
        onStepContinue: () async {
          // Step 0: Optional profile image step
          if (_currentStep == 0) {
            setState(() => _currentStep++);
            return;
          }

          // Step 1: Basic info step
          if (_currentStep == 1) {
            if (_formKey.currentState?.validate() ?? false) {
              setState(() => _currentStep++);

              // 🔄 Trigger location permission once reaching step 2
              if (_gpsLocation == null) {
                await _getCurrentLocation(context);
                if (_gpsLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ تعذر تحديد الموقع. تأكد من السماح بالوصول للموقع."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("رجاء املىء الحقول المطلوبة")),
              );
            }
            return;
          }

          // Step 2: Final submission step
          if (_currentStep == 2) {
            if (_formKey.currentState?.validate() ?? false) {
              if (_gpsLocation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠️ لم يتم تحديد الموقع. لا يمكن المتابعة."),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // ✅ If user did not upload image, upload the default image
              if (_profileImage == null) {
                final byteData = await rootBundle.load('assets/icons/patient1.png');
                final tempDir = await getTemporaryDirectory();
                final file = File('${tempDir.path}/default_patient.png');
                await file.writeAsBytes(byteData.buffer.asUint8List());
                _profileImage = file;
              }

              await _saveProfile();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("رجاء املىء الحقول المطلوبة")),
              );
            }
          }
        },

        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text(
              "البروفايل",
              style: TextStyle(fontSize: 14),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
            content: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
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
              ],
            ),
          ),
          Step(
            title: const Text(
              "المعلومات ",
              style: TextStyle(fontSize: 14),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!_isGmailRegistration)
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
                  if (!_isGmailRegistration)
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
                  const SizedBox(height: 5),
                  if (!_isGmailRegistration)
                    Text(
                      "قوة كلمة السر: ${getPasswordStrengthLabel(_passwordStrength)}",
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
                        renderBorder: false,
                        fillColor: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                        selectedColor: Colors.white,
                        color: Colors.black,
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          minHeight: 50,
                        ),
                        children: const [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.male),
                              Text(
                                "ذكر",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.female),
                              Text(
                                "أنثى",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Step(
            title: const Text(
              "معلومات الاتصال",
              style: TextStyle(fontSize: 14),
            ),
            isActive: _currentStep >= 2,
            state: StepState.editing,
            content: Column(
              children: [
                TextFormField(
                  textAlign: TextAlign.right,
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    prefixText: '+964 ',
                    counterText: '',
                    labelText: 'رقم المحمول',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    // Hide the default counter
                    contentPadding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                  ),
                  // Only digits, max 10
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    // Basic check if empty, further checks done in _saveProfile()
                    if (value == null || value.isEmpty) {
                      return "ادخل رقم هاتف صحيح";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     _getCurrentLocation(context);
                //   },
                //   child: const Text("حدد موقعك بالGPS"),
                // ),
                if (_gpsLocation != null)
                  Text(
                    "الموقع: $_gpsLocation",
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
