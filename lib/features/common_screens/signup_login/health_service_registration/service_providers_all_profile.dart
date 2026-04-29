// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart'; // Import the geolocator package
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../token_provider.dart';
// import '../../../../widgets/global_health_profile/communication_checkboxes.dart';
// import '../../../../widgets/global_health_profile/gender_toggle_widget.dart';
// import '../../../../widgets/global_health_profile/home_visit_switch.dart';
// import '../../../../widgets/global_health_profile/profile_image_picker_widget.dart';
// import '../../../../widgets/global_health_profile/save_button.dart';
// import '../../../../widgets/global_health_profile/time_and_day_picker_widget.dart';
// import 'package:racheeta/constansts/constants.dart';
// import '../../../doctors/providers/doctors_provider.dart';
// import '../../../doctors/screens/doctors_dashboard_screen.dart';
// import '../../../nurse/screens/nurse_dashboard_screen.dart';
// import '../../../pharmacist/screens/pharmacy_dashboard_screen.dart';
// import '../../../screens/home_screen.dart';
// import 'beauty_centers_fields.dart';
// import 'city_district_selection_page.dart';
// import 'doctor_fields.dart';
// import 'hospital_fields.dart';
// import 'laboratory_fields.dart';
// import 'medical_center_fields.dart';
// import 'nurse_fields.dart';
// import 'pharmacist_fields.dart';
// import 'therapist_fields.dart';
//
// //
// class ServiceProviderProfile extends StatefulWidget {
//   final String userType;
//   final Map<String, String>? userCredentials;
//
//   ServiceProviderProfile({required this.userType, this.userCredentials});
//
//   @override
//   _ServiceProviderProfileState createState() => _ServiceProviderProfileState();
// }
//
// class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> _doctorFormKey = GlobalKey<FormState>();
//
//   int _currentStep = 0;
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _specialtyController = TextEditingController();
//   final TextEditingController _degreeController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();
//
//   String? _gpsLocation;
//   File? _profileImage;
//   bool _isLoading = false;
//   String? _selectedGender = "m";
//   bool _isGmailRegistration = false;
//   double _passwordStrength = 0.0;
//   bool acceptAudioCalls = false;
//   bool acceptVideoCalls = false;
//   bool homeVisit = false;
//   int selectedGender = 0;
//   Position? _currentPosition; // To store the GPS location
//   String _locationMessage =
//       "لم يتم تحديد الموقع بعد"; // Display location message
//
//   final List<String> availableTimes = [
//     '03:00 مساء',
//     '04:00 مساء',
//     '05:00 مساء',
//     '06:00 مساء',
//     '07:00 مساء',
//     '08:00 مساء',
//     '09:00 مساء',
//     '10:00 مساء',
//     '11:00 مساء',
//   ];
//
//   final List<String> availableDays = [
//     'السبت',
//     'الاحد',
//     'الاثنين',
//     'الثلاثاء',
//     'الاربعاء',
//     'الخميس',
//     'الجمعة',
//   ];
//
//   // Default city and district values
//   String selectedCity = 'بغداد';
//   String selectedDistrict = 'الأعظمية'; // Default selected district
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.userCredentials != null) {
//       _emailController.text = widget.userCredentials?['email'] ?? '';
//       _isGmailRegistration = widget.userCredentials?['uid'] != null;
//     }
//
//     _passwordController.addListener(() {
//       setState(() {
//         _passwordStrength = calculatePasswordStrength(_passwordController.text);
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   double calculatePasswordStrength(String password) {
//     if (password.isEmpty) return 0.0;
//
//     int strength = 0;
//     if (password.length >= 6) strength++; // Length
//     if (RegExp(r'[A-Za-z]').hasMatch(password)) strength++; // Letters
//     if (RegExp(r'\d').hasMatch(password)) strength++; // Numbers
//     if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++; // Special chars
//
//     // Normalize to a range of 0.0 to 1.0
//     return strength / 4;
//   }
//
//   String getPasswordStrengthLabel(double strength) {
//     if (strength <= 0.25) {
//       return "Weak";
//     } else if (strength <= 0.5) {
//       return "Medium";
//     } else if (strength <= 0.75) {
//       return "Strong";
//     } else {
//       return "Very Strong";
//     }
//   }
//
//   bool isValidPhoneNumber(String number) {
//     // Checks if number matches pattern +964XXXXXXXXXX (13 digits total)
//     final regex = RegExp(r'^\+964\d{10}$');
//     return regex.hasMatch(number);
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _takePhoto() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _uploadProfileImage(File imageFile, String userId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("access_token");
//       if (token == null) {
//         debugPrint("No token found - can't upload image");
//         return;
//       }
//
//       final dio = Dio();
//       dio.options.headers["Authorization"] = "JWT $token";
//       dio.options.headers["Content-Type"] = "multipart/form-data";
//
//       // Build the form data with just the image
//       final formData = FormData.fromMap({
//         "profile_image": await MultipartFile.fromFile(imageFile.path),
//       });
//
//       // PATCH the user record with the new profile image
//       // Adjust the exact endpoint to match your backend's spec
//       final response = await dio.patch(
//         "https://racheeta.pythonanywhere.com/users/$userId/",
//         data: formData,
//       );
//
//       if (response.statusCode == 200) {
//         debugPrint("Image uploaded (patched) successfully: ${response.data}");
//       } else {
//         debugPrint(
//             "Failed to upload image: ${response.statusCode} - ${response.data}");
//       }
//     } catch (e) {
//       debugPrint("Error uploading image: $e");
//     }
//   }
//
//   Future<void> _getCurrentLocation(BuildContext context) async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Show a confirmation dialog before requesting location
//     final bool userConsent = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Allow Location Access"),
//           content:
//               Text("التطبيق يحتاج للحصول على موقعك الحالي , هل تسمح بذلك؟"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false), // User denied
//               child: Text("رفض"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true), // User accepted
//               child: Text("سماح"),
//             ),
//           ],
//         );
//       },
//     );
//
//     // If user denies permission, return early
//     if (!userConsent) {
//       print("User denied location access.");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("تم رفض الحصول عالموقع من قبل المستخدم")),
//       );
//       return;
//     }
//
//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print("Location services are disabled.");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please enable location services to proceed.")),
//       );
//       return;
//     }
//
//     // Check location permissions
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         print("Location permissions are denied.");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text("Location permission denied. Please allow access.")),
//         );
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       print("Location permissions are permanently denied.");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 "Location access is permanently denied. Please enable it in settings.")),
//       );
//       return;
//     }
//
//     // Fetch current location
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       print("Fetched location: ${position.latitude}, ${position.longitude}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 "Location fetched: ${position.latitude}, ${position.longitude}")),
//       );
//     } catch (e) {
//       print("Error fetching location: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to fetch location.")),
//       );
//     }
//   }
//
//   Future<void> _saveHSPProfile() async {
//     // Validate fields in DoctorFields using the FormKey
//     if (!_doctorFormKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please correct the errors in the form")),
//       );
//       return;
//     }
//     if (!_isGmailRegistration) {
//       if (_emailController.text.isEmpty ||
//           !_emailController.text.contains('@')) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Enter a valid email address")),
//         );
//         return;
//       }
//     }
//     // Handle password (use a default if it's Gmail registration)
//     final password =
//         _isGmailRegistration ? "${DateTime.now().millisecondsSinceEpoch}Rach@!" : _passwordController.text.trim();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );
//
//     try {
//       final provider =
//           Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
//
//       // Prepare user data for creation
//       final userMap = {
//         "email": _emailController.text.trim(),
//         "password": password,
//         "full_name": _fullNameController.text.trim(),
//         "role": "patient",
//         "profile_image": null, // We’ll upload the actual file via PATCH
//         "gps_location": _gpsLocation ?? "33.3152 44.3661",
//         // "phone_number": phoneNumber,
//         "gender": _selectedGender,
//         "firebase_uid": widget.userCredentials?['uid'],
//       };
//
//       debugPrint("Sending user data: $userMap");
//
//       // Create the user (POST) => server returns user with an "id"
//       final response =
//           await provider.saveUserProfile(userMap) as Map<String, dynamic>;
//       debugPrint("User saved successfully: $response");
//
//       // Check if user already exists
//       if (response.containsKey("error")) {
//         debugPrint("Error: ${response["error"]}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: ${response["error"]}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         Navigator.of(context).pop(); // Dismiss loading dialog
//         return;
//       }
//
//       // Extract newly created user ID
//       final userId = response["id"];
//       debugPrint("New user ID: $userId");
//
//       // Save user information in SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString("user_id", userId);
//       await prefs.setString("email", response["email"]);
//       await prefs.setString("full_name", response["full_name"]);
//       await prefs.setString("role", response["role"]);
//       await prefs.setString("gps_location", response["gps_location"] ?? "N/A");
//       await prefs.setString("phone_number", response["phone_number"]);
//       await prefs.setString("gender", response["gender"]);
//       debugPrint("User information stored in SharedPreferences.");
//
//       // Authenticate the user and store the token
//       final token = await provider.authenticateUser(
//         _emailController.text.trim(),
//         password,
//       );
//
//       if (token != null) {
//         await prefs.setString("access_token", token);
//         await prefs.setBool("isRegistered", true); // Set isRegistered to true
//         debugPrint("Access token saved: $token");
//       }
//
//       // Authenticate (login) to get JWT tokens
//       await provider.authenticateUser(
//         _emailController.text.trim(),
//         password,
//       );
//
//       // Immediately update the provider's token
//       final updatedToken = prefs.getString("access_token") ?? "";
//       provider.setAuthToken(updatedToken); // Reinitialize or set token
//
//       final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
//       tokenProvider.updateToken(updatedToken);
//
//       // If user selected an image, send a PATCH request to update the profile_image
//       if (userId != null && _profileImage != null) {
//         await _uploadProfileImage(_profileImage!, userId);
//       }
//
//       // If user came from Gmail sign-in, send Firebase auth
//       if (widget.userCredentials?['uid'] != null) {
//         await _sendFirebaseAuth(_emailController.text.trim(),
//             widget.userCredentials!['uid']!, password, context);
//         await provider.refreshUserState(); // Refresh user state
//       }
//
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Profile updated successfully")),
//       );
//
//       // Dismiss loading dialog
//       Navigator.of(context).pop();
//
//       // Navigate to HomeScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HomeScreen()),
//       );
//     } catch (e) {
//       Navigator.of(context).pop(); // Dismiss loading on error
//       if (e is DioError && e.response?.data != null) {
//         final errorData = e.response?.data;
//         debugPrint("Server response: $errorData");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Error: ${errorData.values.join(', ')}",
//               style: const TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else {
//         debugPrint("Error saving profile: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to save profile: $e")),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   /// Send Firebase auth data if user used Gmail
//   Future<void> _sendFirebaseAuth(String email, String firebaseUid,
//       String password, BuildContext context) async {
//     try {
//       final dio = Dio();
//       final response = await dio.post(
//         "https://racheeta.pythonanywhere.com/firebase-auth/",
//         data: {
//           "email": email,
//           "firebase_uid": firebaseUid,
//           "password": password,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = response.data;
//         debugPrint("Firebase Auth data sent successfully: $data");
//
//         // Save tokens in SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("access_token", data["access_token"]);
//         await prefs.setString("refresh_token", data["refresh_token"]);
//         await prefs.setString("user_id", data["user_id"]);
//         await prefs.setBool('isRegistered', true);
//
//         debugPrint("Tokens & userId stored in SharedPreferences");
//
//         // Update the TokenProvider
//         final tokenProvider =
//             Provider.of<TokenProvider>(context, listen: false);
//         tokenProvider.updateToken(data["access_token"]);
//       } else {
//         throw Exception("Failed to send Firebase Auth data: ${response.data}");
//       }
//     } catch (e) {
//       debugPrint("Error sending Firebase Auth data: $e");
//       throw e;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.of(context).pop(); // Navigate back to the previous page
//           },
//         ),
//         title: Text(
//           'الملف الشخصي لـ ${widget.userType}',
//           style: kAppBarDoctorsTextStyle,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey, // Assign the form key
//           child: ListView(
//             children: [
//               Column(
//                 children: [
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: CircleAvatar(
//                       radius: 60,
//                       backgroundImage: _profileImage != null
//                           ? FileImage(_profileImage!)
//                           : const AssetImage('assets/icons/doctor_icon.png')
//                               as ImageProvider,
//                       child: _profileImage == null
//                           ? const Icon(Icons.camera_alt, size: 30)
//                           : null,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _takePhoto,
//                         child: const Text("التقط صورة"),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: _pickImage,
//                         child: const Text("اختر صورة من المعرض"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   _locationMessage, // Display location message
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ),
//
//               if (widget.userType == 'doctor') ...[
//                 DoctorFields(
//                   formKey: _doctorFormKey,
//                 ),
//                 CommunicationCheckboxes(
//                   acceptAudioCalls: acceptAudioCalls,
//                   acceptVideoCalls: acceptVideoCalls,
//                   onCheckboxChanged: (audio, video) {
//                     setState(() {
//                       acceptAudioCalls = audio;
//                       acceptVideoCalls = video;
//                     });
//                   },
//                 ),
//                 HomeVisitSwitch(
//                   homeVisit: homeVisit,
//                   onToggle: (value) {
//                     setState(() {
//                       homeVisit = value;
//                     });
//                   },
//                 ),
//               ],
//               if (widget.userType == 'nurse') ...[
//                 NurseFields(formKey: _specializedFormKeys['nurse'] as GlobalKey<FormState>,),
//                 HomeVisitSwitch(
//                   homeVisit: homeVisit,
//                   onToggle: (value) {
//                     setState(() {
//                       homeVisit = value;
//                     });
//                   },
//                 ),
//               ],
//               if (widget.userType == 'therapist') ...[
//                 TherapistFields(),
//                 HomeVisitSwitch(
//                   homeVisit: homeVisit,
//                   onToggle: (value) {
//                     setState(() {
//                       homeVisit = value;
//                     });
//                   },
//                 ),
//               ],
//               if (widget.userType == 'pharmacist') ...[PharmacistFields()],
//               if (widget.userType == 'laboratory') ...[
//                 LaboratoryFields(),
//               ],
//               if (widget.userType == 'hospital') ...[
//                 HospitalFields(),
//               ],
//               if (widget.userType == 'medical_center') ...[
//                 MedicalCenterFields(),
//               ],
//               if (widget.userType == 'beauty_centers') ...[
//                 BeautyCentersFields(),
//               ],
//               if (widget.userType == 'doctor' ||
//                   widget.userType == 'nurse' ||
//                   widget.userType == 'therapist')
//                 GenderToggleWidget(
//                   selectedGender: selectedGender,
//                   onToggle: (gender) {
//                     setState(() {
//                       selectedGender = gender;
//                     });
//                   },
//                 ),
//               if (selectedGender == 0 &&
//                   (widget.userType == 'doctor' ||
//                       widget.userType == 'nurse' ||
//                       widget.userType == 'therapist'))
//                 const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text(
//                     "يرجى اختيار الجنس",
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//               CityDistrictSelection(
//                 selectedCity: selectedCity,
//                 selectedDistrict: selectedDistrict,
//                 onCityChanged: (newCity) {
//                   setState(() {
//                     selectedCity = newCity;
//                   });
//                 },
//                 onDistrictChanged: (newDistrict) {
//                   setState(() {
//                     selectedDistrict = newDistrict;
//                   });
//                 },
//               ),
//               TimeAndDayPicker(
//                 availableTimes: availableTimes,
//                 availableDays: availableDays,
//                 onSave: (startTime, endTime, days) {
//                   // Handle saving logic
//                 },
//               ),
//               const SizedBox(height: 5),
//               ElevatedButton(
//                 onPressed: () {
//                   _getCurrentLocation(context);
//                 },
//                 child: const Text("حدد موقعك بالGPS"),
//               ),
//               if (_gpsLocation != null)
//                 Text(
//                   "الموقع: $_gpsLocation",
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               const SizedBox(height: 20),
//
//               SaveButton(onSave: _saveHSPProfile), // Trigger validation
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
