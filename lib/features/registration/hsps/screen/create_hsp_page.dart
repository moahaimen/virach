import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../token_provider.dart';
import '../../../../widgets/global_health_profile/communication_checkboxes.dart';
import '../../../../widgets/global_health_profile/gender_toggle_widget.dart';
import '../../../../widgets/global_health_profile/home_visit_switch.dart';
import '../../../../widgets/global_health_profile/time_and_day_picker_widget.dart';
import '../../../beauty_centers/providers/beauty_centers_provider.dart';
import '../../../beauty_centers/screens/beauty_dashboard_screen.dart';
import '../../../common_screens/signup_login/health_service_registration/beauty_centers_fields.dart';
import '../../../common_screens/signup_login/health_service_registration/city_district_selection_page.dart';
import '../../../common_screens/signup_login/health_service_registration/doctor_fields.dart';
import '../../../common_screens/signup_login/health_service_registration/hospital_fields.dart';
import '../../../common_screens/signup_login/health_service_registration/laboratory_fields.dart';
import '../../../common_screens/signup_login/health_service_registration/medical_center_fields.dart';
import '../../../common_screens/signup_login/health_service_registration/nurse_fields.dart';
import '../../../common_screens/signup_login/health_service_registration/pharmacist_fields.dart';
import '../../../common_screens/signup_login/health_service_registration/therapist_fields.dart';
import '../../../hospitals/providers/hospital_display_provider.dart';
import '../../../hospitals/screens/hospital_dashboard_screen.dart';
import '../../../labrotary/providers/labs_provider.dart';
import '../../../labrotary/screens/labrotary_dashboard_screen.dart';
import '../../../medical_centre/providers/medical_centers_providers.dart';
import '../../../medical_centre/screens/medical_centre_dashboard_screen.dart';
import '../../../nurse/providers/nurse_provider.dart';
import '../../../nurse/screens/nurse_dashboard_screen.dart';
import '../../../pharmacist/providers/pharma_provider.dart';
import '../../../pharmacist/screens/pharmacy_dashboard_screen.dart';
import '../../../therapist/providers/therapist_provider.dart';
import '../../../therapist/screens/therapist_dashboard_screen.dart';
import '../../../doctors/providers/doctors_provider.dart';
import '../../../doctors/screens/doctors_dashboard_screen.dart';

// NOTE: If nurse has a different fields widget, you can import that here
// e.g., import 'nurse_fields.dart';
// ①  ─────────────────────────── Role constants ───────────────────────────
class HspRoles {
  static const doctor        = 'doctor';
  static const nurse         = 'nurse';
  static const pharmacist    = 'pharmacist';
  static const physTherapist = 'physical-therapist';
  static const beautyCenter  = 'beauty_center';
  static const lab           = 'labrotary';
  static const medicalCenter = 'medical_center';
  static const mdeidcalCenter = 'mdeidcal_center'; // ➜ add this line
  static const hospital      = 'hospital';
}

// ①  ───────────────────────────────────────────────────────────────────────

class CreateHSPPage extends StatefulWidget {
  final String userType; // e.g. "doctor" or "nurse"
  final Map<String, String>? userCredentials;

  const CreateHSPPage({
    Key? key,
    required this.userType,
    this.userCredentials,
  }) : super(key: key);

  @override
  _CreateHSPPageState createState() => _CreateHSPPageState();
}

class _CreateHSPPageState extends State<CreateHSPPage> {
  int _currentStep = 0;
  bool _isLoading = false;
  String _statusMessage = "";
  String? _gpsLocation;
  String? _bio;
  File? _profileImage;

  bool acceptAudioCalls = false;
  bool acceptVideoCalls = false;
  bool homeVisit = false;

  int selectedGender = 0; // 0 => 'm', 1 => 'f'

  String selectedCity = "بغداد";
  String selectedDistrict = "الأعظمية";

  final List<String> availableTimes = [
    '03:00 مساء',
    '04:00 مساء',
    '05:00 مساء',
    '06:00 مساء',
    '07:00 مساء',
    '08:00 مساء',
    '09:00 مساء',
    '10:00 مساء',
    '11:00 مساء',
  ];
  final List<String> availableDays = [
    'السبت',
    'الاحد',
    'الاثنين',
    'الثلاثاء',
    'الاربعاء',
    'الخميس',
    'الجمعة',
  ];
  String typedAvailabilityTime = "";
  List<String> typedDays = [];
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  List<String> _selectedDays = [];
  bool _isGmailRegistration = false;
  String? _firebaseUid;

// 🔄 replace only the keys list
  final Map<String, GlobalKey<FormState>> _specializedFormKeys = {
    HspRoles.doctor        : GlobalKey<FormState>(),
    HspRoles.nurse         : GlobalKey<FormState>(),
    HspRoles.pharmacist    : GlobalKey<FormState>(),
    HspRoles.physTherapist : GlobalKey<FormState>(),
    HspRoles.beautyCenter  : GlobalKey<FormState>(),
    HspRoles.lab           : GlobalKey<FormState>(),

    // “correct” spelling
    HspRoles.medicalCenter : GlobalKey<FormState>(),

    // ✅ add the backend-typo spelling so userType == "mdeidcal_center"
    //    will still find a key and validate properly
    HspRoles.mdeidcalCenter: GlobalKey<FormState>(),

    HspRoles.hospital      : GlobalKey<FormState>(),
  };


  final GlobalKey<FormState> _nurseFormKey = GlobalKey<FormState>();
  final _therapistFormKey = GlobalKey<FormState>();
  final _therapistFieldsKey = GlobalKey<TherapistFieldsState>();
  final _beauticianFieldsKey = GlobalKey<BeautyCentersFieldsState>();
  final _hospitalFieldsKey = GlobalKey<HospitalFieldsState>();
  final _pharmacyFieldsKey = GlobalKey<PharmacistFieldsState>();
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _doctorFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _pharmacistFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _labFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _hospitalFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _medicalCenterFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _beauticianFormKey = GlobalKey<FormState>();
// Global keys for steps:
  final _step0FormKey = GlobalKey<FormState>();
  final _step1FormKey = GlobalKey<FormState>();

  // We can reuse the same fields widget or separate them
  final GlobalKey<DoctorFieldsState> _doctorFieldsKey =
      GlobalKey<DoctorFieldsState>();
  final GlobalKey<PharmacistFieldsState> _pharmaFieldsKey =
      GlobalKey<PharmacistFieldsState>();
  final GlobalKey<NurseFieldsState> _nurseFieldsKey =
      GlobalKey<NurseFieldsState>();
  final GlobalKey<BeautyCentersFieldsState> _beautyFieldsKey =
      GlobalKey<BeautyCentersFieldsState>();
  final GlobalKey<LaboratoryFieldsState> _labFieldsKey =
      GlobalKey<LaboratoryFieldsState>();

  final TextEditingController _pharmacyNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _directorNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _administrationController =
      TextEditingController();
  final TextEditingController _centerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gpsLocationController = TextEditingController();

  // If you want to prevent double-taps in pickImage:
  bool _isPickingImage = false;
// Debug print in the constructor
  _CreateHSPPageState() {
    print(">>> [DEBUG] CreateHSPPage Constructor called");
  }
  late DoctorRetroDisplayGetProvider doctorProvider;
  bool isValidPhoneNumber(String number) {
    // Checks if number matches pattern +964XXXXXXXXXX (13 digits total)
    final regex = RegExp(r'^\+964\d{10}$');
    return regex.hasMatch(number);
  }

// 3. Add this helper method
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساء' : 'صباحا';
    final displayHour = hour > 12 ? hour - 12 : hour;

    print(">>> [FORMAT] Raw: ${time.hour}:${time.minute}");
    print(">>> [FORMAT] Converted: $displayHour:$minute $period");

    return "$displayHour:$minute $period";
  }

  @override
  void initState() {
    super.initState();

    doctorProvider =
        Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);

    print('[DEBUG] CreateHSPPage received credentials:');
    print('┌────────── Received Credentials ──────────');
    print('│ Type: ${widget.userType}');
    print('│ Email: ${widget.userCredentials?['email']}');
    print('│ UID: ${widget.userCredentials?['uid']}');
    print('│ Name: ${widget.userCredentials?['name']}');
    print('│ Photo URL: ${widget.userCredentials?['photoUrl']}');
    print('└──────────────────────────────────────────');

    // Auto-fill name field if available
    if (widget.userCredentials?['name'] != null) {
      _nameController.text = widget.userCredentials!['name']!;
    }

    // Load profile photo if available
    if (widget.userCredentials?['photoUrl'] != null) {
      _loadGoogleProfileImage(widget.userCredentials!['photoUrl']!);
    }
    _isGmailRegistration = widget.userCredentials?['uid'] != null;

    // Auto-fill name from Google
    if (_isGmailRegistration) {
      _nameController.text = widget.userCredentials?['name'] ?? '';
    }
    // Auto-fill Gmail credentials
    if (widget.userCredentials != null) {
      _isGmailRegistration = true;
      _emailController.text = widget.userCredentials!['email'] ?? '';
      _nameController.text = widget.userCredentials!['name'] ?? '';
    }

    print(">>> [INIT] Email: ${_emailController.text}");
    print(">>> [INIT] Name: ${_nameController.text}");
  }
  Future<String?> _getFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint("[ERROR] Failed to retrieve FCM token");
        return null;
      }
      debugPrint("[DEBUG] Retrieved FCM Token: $fcmToken");
      return fcmToken;
    } catch (e) {
      debugPrint("[ERROR] Exception while fetching FCM token: $e");
      return null;
    }
  }

  Future<void> _loadGoogleProfileImage(String url) async {
    try {
      final response = await Dio().get<Uint8List>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      setState(() {
        _profileImage = File.fromRawPath(response.data!);
      });
    } catch (e) {
      print('[ERROR] Failed to load Google profile image: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  ///هنا يتم ضغط زر المتابعة وسبب المشاكل عند التنقلات بين الفورم
  // Stepper logic
  void _onStepContinue() async {
    // Step 0 => Common user form (profile image optional)
    if (_currentStep == 0) {
      if (_userFormKey.currentState!.validate()) {
        // If no image provided, use default
        if (_profileImage == null) {
          try {
            final byteData = await rootBundle.load('assets/images/default_avatar.png');
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/default_avatar.png');
            await tempFile.writeAsBytes(byteData.buffer.asUint8List());
            _profileImage = tempFile;

            if (_profileImage!.existsSync()) {
              debugPrint("✅ Default profile image loaded and exists: ${_profileImage!.path}");
            } else {
              debugPrint("❌ Default image assigned but file does not exist on disk.");
            }
          } catch (e) {
            debugPrint("❌ Failed to load default image: $e");
          }
        }
        setState(() => _currentStep++);
      }
      // Step 1 => Specialized form per HSP type
    } else if (_currentStep == 1) {
      final formKey = _specializedFormKeys[widget.userType];
      if (formKey?.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("   رجاء املىء الحقول المطلوبة")),
        );
      }

      // Step 2 => Final step: auto-request GPS, then submit
    } else if (_currentStep == 2) {
      // Auto-request location if missing
      if (_gpsLocation == null || _gpsLocation!.isEmpty) {
        await _getCurrentLocation(context);
      }

      // If still missing, block
      if (_gpsLocation == null || _gpsLocation!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("يجب تحديد موقعك باستخدام GPS قبل المتابعة"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      ///TODo check if this switch works for all Hsps
      // Submit based on role
      switch (widget.userType) {
        case 'doctor':
          _submitDoctor(); break;
        case 'nurse':
          _submitNurse(); break;
        case 'physical-therapist':
        case 'therapist':
          _submitTherapist(); break;
        case 'pharmacist':
          _submitPharmacy(); break;
        case 'labrotary':
          _submitLab(); break;
        case HspRoles.medicalCenter:
          _submitMedicalCenter();
          break;
        case 'hospital':
          _submithospital(); break;
      /* ─────────── MEDICAL-CENTER (both spellings) ─────────── */
        case HspRoles.medicalCenter:      // "medical_center"
        case HspRoles.mdeidcalCenter:     // "mdeidcal_center"  ← NEW
          _submitMedicalCenter();
          break;

        case 'beauty_center':
          _submitBeautician(); break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("نوع المستخدم غير مدعوم")),
          );
      }
    }
  }
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  List<Step> get _steps => [
        Step(
          title: const Text("اساسية"),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.editing,
          content: _buildUserForm(),
        ),
        Step(
          title: const Text("تخصصية"),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.editing,
          content: _buildSpecialForm(),
        ),
        Step(
          title: const Text("إضافات"),
          isActive: _currentStep >= 2,
          state: StepState.editing,
          content: _buildAdditionalStep(),
        ),
      ];

  // ====================== WIDGETS =========================

  // ====================== WIDGETS (STEP CONTENT) =========================

  /// Step 0 => Common Fields
  Widget _buildUserForm() {
    return Form(
      key: _userFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Profile image section
          _buildProfileImageSection(),
          const SizedBox(
            height: 10,
          ),
          if (!_isGmailRegistration) _buildPhotoButtons(),
          const SizedBox(
            height: 10,
          ),

          if (!_isGmailRegistration) _buildEmailField(),
          const SizedBox(
            height: 10,
          ),

          _buildNameField(),
          const SizedBox(
            height: 10,
          ),

          if (!_isGmailRegistration) _buildPasswordField(),
          const SizedBox(
            height: 10,
          ),

          _buildPhoneField(),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return GestureDetector(
      onTap: _isGmailRegistration ? null : _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundImage: _isGmailRegistration
            ? (widget.userCredentials?['photoUrl'] != null
                ? NetworkImage(widget.userCredentials!['photoUrl']!)
                : const AssetImage('assets/icons/doctor_icon.png')
                    as ImageProvider)
            : (_profileImage != null
                ? FileImage(_profileImage!)
                : const AssetImage('assets/icons/doctor_icon.png')
                    as ImageProvider),
        child: _isGmailRegistration
            ? null
            : (_profileImage == null ? const Icon(Icons.camera_alt) : null),
      ),
    );
  }

  Widget _buildPhotoButtons() {
    return Row(
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
    );
  }

  Widget _buildEmailField() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "الرجاء إدخال البريد الإلكتروني";
            }

            final emailRegex =
            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return "صيغة البريد الإلكتروني غير صالحة";
            }

            return null;
          },
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "اسم الشخص",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
        if (value.length < 3) return "الاسم قصير جدا";
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return "الرجاء إدخال كلمة المرور";
            if (value.length < 6) return "يجب أن تكون أطول من 6 أحرف";
            return null;
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Directionality(
      // force LTR just for the phone field
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          prefix: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('+964', style: TextStyle(fontSize: 16)),
          ),
          prefixIcon: Icon(Icons.phone),
          labelText: 'رقم المحمول',
          counterText: '',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'يرجى إدخال رقم الهاتف';
          if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
            return 'يجب أن يكون 10 أرقام (بدون +964)';
          return null;
        },
      ),
    );
  }

  /// Step 1 => Specialized Fields
  Widget _buildSpecialForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Doctor
          if (widget.userType == 'doctor') ...[
            DoctorFields(
                key: _doctorFieldsKey,
                formKey: _specializedFormKeys['doctor']!),
          ],

          // Nurse
          if (widget.userType == 'nurse') ...[
            NurseFields(
              key: _nurseFieldsKey,
              formKey: _specializedFormKeys['nurse']!,
            ),
          ],

          /// Therapist
          if (widget.userType == 'therapist' ||
              widget.userType == 'physical-therapist') ...[
            // No extra Form widget here
            TherapistFields(
              key:
                  _therapistFieldsKey, // If you want direct .specialty, .bio getters
              formKey: _specializedFormKeys[
                  'physical-therapist'], // The same key you will use to validate
            ),
          ],

          /// Pharmacist
          if (widget.userType == 'pharmacist') ...[
            PharmacistFields(
              key: _pharmacyFieldsKey, // So we can read phone, etc.
              formKey: _specializedFormKeys['pharmacist'],
            ),
          ],

          // Laboratory
          if (widget.userType == 'labrotary') ...[
            LaboratoryFields(
              key: _labFieldsKey,
              formKey: _specializedFormKeys['labrotary'],
            ),
          ],

          // Hospital
          if (widget.userType == 'hospital') ...[
            Form(
              key: _hospitalFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: HospitalFields(
                key: _hospitalFieldsKey,
                formKey: _specializedFormKeys['hospital'],
              ),
            ),
          ],

          // Medical Center
// ───────────── MEDICAL-CENTER (accept both spellings) ─────────────
          if (widget.userType == HspRoles.medicalCenter ||             // "medical_center"
              widget.userType == HspRoles.mdeidcalCenter) ...[          // "mdeidcal_center"
            MedicalCenterFields(
              formKey               : _specializedFormKeys[widget.userType]!,
              centerNameController  : _centerNameController,
              directorNameController: _directorNameController,
              bioController         : _bioController,
              phoneController       : _phoneController,
              selectedCity          : selectedCity,
              selectedDistrict      : selectedDistrict,
              onCityChanged         : (c) => setState(() => selectedCity     = c),
              onDistrictChanged     : (d) => setState(() => selectedDistrict = d),
            ),
          ],

          // Beauty Center
          if (widget.userType == 'beauty_center') ...[
            BeautyCentersFields(
              key: _beauticianFieldsKey,
              formKey:
                  _specializedFormKeys['beauty_center'], // link the form key
            ),
          ],
        ],
      ),
    );
  }

  /// Step 2 => Additional Toggles, Location, etc.
  Widget _buildAdditionalStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Communication checkboxes => if relevant (e.g., doctor/nurse/therapist)
          if (widget.userType == 'doctor' ||
              widget.userType == 'nurse' ||
              widget.userType == 'therapist')
            CommunicationCheckboxes(
              acceptAudioCalls: acceptAudioCalls,
              acceptVideoCalls: acceptVideoCalls,
              onCheckboxChanged: (audio, video) {
                setState(() {
                  acceptAudioCalls = audio;
                  acceptVideoCalls = video;
                });
              },
            ),

          // Home visit => if relevant
          if (widget.userType == 'doctor' ||
              widget.userType == 'nurse' ||
              widget.userType == 'therapist')
            HomeVisitSwitch(
              homeVisit: homeVisit,
              onToggle: (value) {
                setState(() => homeVisit = value);
              },
            ),

          // Gender toggle => if relevant
          if (widget.userType == 'doctor' ||
              widget.userType == 'nurse' ||
              widget.userType == 'therapist') ...[
            GenderToggleWidget(
              selectedGender: selectedGender,
              onToggle: (index) {
                setState(() => selectedGender = index);
              },
            ),
            if (selectedGender == 0)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "يرجى اختيار الجنس",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],

          /// City & District
          CityDistrictSelection(
            selectedCity: selectedCity,
            selectedDistrict: selectedDistrict,
            onCityChanged: (c) => setState(() => selectedCity = c),
            onDistrictChanged: (d) => setState(() => selectedDistrict = d),
          ),

          TimeAndDayPicker(
            availableTimes: const [
              '03:00 مساء',
              '04:00 مساء',
              '05:00 مساء',
              '06:00 مساء',
              '07:00 مساء',
              '08:00 مساء',
              '09:00 مساء',
              '10:00 مساء',
              '11:00 مساء'
            ],
            availableDays: const [
              'السبت',
              'الأحد',
              'الإثنين',
              'الثلاثاء',
              'الاربعاء',
              'الخميس',
              'الجمعة'
            ],
            onSave: (startTime, endTime, days) {
              setState(() {
                typedAvailabilityTime = "$startTime-$endTime";
                typedDays = days;
              });
              print(">>> [DEBUG] Saved Availability: $typedAvailabilityTime");
              print(">>> [DEBUG] Saved Days: ${typedDays.join(', ')}");
            },
          ),

          const SizedBox(height: 20),

          // GPS Button
          // ElevatedButton(
          //   onPressed: () => _getCurrentLocation(context),
          //   child: const Text("حدد موقعك بالGPS"),
          // ),
          if (_gpsLocation != null)
            Text("الموقع: $_gpsLocation", style: const TextStyle(fontSize: 16)),

          // Status message
          if (_statusMessage.isNotEmpty)
            Text(_statusMessage, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  // ====================== MAIN BUILD =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إنشاء حساب ${widget.userType}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              steps: _steps,
            ),
    );
  }

  // ====================== SUBMISSION LOGIC =========================

  /// (1) Submit as DOCTOR

  /// (1) Submit as DOCTOR

  Future<void> _submitDoctor() async {
    setState(() => _isLoading = true);
    print(">>> [DEBUG] Starting _submitDoctor process");

    // Validate availability time.
    if (typedAvailabilityTime.isEmpty) {
      setState(() {
        _statusMessage = "يرجى تحديد وقت العمل.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Availability Time is empty. Cannot proceed.");
      return;
    }

    // Prepare inputs.
    final typedEmail = _isGmailRegistration
        ? (widget.userCredentials?['email'] ?? '')
        : _emailController.text.trim();
    final typedName = _nameController.text.trim();
    final typedPassword =
    _isGmailRegistration ? "10000001" : _passwordController.text.trim();
    final typedPhone = _phoneController.text.trim();
    final typedGender = (selectedGender == 0) ? 'm' : 'f';
    final typedAddress = "$selectedCity - $selectedDistrict";

    final docState = _doctorFieldsKey.currentState;
    final typedBio = docState?.bio ?? "";
    final typedSpecialty = docState?.specialty ?? "";
    final typedDegree = docState?.degree ?? "";
    final typedCountry = docState?.country ?? "Iraq";

    print(">>> [DEBUG] _submitDoctor Inputs:");
    print("    Email: $typedEmail");
    print("    Name: $typedName");
    print("    Password: ${typedPassword.isEmpty ? 'EMPTY' : 'PROVIDED'}");
    print("    Phone: $typedPhone");
    print("    Gender: $typedGender");
    print("    Address: $typedAddress");
    print("    Specialty: $typedSpecialty");
    print("    Degree: $typedDegree");
    print("    Bio: $typedBio");
    print("    Country: $typedCountry");
    print("    Availability Time: $typedAvailabilityTime");

    // Basic field validation.
    if ((!_isGmailRegistration && typedEmail.isEmpty) ||
        (!_isGmailRegistration && typedName.isEmpty) ||
        (!_isGmailRegistration && typedPassword.isEmpty) ||
        typedPhone.isEmpty ||
        typedSpecialty.isEmpty ||
        typedDegree.isEmpty) {
      setState(() {
        _statusMessage = "يرجى ملء جميع الحقول المطلوبة.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Required fields validation failed.");
      return;
    }

    try {
      // Retrieve the device's FCM token.
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final isActivedoctor = false;
      print(">>> [DEBUG] Retrieved FCM Token: $fcmToken");

      // 1) Create User (role = doctor) including the FCM token.
      final createdUser = await doctorProvider.createUser(
        email: typedEmail,
        fullName: typedName,
        password: typedPassword,
        role: "doctor",
        phoneNumber: typedPhone,
        gps_location: _gpsLocation ?? "33.3152 44.3661",
        gender: typedGender,
        firebaseUid:
        _isGmailRegistration ? widget.userCredentials!['uid'] : null,
        fcm: fcmToken, // <-- Pass FCM token here.
        isActive: isActivedoctor
      );

      if (createdUser == null || createdUser.id == null) {
        setState(() {
          _statusMessage = "إنشاء المستخدم (Doctor) فشل.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create user.");
        return;
      }
      print(">>> [DEBUG] User created: ${createdUser.toJson()}");

      // 2) Authenticate user (if not Gmail).
      if (!_isGmailRegistration) {
        print(">>> [DEBUG] Authenticating user (Doctor)...");
        final token =
        await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "تعذر تسجيل الدخول تلقائياً (Doctor).";
            _isLoading = false;
          });
          print(">>> [DEBUG] User authentication failed.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
        final tokenProv = Provider.of<TokenProvider>(context, listen: false);
        tokenProv.updateToken(token);
        print(">>> [DEBUG] Authentication token saved.");
      }

      // 3) If Gmail, link Firebase UID; otherwise, re-authenticate.
      if (_isGmailRegistration && _firebaseUid != null) {
        await _sendFirebaseAuth(
            typedEmail, _firebaseUid!, typedPassword, context);
      } else {
        final token =
        await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "Failed to authenticate doctor user.";
            _isLoading = false;
          });
          print(">>> [DEBUG] Re-auth for doctor user failed.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
      }

      // 4) Create the Doctor record.
      final typedPriceString = docState?.price ?? "";
      final typedPrice = double.tryParse(typedPriceString);
      final createdDoctor = await doctorProvider.createDoctor(
        userModel: createdUser,
        specialty: typedSpecialty,
        degrees: typedDegree,
        bio: typedBio,
        address: typedAddress,
        isInternationalBool: typedCountry != "Iraq",
        country: typedCountry,
        availabilityTime: typedAvailabilityTime,
        price: typedPrice,
        voiceCall: acceptAudioCalls,
        videoCall: acceptVideoCalls,

      );

      if (createdDoctor == null || createdDoctor.id == null) {
        setState(() {
          _statusMessage = "إنشاء حساب الطبيب فشل.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create doctor record.");
        return;
      }
      print(">>> [DEBUG] Doctor record created: ${createdDoctor.toJson()}");

      // 5) Upload profile image if provided.
      if (_profileImage != null && _profileImage!.existsSync()) {
        print(">>> [DEBUG] Uploading doctor profile image...");
        await _uploadProfileImage(_profileImage!, createdUser.id!);
      } else {
        print("❌ No profile image to upload or file does not exist.");
      }



      // 6) Save both user_id (User PK) and doctor_id (Doctor PK) in SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", createdUser.id!);
      await prefs.setString("doctor_id", createdDoctor.id!);
      await prefs.setString("full_name", createdUser.fullName ?? "");
      await prefs.setString("email", createdUser.email ?? "");
      await prefs.setString("role", "doctor");
      await prefs.setBool("isRegistered", true);

      print(
          ">>> [DEBUG] user_id=${createdUser.id}, doctor_id=${createdDoctor.id}");

      // 7) Navigate to the Doctor Dashboard.
      setState(() {
        _statusMessage =
        "تم إنشاء الطبيب بنجاح برقم المعرف: ${createdDoctor.id}";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => ResponsiveDoctorDashboard(
            userType: 'doctor',
            userId: createdUser.id!,
            doctorId: createdDoctor.id!,
            userName: createdUser.fullName ?? 'Doctor',
          ),
        ),
      );
      print(">>> [DEBUG] Navigation to doctor dashboard completed.");
    } catch (e, stack) {
      print(">>> [DEBUG] Exception in _submitDoctor: $e");
      print("StackTrace: $stack");
      setState(() => _statusMessage = "Error(doctor): $e");
    } finally {
      setState(() => _isLoading = false);
      print(">>> [DEBUG] _submitDoctor process completed.");
    }
  }


  /// Creating Nurse
  Future<void> _submitNurse() async {
    setState(() => _isLoading = true);
    print(">>> [DEBUG] Starting _submitNurse process");

    // Validate availability time
    if (typedAvailabilityTime.isEmpty) {
      setState(() {
        _statusMessage = "يرجى تحديد وقت العمل.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Availability Time is empty. Cannot proceed.");
      return;
    }

    // Gather form inputs
    final typedEmail = _isGmailRegistration
        ? (widget.userCredentials?['email'] ?? '')
        : _emailController.text.trim();
    final typedName = _nameController.text.trim();
    final typedPassword =
        _isGmailRegistration ? "10000001" : _passwordController.text.trim();
    final typedPhone = _phoneController.text.trim();
    final typedGender = (selectedGender == 0) ? 'm' : 'f';
    final typedAddress = "$selectedCity - $selectedDistrict";

    // Nurse fields
    final nurseState = _nurseFieldsKey.currentState;
    final typedSpecialty = nurseState?.selectedSpecialty ?? "";
    final typedDegree = nurseState?.selectedDegree ?? "";
    final typedBio = nurseState?.bio ?? "";

    print(">>> [DEBUG] _submitNurse Inputs:");
    print("    Email: $typedEmail");
    print("    Name: $typedName");
    print("    Password: ${typedPassword.isEmpty ? 'EMPTY' : 'PROVIDED'}");
    print("    Phone: $typedPhone");
    print("    Gender: $typedGender");
    print("    Address: $typedAddress");
    print("    Specialty: $typedSpecialty");
    print("    Degree: $typedDegree");
    print("    Bio: $typedBio");
    print("    Availability Time: $typedAvailabilityTime");

    // Validate fields
    final missingEmail = !_isGmailRegistration && typedEmail.isEmpty;
    final missingPassword = !_isGmailRegistration && typedPassword.isEmpty;
    if (missingEmail ||
        typedName.isEmpty ||
        typedPhone.isEmpty ||
        typedSpecialty.isEmpty ||
        typedDegree.isEmpty ||
        missingPassword) {
      setState(() {
        _statusMessage = "يرجى ملء جميع الحقول المطلوبة.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Required fields validation failed.");
      return;
    }

    try {
      // Step 1: Create the user (role = nurse)
      print(">>> [DEBUG] Creating user with email: $typedEmail");
      final createdUser = await doctorProvider.createUser(
        email: typedEmail,
        fullName: typedName,
        password: typedPassword,
        role: "nurse",
        phoneNumber: typedPhone,
        gps_location: _gpsLocation ?? "33.3152 44.3661",
        gender: typedGender,
        firebaseUid:
            _isGmailRegistration ? widget.userCredentials!['uid'] : null,
      );

      if (createdUser == null || createdUser.id == null) {
        setState(() {
          _statusMessage = "إنشاء المستخدم (Nurse) فشل.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create user.");
        return;
      }

      print(">>> [DEBUG] User created successfully: ${createdUser.toJson()}");

      // Step 2: If not Gmail => authenticate user to get token
      if (!_isGmailRegistration) {
        print(">>> [DEBUG] Authenticating user (Nurse)...");
        final token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);

        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "تعذر تسجيل الدخول تلقائياً (Nurse).";
            _isLoading = false;
          });
          print(">>> [DEBUG] User authentication failed.");
          return;
        }

        // Save that token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
        Provider.of<TokenProvider>(context, listen: false).updateToken(token);
        print(">>> [DEBUG] Nurse token saved (email flow).");
      }

      ///authenicate
      // 4) If using Gmail => link the Firebase UID, else authenticate
      if (_isGmailRegistration && _firebaseUid != null) {
        await _sendFirebaseAuth(
            typedEmail, _firebaseUid!, typedPassword, context);
      } else {
        final token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);

        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "Failed to authenticate therapist user.";
            _isLoading = false;
          });
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
      }

      // Step 4: Create the actual nurse record
      final nurseProvider =
          Provider.of<NurseRetroDisplayGetProvider>(context, listen: false);
      final createdNurse = await nurseProvider.createNurse(
        userModel: createdUser,
        specialty: typedSpecialty,
        degree: typedDegree,
        bio: typedBio,
        address: typedAddress,
        availabilityTime: typedAvailabilityTime,
      );

      if (createdNurse == null || createdNurse.id == null) {
        setState(() {
          _statusMessage = "إنشاء حساب الممرضة فشل.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create nurse record.");
        return;
      }

      print(">>> [DEBUG] Nurse created successfully: ${createdNurse.toJson()}");

      // Step 5: Upload profile image if exists
      if (_profileImage != null && _profileImage!.existsSync()) {
        print(">>> [DEBUG] Uploading doctor profile image...");
        await _uploadProfileImage(_profileImage!, createdUser.id!);
      } else {
        print("❌ No profile image to upload or file does not exist.");
      }

      // Step 6: Save user info so we remain logged in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", createdUser.id!);
      await prefs.setString("full_name", createdUser.fullName ?? "");
      await prefs.setString("nurse_id", createdNurse.id!); // doctor PK
      await prefs.setString("email", createdUser.email ?? "");
      await prefs.setString("role", "nurse");
      await prefs.setBool("isRegistered", true);

      print(">>> [DEBUG] Nurse info saved in SharedPreferences.");

      // Step 7: Navigate to nurse dashboard
      setState(() {
        _statusMessage =
            "تم إنشاء الممرضة بنجاح برقم المعرف: ${createdNurse.id}";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => ResponsiveNurseDashboard(
                  userType: 'nurse',
                  userId: createdUser.id!,
                  userName: createdUser.fullName ?? 'Nurse',
                  nurseId: createdNurse.id!, // The doctor PK
                )),
      );
      print(">>> [DEBUG] Navigation to nurse dashboard completed.");
    } catch (e) {
      print(">>> [DEBUG] Exception in _submitNurse: $e");
      setState(() => _statusMessage = "Error(nurse): $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Creating Therapist
  Future<void> _submitTherapist() async {
    setState(() => _isLoading = true);
    print(">>> [DEBUG] Starting _submitTherapist process");

    // 1) Validate availability time (like Nurse)
    if (typedAvailabilityTime.isEmpty) {
      setState(() {
        _statusMessage = "يرجى تحديد وقت العمل.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Availability Time is empty. Cannot proceed.");
      return;
    }

    // 2) Gather common fields (just like Nurse)
    final typedEmail = _isGmailRegistration
        ? (widget.userCredentials?['email'] ?? '')
        : _emailController.text.trim();
    final typedName = _nameController.text.trim();
    final typedPassword =
        _isGmailRegistration ? "10000001" : _passwordController.text.trim();
    final typedPhone = _phoneController.text.trim();
    final typedGender = (selectedGender == 0) ? 'm' : 'f';
    final typedAddress = "$selectedCity - $selectedDistrict";

    // 3) Gather the therapist-specific fields
    final therapistState = _therapistFieldsKey.currentState;
    if (therapistState == null) {
      setState(() {
        _statusMessage = "Therapist form state not found.";
        _isLoading = false;
      });
      return;
    }

    final typedSpecialty = therapistState.specialty;
    final typedDegree = therapistState.degree;
    final typedBio = therapistState.bio;
    // If your widget also picks city/district or times, gather them similarly:
    // final typedCity = therapistState.selectedCity;
    // final typedDistrict = therapistState.selectedDistrict;
    print(">>> [DEBUG] _submitNurse Inputs:");
    print("    Email: $typedEmail");
    print("    Name: $typedName");
    print("    Password: ${typedPassword.isEmpty ? 'EMPTY' : 'PROVIDED'}");
    print("    Phone: $typedPhone");
    print("    Gender: $typedGender");
    print("    Address: $typedAddress");
    print("    Specialty: $typedSpecialty");
    print("    Degree: $typedDegree");
    print("    Bio: $typedBio");
    print("    Availability Time: $typedAvailabilityTime");

    // 4) Validate the required fields
    final missingEmail = !_isGmailRegistration && typedEmail.isEmpty;
    final missingPassword = !_isGmailRegistration && typedPassword.isEmpty;
    if (missingEmail ||
        typedName.isEmpty ||
        typedPhone.isEmpty ||
        typedSpecialty.isEmpty ||
        typedDegree.isEmpty ||
        missingPassword) {
      setState(() {
        _statusMessage = "يرجى ملء جميع الحقول المطلوبة.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Required fields validation failed.");
      return;
    }

    try {
      // 5) Create user with role = "therapist"
      print(">>> [DEBUG] Creating therapist user with email: $typedEmail");
      final createdUser = await doctorProvider.createUser(
        email: typedEmail,
        fullName: typedName,
        password: typedPassword,
        role: "therapist",

        /// <--- Important difference!
        phoneNumber: typedPhone,
        gps_location: _gpsLocation ?? "33.3152,44.3661",
        gender: typedGender,
        firebaseUid:
            _isGmailRegistration ? widget.userCredentials!['uid'] : null,
      );

      if (createdUser == null || createdUser.id == null) {
        setState(() {
          _statusMessage = "Failed to create therapist user.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Therapist user creation failed.");
        return;
      }
      print(">>> [DEBUG] Therapist user created with ID=${createdUser.id}");

      // 6) If NOT Gmail => normal authentication to get JWT token
      ///authenicate
      // 4) If using Gmail => link the Firebase UID, else authenticate
      if (_isGmailRegistration && _firebaseUid != null) {
        await _sendFirebaseAuth(
            typedEmail, _firebaseUid!, typedPassword, context);
      } else {
        final token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);

        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "Failed to authenticate therapist user.";
            _isLoading = false;
          });
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
      }

      // 8) Create the therapist record in your backend
      print(">>> [DEBUG] Creating therapist record...");
      final therapistProvider =
          Provider.of<TherapistRetroDisplayGetProvider>(context, listen: false);
      final createdTherapist = await therapistProvider.createTherapist(
        userModel: createdUser,
        specialty: typedSpecialty,
        bio: typedBio,
        // If your user picked a city/district in the same step,
        // combine them into typedAddress or do "city - district":
        address: typedAddress,
        availabilityTime: typedAvailabilityTime, // from your parent state
        // Or any other fields: degrees, advertisePrice, etc.
      );

      if (createdTherapist == null || createdTherapist.id == null) {
        setState(() {
          _statusMessage = "Failed to create therapist record on server.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Therapist record creation failed.");
        return;
      }
      print(">>> [DEBUG] Therapist record created: ${createdTherapist.id}");

      // 9) Upload profile image (if any)
      if (_profileImage != null && _profileImage!.existsSync()) {
        print(">>> [DEBUG] Uploading doctor profile image...");
        await _uploadProfileImage(_profileImage!, createdUser.id!);
      } else {
        print("❌ No profile image to upload or file does not exist.");
      }
      // 10) Save user info so we remain logged in after restart
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", createdUser.id!);
      await prefs.setString("full_name", createdUser.fullName ?? "");
      await prefs.setString("email", createdUser.email ?? "");
      await prefs.setString("therapist_id", createdTherapist.id!); // doctor PK
      await prefs.setString("role", "therapist");
      await prefs.setBool("isRegistered", true);
      print(">>> [DEBUG] Therapist info saved in SharedPreferences.");

      // 11) Navigate to therapist dashboard
      setState(() {
        _statusMessage =
            "تم إنشاء المعالج الطبيعي بنجاح برقم المعرف: ${createdTherapist.id}";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => ResponsiveTherapistDashboard(
                userType: 'therapist',
                userId: createdUser.id!,
                therapistId: createdTherapist.id!, // The doctor PK
                userName: createdUser.fullName ?? 'Therapist')),
      );

      print(">>> [DEBUG] Navigation to therapist dashboard completed.");
    } catch (e) {
      print(">>> [DEBUG] Exception in _submitTherapist: $e");
      setState(() => _statusMessage = "Error(therapist): $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitBeautician() async {
    setState(() => _isLoading = true);
    print(">>> [DEBUG] Starting _submitBeautician process");

    // A) Validate the specialized form
    final beautyFormKey = _specializedFormKeys['beauty_center'];
    if (beautyFormKey != null && !beautyFormKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      print(">>> [DEBUG] BeautyCentersFields validation failed.");
      return;
    }

    // B) Validate availability time
    if (typedAvailabilityTime.isEmpty) {
      setState(() {
        _statusMessage = "يرجى تحديد وقت العمل.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Availability Time is empty. Cannot proceed.");
      return;
    }

    // C) Gather top-level user inputs
    final typedEmail = _isGmailRegistration
        ? (widget.userCredentials?['email'] ?? '')
        : _emailController.text.trim();
    final typedName = _nameController.text.trim();
    final typedPassword =
        _isGmailRegistration ? "10000001" : _passwordController.text.trim();
    final typedPhone = _phoneController.text.trim();
    final typedGender = (selectedGender == 0) ? 'm' : 'f';
    final typedAddress = "$selectedCity - $selectedDistrict";

    // D) Get fields from the child widget
    final beautyState = _beauticianFieldsKey.currentState;
    if (beautyState == null) {
      setState(() {
        _statusMessage = "تعذر الوصول إلى بيانات مركز التجميل.";
        _isLoading = false;
      });
      print(">>> [DEBUG] BeautyCentersFieldsState is null.");
      return;
    }

    final typedCenterName = beautyState.centerName;
    final typedBio = beautyState.bio;

    print(">>> [DEBUG] _submitBeautician with: "
        "Email=$typedEmail, Name=$typedName, Password=${typedPassword.isEmpty ? 'EMPTY' : 'PROVIDED'}, "
        "Phone=$typedPhone, Gender=$typedGender, "
        "CenterName=$typedCenterName, Bio=$typedBio, "
        "Availability=$typedAvailabilityTime");

    // E) Validate required fields
    final missingEmail = !_isGmailRegistration && typedEmail.isEmpty;
    final missingPassword = !_isGmailRegistration && typedPassword.isEmpty;
    if (missingEmail ||
        typedName.isEmpty ||
        typedPhone.isEmpty ||
        missingPassword) {
      setState(() {
        _statusMessage = "يرجى ملء جميع الحقول المطلوبة.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Required fields validation failed.");
      return;
    }

    try {
      // 1) Create user with role = "beauty_center" (or "beautician")
      print(">>> [DEBUG] Creating user with role=beauty_center...");
      final createdUser = await doctorProvider.createUser(
        email: typedEmail,
        fullName: typedName,
        password: typedPassword,
        // change "doctor" -> "beauty_center" to match your backend
        role: "beauty_center",
        phoneNumber: typedPhone,
        gps_location: _gpsLocation ?? "33.3152,44.3661",
        gender: typedGender,
        firebaseUid:
            _isGmailRegistration ? widget.userCredentials!['uid'] : null,
      );

      if (createdUser == null || createdUser.id == null) {
        setState(() {
          _statusMessage = "إنشاء المستخدم (Beautician) فشل.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create beautician user.");
        return;
      }
      print(">>> [DEBUG] Beautician user created: ${createdUser.id}");

      // 2) If not Gmail => authenticate to get token
      String? token;
      if (!_isGmailRegistration) {
        print(">>> [DEBUG] Authenticating user (Beautician)...");
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "تعذر تسجيل الدخول تلقائياً (Beautician).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Beautician user authentication failed.");
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
        // Update the beauty center provider's header so it has "JWT <token>"
        final beautyCenterProvider =
            Provider.of<BeautyCentersRetroDisplayGetProvider>(context,
                listen: false);
        beautyCenterProvider.updateToken(token);

        Provider.of<TokenProvider>(context, listen: false).updateToken(token);
        print(">>> [DEBUG] Beautician token saved (email flow).");
      }

      // 3) If Gmail => link Firebase UID
      if (_isGmailRegistration && _firebaseUid != null) {
        print(
            ">>> [DEBUG] Linking Gmail beautician with Firebase UID: $_firebaseUid");
        token = await _sendFirebaseAuth(
            typedEmail, _firebaseUid!, typedPassword, context);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل ربط حساب Gmail. لم يتم إنشاء مركز التجميل.";
            _isLoading = false;
          });
          print(">>> [DEBUG] Linking Firebase UID failed for beautician.");
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        final beautyCenterProvider =
            Provider.of<BeautyCentersRetroDisplayGetProvider>(context,
                listen: false);
        beautyCenterProvider.updateToken(token);

        Provider.of<TokenProvider>(context, listen: false).updateToken(token);
        print(">>> [DEBUG] Beautician token saved (Gmail flow).");
      } else if (token == null) {
        // If we come here and token is still null => re-auth
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل التحقق من المستخدم (Beautician).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Re-auth for beautician user failed.");
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        final beautyCenterProvider =
            Provider.of<BeautyCentersRetroDisplayGetProvider>(context,
                listen: false);
        beautyCenterProvider.updateToken(token);

        print(">>> [DEBUG] Beautician token re-confirmed.");
      }

      // 4) Create the beauty center record
      print(">>> [DEBUG] Creating beauty center record...");
      final beautyCenterProvider =
          Provider.of<BeautyCentersRetroDisplayGetProvider>(context,
              listen: false);

      // Omit the "profile_image" from your JSON to avoid "not a file" error
      final createdBeautyCenter =
          await beautyCenterProvider.createBeautyCenters(
        userModel: createdUser,
        centerName: typedCenterName,
        bio: typedBio,
        availabilityTime: typedAvailabilityTime,
        phoneNumber: typedPhone,
        address: typedAddress,
        gpsLocation: _gpsLocation,
        profileImage: null, // skip passing the image path as raw JSON
      );

      if (createdBeautyCenter == null || createdBeautyCenter.id == null) {
        setState(() {
          _statusMessage = "فشل إنشاء حساب مركز التجميل.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create beauty center record.");
        return;
      }
      print(">>> [DEBUG] Beauty center created: ${createdBeautyCenter.id}");

      // 5) (Optional) If you want to upload a real file, do it in a separate step
      // if (_profileImage != null) {
      //   print(">>> [DEBUG] Uploading beautician profile image via multipart...");
      //   try {
      //     await _uploadBeauticianImage(_profileImage!, createdBeautyCenter.id!);
      //   } catch (e) {
      //     print(">>> [ERROR] Beautician image upload failed: $e");
      //     setState(() {
      //       _statusMessage = "تم الإنشاء لكن فشل رفع الصورة";
      //     });
      //   }
      // }
      if (_profileImage != null && _profileImage!.existsSync()) {
        print(">>> [DEBUG] Uploading doctor profile image...");
        await _uploadProfileImage(_profileImage!, createdUser.id!);
      } else {
        print("❌ No profile image to upload or file does not exist.");
      }
      // 6) Save user info in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", createdUser.id!);
      await prefs.setString("full_name", createdUser.fullName ?? "");
      await prefs.setString("email", createdUser.email ?? "");
      await prefs.setString(
          "beautycenter_id", createdBeautyCenter.id!); // doctor PK
      // Same role you used in createUser:
      await prefs.setString("role", "beauty_center");
      await prefs.setBool("isRegistered", true);

      print(">>> [DEBUG] User info saved in SharedPreferences.");

      // 7) Navigate to beauty center dashboard
      setState(() {
        _statusMessage =
            "تم إنشاء مركز التجميل بنجاح برقم المعرف: ${createdBeautyCenter.id}";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => ResponsiveBeautyDashboard(
                  userType: 'beauty_center',
                  userId: createdUser.id!,
                  userName: createdUser.fullName ?? 'Beauty-center',
                  beautyId: createdBeautyCenter.id!,
                )),
      );
      print(">>> [DEBUG] Navigation to beauty center dashboard completed.");
    } catch (e) {
      print(">>> [DEBUG] Exception in _submitBeautician: $e");
      setState(() => _statusMessage = "Error (Beautician): $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

////////////////////////////////////////
  ///خطوات شرح كيفية عمل الصحيح للفنكشنات والحقول
  ///1- الخلل في  ضغط زر المتابعة يكون بسبب_onStepContinue
  /// اذهب لملف الوورد على سطح المكتب
///////////////////////////////
  ///Creating Pharmacy
  Future<void> _submitPharmacy() async {
    setState(() => _isLoading = true);
    print(">>> [DEBUG] Starting pharmacy registration process");

    // 1) Validate specialized pharmacist form
    final pharmacyFormKey = _specializedFormKeys['pharmacist'];
    // if (pharmacyFormKey != null &&
    //     !(pharmacyFormKey.currentState?.validate() ?? false)) {
    //   setState(() {
    //     _statusMessage = "يرجى تصحيح الأخطاء في نموذج الصيدلية";
    //     _isLoading = false;
    //   });
    //   print(">>> [DEBUG] Pharmacy form validation failed");
    //   return;
    // }

    // 2) Gather specialized fields from PharmacistFields
    final pharmacyState = _pharmacyFieldsKey.currentState;
    if (pharmacyState == null) {
      setState(() {
        _statusMessage = "حصل خطأ أثناء جلب بيانات نموذج الصيدلية";
        _isLoading = false;
      });
      print(">>> [DEBUG] PharmacistFieldsState is null, cannot proceed.");
      return;
    }

    final typedPharmacyName = pharmacyState.pharmacyName;
    final typedBio = pharmacyState.bio;
    final typedPharmacyPhone = pharmacyState.phone;
    final isNightPharmacy = pharmacyState.sentinel;

    // 3) Validate typedAvailabilityTime if you want:
    if (typedAvailabilityTime.isEmpty) {
      setState(() {
        _statusMessage = "يرجى تحديد وقت العمل.";
        _isLoading = false;
      });
      print(">>> [DEBUG] Availability Time is empty. Cannot proceed.");
      return;
    }

    // 4) Gather top-level (common) user info
    final typedEmail = _isGmailRegistration
        ? (widget.userCredentials?['email'] ?? '')
        : _emailController.text.trim();
    final typedName = _nameController.text.trim();
    final typedPassword =
        _isGmailRegistration ? "10000001" : _passwordController.text.trim();
    final typedGender = (selectedGender == 0) ? 'm' : 'f';
    final typedAddress = "$selectedCity - $selectedDistrict";
    final typedGpsLocation = _gpsLocation ?? "33.3152,44.3661";

    print(">>> [DEBUG] _submitPharmacy with:"
        "\n   PharmacyName=$typedPharmacyName"
        "\n   Bio=$typedBio"
        "\n   Phone=$typedPharmacyPhone"
        "\n   isNightPharmacy=$isNightPharmacy"
        "\n   Email=$typedEmail"
        "\n   Name=$typedName"
        "\n   Password=${typedPassword.isEmpty ? 'EMPTY' : 'PROVIDED'}"
        "\n   Gender=$typedGender"
        "\n   Address=$typedAddress"
        "\n   GPS=$typedGpsLocation");

    // 5) Validate required fields (like Nurse flow)
    final missingEmail = !_isGmailRegistration && typedEmail.isEmpty;
    final missingPassword = !_isGmailRegistration && typedPassword.isEmpty;
    if (missingEmail ||
        typedName.isEmpty ||
        typedPharmacyPhone.isEmpty ||
        missingPassword) {
      setState(() {
        _statusMessage =
            "يرجى ملء جميع الحقول المطلوبة (البريد، الاسم، الهاتف، الخ..)";
        _isLoading = false;
      });
      print(">>> [DEBUG] Required fields validation failed.");
      return;
    }

    try {
      // 6) Create user with role=pharmacist
      final doctorProvider =
          Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
      print(">>> [DEBUG] Creating user with role=pharmacist...");
      final createdUser = await doctorProvider.createUser(
        email: typedEmail,
        fullName: typedName,
        password: typedPassword,
        role: "pharmacist", // The server expects pharmacist
        phoneNumber: typedPharmacyPhone, // from specialized form
        gps_location: typedGpsLocation,
        gender: typedGender,
        firebaseUid:
            _isGmailRegistration ? widget.userCredentials!['uid'] : null,
      );

      if (createdUser == null || createdUser.id == null) {
        setState(() {
          _statusMessage = "إنشاء المستخدم (Pharmacist) فشل.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create pharmacist user.");
        return;
      }
      print(">>> [DEBUG] Pharmacist user created: ${createdUser.id}");

      // 7) If not Gmail => authenticate user (Pharmacist)
      String? token;
      if (!_isGmailRegistration) {
        print(">>> [DEBUG] Authenticating user (Pharmacist)...");
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "تعذر تسجيل الدخول تلقائياً (Pharmacist).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Pharmacist user authentication failed.");
          return;
        }

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        // CRUCIAL: Update the Pharma provider's dio header
        final pharmacistProvider =
            Provider.of<PharmaRetroDisplayGetProvider>(context, listen: false);
        pharmacistProvider.dio.options.headers["Authorization"] = "JWT $token";

        Provider.of<TokenProvider>(context, listen: false).updateToken(token);
        print(">>> [DEBUG] Pharmacist token saved (email flow).");
      }

// 8) If Gmail => link Firebase UID
      if (_isGmailRegistration && _firebaseUid != null) {
        print(
            ">>> [DEBUG] Linking Gmail Pharmacist with Firebase UID: $_firebaseUid");
        token = await _sendFirebaseAuth(
            typedEmail, _firebaseUid!, typedPassword, context);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل ربط حساب Gmail. لم يتم إنشاء الصيدلية.";
            _isLoading = false;
          });
          print(">>> [DEBUG] Linking Firebase UID failed for pharmacist.");
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        // Again, update the dio header
        final pharmacistProvider =
            Provider.of<PharmaRetroDisplayGetProvider>(context, listen: false);
        pharmacistProvider.dio.options.headers["Authorization"] = "JWT $token";

        Provider.of<TokenProvider>(context, listen: false).updateToken(token);
        print(">>> [DEBUG] Pharmacist token saved (Gmail flow).");
      } else if (token == null) {
        // If we come here and token is still null => re-auth
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل التحقق من المستخدم (Pharmacist).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Re-auth for pharmacist user failed.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        // Must set the header again
        final pharmacistProvider =
            Provider.of<PharmaRetroDisplayGetProvider>(context, listen: false);
        pharmacistProvider.dio.options.headers["Authorization"] = "JWT $token";

        print(">>> [DEBUG] Pharmacist token re-confirmed.");
      }

      // 9) Create pharmacy record
      final pharmacistProvider =
          Provider.of<PharmaRetroDisplayGetProvider>(context, listen: false);
      print(">>> [DEBUG] Creating pharmacy record...");

      final createdPharmacy = await pharmacistProvider.createPharmacy(
        userModel: createdUser,
        pharmacyName: typedPharmacyName,
        address: typedAddress,
        gpsLocation: typedGpsLocation,
        bio: typedBio,
        sentinel: isNightPharmacy,
      );

      if (createdPharmacy == null || createdPharmacy.id == null) {
        setState(() {
          _statusMessage = "فشل إنشاء حساب الصيدلية.";
          _isLoading = false;
        });
        print(">>> [DEBUG] Failed to create pharmacy record.");
        return;
      }
      print(">>> [DEBUG] Pharmacy created: ${createdPharmacy.id}");



      // 10) Upload profile image if available
      // if (_profileImage != null) {
      //   print(">>> [DEBUG] Uploading pharmacy profile image...");
      //   try {
      //     await _uploadPharmacyImage(_profileImage!, createdPharmacy.id!);
      //   } catch (e) {
      //     print(">>> [ERROR] Pharmacy image upload failed: $e");
      //     setState(() => _statusMessage = "تم الإنشاء لكن فشل رفع الصورة");
      //   }
      // }
      // 5) Upload profile image if provided.
      if (_profileImage != null && _profileImage!.existsSync()) {
        print(">>> [DEBUG] Uploading doctor profile image...");
        await _uploadProfileImage(_profileImage!, createdUser.id!);
      } else {
        print("❌ No profile image to upload or file does not exist.");
      }

      // 11) Save user info so user remains logged in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", createdUser.id!);
      await prefs.setString("full_name", createdUser.fullName ?? "");
      await prefs.setString("email", createdUser.email ?? "");
      await prefs.setString("pharmacy_id", createdPharmacy.id!); // doctor PK
      await prefs.setString("role", "pharmacist");
      await prefs.setBool("isRegistered", true);

      print(">>> [DEBUG] Pharmacist info saved in SharedPreferences.");

      setState(() {
        _statusMessage =
            "تم إنشاء الصيدلية بنجاح برقم المعرف: ${createdPharmacy.id}";
      });

      // 12) Navigate to pharmacy dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => ResponsivePharmacyDashboard(
                userType: 'pharmacist',
                userId: createdUser.id!,
                userName: createdUser.fullName ?? 'Pharmacist',
                pharmaId: createdPharmacy.id!)),
      );
      print(">>> [DEBUG] Navigation to pharmacy dashboard completed.");
    } catch (e, stack) {
      print(">>> [DEBUG] Exception in _submitPharmacy: $e");
      print("Stack trace: $stack");
      setState(() => _statusMessage = "Error(pharmacy): $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  ///Creating Labs
  /// (A) _submitLab()
  Future<void> _submitLab() async {
    setState(() => _isLoading = true);
    print(">>> [DEBUG][START] Laboratory submission initiated");

    try {
      // 1. Validate Laboratory-specific form using the correct key 'labrotary'
      print(">>> [DEBUG][VALIDATION] Checking laboratory form validation");
      final labFormKey = _specializedFormKeys['labrotary']!;
      if (!(labFormKey.currentState?.validate() ?? false)) {
        print(">>> [DEBUG][VALIDATION FAIL] Laboratory form validation failed");
        setState(() {
          _statusMessage = "يرجى ملء جميع حقول المختبر المطلوبة";
          _isLoading = false;
        });
        return;
      }

      // 2. Validate parent fields (city, district, availability)
      print("""
    >>> [DEBUG][PARENT FIELDS] Checking parent fields:
    City: '$selectedCity'
    District: '$selectedDistrict'
    Availability: '$typedAvailabilityTime'
    """);
      if (selectedCity.isEmpty ||
          selectedDistrict.isEmpty ||
          typedAvailabilityTime.isEmpty) {
        print(">>> [DEBUG][VALIDATION FAIL] Parent fields validation failed");
        setState(() {
          _statusMessage = "يرجى تحديد الموقع ووقت العمل";
          _isLoading = false;
        });
        return;
      }

      // 3. Gather Laboratory-specific data from the LaboratoryFields widget
      final labState = _labFieldsKey.currentState!;
      final labData = {
        'name': labState.labNameController.text.trim(),
        'available_tests': labState.availableTestsController.text.trim(),
        'bio': labState.bioController.text.trim(),
        'phone': labState.phoneController.text.trim(),
      };

      print(">>> [DEBUG] Laboratory Data: $labData");

      // 4. Ensure none of these fields are empty
      if (labData.values.any((v) => v.isEmpty)) {
        print(
            ">>> [DEBUG][VALIDATION FAIL] Laboratory fields validation failed");
        setState(() {
          _statusMessage = "يرجى ملء جميع حقول المختبر المطلوبة";
          _isLoading = false;
        });
        return;
      }

      // 5. Create a user with role "laboratory"
      final typedEmail = _isGmailRegistration
          ? (widget.userCredentials?['email'] ?? '')
          : _emailController.text.trim();
      final typedName = _nameController.text.trim();
      final typedPassword =
          _isGmailRegistration ? "10000001" : _passwordController.text.trim();
      final typedPhone = labData['phone']!;
      final typedGender = (selectedGender == 0) ? 'm' : 'f';

      print(">>> [DEBUG][USER CREATION] Creating user with role=laboratory...");
      final createdUser = await doctorProvider.createUser(
        email: typedEmail,
        fullName: typedName,
        password: typedPassword,
        role: "laboratory", // or "laboratory" if your API expects that
        phoneNumber: typedPhone,
        gps_location: _gpsLocation ?? "33.3152,44.3661",
        gender: typedGender,
        firebaseUid:
            _isGmailRegistration ? widget.userCredentials!['uid'] : null,
      );

      if (createdUser?.id == null) {
        print(
            ">>> [DEBUG][ERROR] User creation failed: ${createdUser?.toJson()}");
        setState(() {
          _statusMessage = "فشل إنشاء المستخدم الأساسي (للمختبر)";
          _isLoading = false;
        });
        return;
      }
      print(">>> [DEBUG] Lab user created: ${createdUser!.id}");

      // 6. Authenticate or link Gmail (similar to your existing logic)
      String? token;
      if (!_isGmailRegistration) {
        print(">>> [DEBUG] Authenticating user (Lab)...");
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "تعذر تسجيل الدخول تلقائياً (المختبر).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Lab user authentication failed.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
        final labsProvider =
            Provider.of<LabsRetroDisplayGetProvider>(context, listen: false);
        labsProvider.updateToken(token);
        print(">>> [DEBUG] Lab token saved (email flow).");
      } else if (_isGmailRegistration && _firebaseUid != null) {
        print(">>> [DEBUG] Linking Gmail Lab with Firebase UID: $_firebaseUid");
        token = await _sendFirebaseAuth(
            typedEmail, _firebaseUid!, typedPassword, context);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل ربط حساب Gmail بالمختبر.";
            _isLoading = false;
          });
          print(">>> [DEBUG] Linking Firebase UID failed for lab user.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
        final labsProvider =
            Provider.of<LabsRetroDisplayGetProvider>(context, listen: false);
        labsProvider.updateToken(token);
        print(">>> [DEBUG] Lab token saved (Gmail flow).");
      } else if (token == null) {
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل التحقق من المستخدم (المختبر).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Re-auth lab user failed.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);
        final labsProvider =
            Provider.of<LabsRetroDisplayGetProvider>(context, listen: false);
        labsProvider.updateToken(token);
        print(">>> [DEBUG] Lab token re-confirmed.");
      }

      // 7. Create laboratory record
      final labsProvider =
          Provider.of<LabsRetroDisplayGetProvider>(context, listen: false);
      print(
          ">>> [DEBUG][LABORATORY CREATION] Creating laboratory with userID=${createdUser.id}");
      final labResponse = await labsProvider.createLaboratory(
        userModel: createdUser,
        laboratoryName: labData['name']!,
        availableTests: labData['available_tests']!,
        bio: labData['bio']!,
        availabilityTime: typedAvailabilityTime,
        phoneNumber: labData['phone']!,
        address: "$selectedCity - $selectedDistrict",
        gpsLocation: _gpsLocation,
        profileImage: null, // If you want, handle image upload separately
      );

      if (labResponse == null || labResponse.id == null) {
        print(
            ">>> [DEBUG][ERROR] Laboratory creation failed. Response: ${labResponse?.toJson()}");
        setState(() {
          _statusMessage = "فشل إنشاء سجل المختبر";
          _isLoading = false;
        });
        return;
      }
      print(">>> [DEBUG] Laboratory record created: ${labResponse.id}");

      // 8. (Optional) Upload lab profile image separately if available
      if (_profileImage != null && _profileImage!.existsSync()) {
        print(">>> [DEBUG] Uploading doctor profile image...");
        await _uploadProfileImage(_profileImage!, createdUser.id!);
      } else {
        print("❌ No profile image to upload or file does not exist.");
      }

      // 9. Save user session
      print(">>> [DEBUG][SESSION] Saving user session data");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", createdUser.id!);
      await prefs.setString("labrotary", labResponse.id!);
      await prefs.setString("labrotary_id", labResponse.id!); // doctor PK
      await prefs.setString("role", "lab");
      await prefs.setBool("isRegistered", true);

      // 10. Navigate to Lab Dashboard
      print(">>> [DEBUG][NAVIGATION] Redirecting to dashboard");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => ResponsiveLabrotaryDashboard(
            userType: 'laboratory',
            userId: createdUser.id!,
            userName: createdUser.fullName ?? 'laboratory',
            labrotaryId: '',
          ),
        ),
      );
    } on DioException catch (e) {
      print("""
    >>> [DEBUG][DIO ERROR] 
    Status: ${e.response?.statusCode}
    Message: ${e.message}
    Response: ${e.response?.data}
    Stack: ${e.stackTrace}
    """);
      final errorMessage = e.response?.data?['detail'] ?? e.message;
      setState(() => _statusMessage = "خطأ في الخادم: $errorMessage");
    } catch (e, stack) {
      print("""
    >>> [DEBUG][UNKNOWN ERROR] 
    Error: $e
    Stack: $stack
    """);
      setState(() => _statusMessage = "خطأ غير متوقع: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
      print(">>> [DEBUG][END] Laboratory submission process completed");
    }
  }

  /// Creating Hospitals
  ///       ///مشكلة رابط المستشفى باليوزر وممسوي رول كمستشفى
  Future<void> _submithospital() async {
    setState(() => _isLoading = true);
    print(">>> [DEBUG][START] Hospital submission initiated");

    try {
      print(">>> [_submithospital] Current _profileImage: $_profileImage");

      // 1. Validate Hospital-specific form
      print(">>> [DEBUG][VALIDATION] Checking hospital form validation");
      final hospitalFormKey = _specializedFormKeys['hospital']!;

      if (!(hospitalFormKey.currentState?.validate() ?? false)) {
        print(">>> [DEBUG][VALIDATION FAIL] Hospital form validation failed");
        setState(() {
          _statusMessage = "يرجى ملء جميع الحقول المطلوبة بشكل صحيح.";
          _isLoading = false;
        });
        return;
      }

      // 2. Validate city/district & typedAvailabilityTime
      print("""
    >>> [DEBUG][PARENT FIELDS] Checking parent fields:
    City: '$selectedCity'
    District: '$selectedDistrict'
    Availability: '$typedAvailabilityTime'
    """);
      if (selectedCity.isEmpty ||
          selectedDistrict.isEmpty ||
          typedAvailabilityTime.isEmpty) {
        print(">>> [DEBUG][VALIDATION FAIL] Parent fields validation failed");
        setState(() {
          _statusMessage = "يرجى تحديد الموقع ووقت العمل";
          _isLoading = false;
        });
        return;
      }

      // 3. Get Hospital-specific data
      print(">>> [DEBUG][DATA RETRIEVAL] Retrieving hospital fields state");
      final hospitalState = _hospitalFieldsKey.currentState!;

      final hospitalData = {
        'name': hospitalState.hospitalNameController.text.trim(),
        'specialty': hospitalState.selectedSpecialty,
        'administration': hospitalState.administrationController.text.trim(),
        'bio': hospitalState.bioController.text.trim(),
        'phone': hospitalState.phoneController.text.trim(),
      };

      print(">>> [DEBUG] Hospital Data: $hospitalData");

      // 4. Validate required hospital fields
      if (hospitalData.values.any((v) => v.isEmpty)) {
        print(">>> [DEBUG][VALIDATION FAIL] Hospital fields validation failed");
        setState(() {
          _statusMessage = "يرجى ملء جميع حقول المستشفى المطلوبة";
          _isLoading = false;
        });
        return;
      }

      // 5. Create user with role="hospital"
      final typedEmail = _isGmailRegistration
          ? (widget.userCredentials?['email'] ?? '')
          : _emailController.text.trim();
      final typedName = _nameController.text.trim();
      final typedPassword =
          _isGmailRegistration ? "10000001" : _passwordController.text.trim();
      final typedPhone = hospitalData['phone']!;
      final typedGender = (selectedGender == 0) ? 'm' : 'f';

      print(">>> [DEBUG][USER CREATION] Creating user with role=hospital...");
      final createdUser = await doctorProvider.createUser(
        email: typedEmail,
        fullName: typedName,
        password: typedPassword,
        role: "hospital", // or "hospital" if your backend expects that
        phoneNumber: typedPhone,
        gps_location: _gpsLocation ?? "40.7128,-74.0060",
        gender: typedGender,
        firebaseUid:
            _isGmailRegistration ? widget.userCredentials!['uid'] : null,
      );

      if (createdUser?.id == null) {
        print(
            ">>> [DEBUG][ERROR] User creation failed: ${createdUser?.toJson()}");
        setState(() {
          _statusMessage = "فشل إنشاء المستخدم الأساسي (مستشفى)";
          _isLoading = false;
        });
        return;
      }
      print(">>> [DEBUG] Hospital user created with ID=${createdUser!.id}");

      // 6. If not Gmail => authenticate
      String? token;
      if (!_isGmailRegistration) {
        print(">>> [DEBUG] Authenticating user (Hospital)...");
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "تعذر تسجيل الدخول تلقائياً (Hospital).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Hospital user authentication failed.");
          return;
        }

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        // Update hospital provider's header
        final hospitalProvider = Provider.of<HospitalRetroDisplayGetProvider>(
            context,
            listen: false);
        hospitalProvider
            .updateToken(token); // We'll define updateToken(...) below

        print(">>> [DEBUG] Hospital token saved (email flow).");
      }

      // 7. If Gmail => link Firebase UID
      if (_isGmailRegistration && _firebaseUid != null) {
        print(
            ">>> [DEBUG] Linking Gmail Hospital with Firebase UID: $_firebaseUid");
        token = await _sendFirebaseAuth(
            typedEmail, _firebaseUid!, typedPassword, context);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل ربط حساب Gmail. لم يتم إنشاء المستشفى.";
            _isLoading = false;
          });
          print(">>> [DEBUG] Linking Firebase UID failed for hospital user.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        // Update hospital provider's header
        final hospitalProvider = Provider.of<HospitalRetroDisplayGetProvider>(
            context,
            listen: false);
        hospitalProvider.updateToken(token);

        print(">>> [DEBUG] Hospital token saved (Gmail flow).");
      } else if (token == null) {
        // If we still have no token => re-auth
        token =
            await doctorProvider.authenticateUser(typedEmail, typedPassword);
        if (token == null || token.isEmpty) {
          setState(() {
            _statusMessage = "فشل التحقق من المستخدم (Hospital).";
            _isLoading = false;
          });
          print(">>> [DEBUG] Re-auth for hospital user failed.");
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", token);

        final hospitalProvider = Provider.of<HospitalRetroDisplayGetProvider>(
            context,
            listen: false);
        hospitalProvider.updateToken(token);

        print(">>> [DEBUG] Hospital token re-confirmed.");
      }

      // 8. Create hospital record
      print(">>> [DEBUG][HOSPITAL CREATION] Creating hospital record...");
      final hospitalProvider =
          Provider.of<HospitalRetroDisplayGetProvider>(context, listen: false);

      // Omit "profile_image" from the JSON unless you do multipart
      final hospitalResponse = await hospitalProvider.createHospital(
        userModel: createdUser,
        hospitalName: hospitalData['name']!,
        specialty: hospitalData['specialty']!,
        administration: hospitalData['administration']!,
        bio: hospitalData['bio']!,
        availabilityTime: typedAvailabilityTime,
        phoneNumber: hospitalData['phone']!,
        address: "$selectedCity - $selectedDistrict",
        gpsLocation: _gpsLocation,

        // skip the "profile_image" param to avoid error
        profileImage: null,
      );

      if (hospitalResponse == null || hospitalResponse.id == null) {
        print(
            ">>> [DEBUG][ERROR] Hospital creation failed. Response: ${hospitalResponse?.toJson()}");
        setState(() {
          _statusMessage = "فشل إنشاء سجل المستشفى";
          _isLoading = false;
        });
        return;
      }
      print(">>> [DEBUG] Hospital record created: ${hospitalResponse.id}");

      // 9. (Optional) Upload an image separately if needed
      if (_profileImage != null && _profileImage!.existsSync()) {
        print(">>> [DEBUG] Uploading doctor profile image...");
        await _uploadProfileImage(_profileImage!, createdUser.id!);
      } else {
        print("❌ No profile image to upload or file does not exist.");
      }


      // 10. Save user session
      print(">>> [DEBUG][SESSION] Saving user session data");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", createdUser.id!);
      await prefs.setString("hospital", hospitalResponse.id!); // doctor PK

      await prefs.setString("role", "hospital");
      await prefs.setBool("isRegistered", true);

      // 11. Navigate to hospital dashboard
      print(">>> [DEBUG][NAVIGATION] Redirecting to hospital dashboard");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => ResponsiveHospitalDashboard(
                  userType: 'hospital',
                  userId: createdUser.id!,
                  userName: createdUser.fullName ?? 'Hospital',
                  hospitalId: hospitalResponse.id!, //
                )),
      );
    } on DioException catch (e) {
      print("""
    >>> [DEBUG][DIO ERROR] 
    Status: ${e.response?.statusCode}
    Message: ${e.message}
    Response: ${e.response?.data}
    Stack: ${e.stackTrace}
    """);
      final errorMessage = e.response?.data?['detail'] ?? e.message;
      setState(() => _statusMessage = "خطأ في الخادم: $errorMessage");
    } catch (e, stack) {
      print("""
    >>> [DEBUG][UNKNOWN ERROR] 
    Error: $e
    Stack: $stack
    """);
      setState(() => _statusMessage = "خطأ غير متوقع: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
      print(">>> [DEBUG][END] Submission process completed");
    }
  }

  ///Creating Medical Centers
  Future<void> _submitMedicalCenter() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });
    print('>>> [MEDICAL-CENTER] single-POST flow');

    // 1) VALIDATE
    if (_directorNameController.text.trim().isEmpty ||
        _bioController.text.trim().isEmpty) {
      _setError('يرجى إدخال اسم المدير والسيرة الذاتية للمركز الطبي.');
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _setError('يرجى ملء جميع الحقول المطلوبة بشكل صحيح.');
      return;
    }

    // 2) COLLECT INPUTS
    final email        = _emailController.text.trim();
    final password     = _passwordController.text.trim();
    final fullName     = _nameController.text.trim();
    final phone        = _phoneController.text.trim();
    final gender       = (selectedGender == 0) ? 'm' : 'f';
    final gps          = _gpsLocation ?? '33.3152 44.3661';
    final centerName   = _centerNameController.text.trim();
    final director     = _directorNameController.text.trim();
    final bio          = _bioController.text.trim();
    final availability = typedAvailabilityTime;
    final address      = '$selectedCity - $selectedDistrict';

    // 3) CREATE THE USER
    final doctorProv = Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
    print('>>> [POST] createUser for MedicalCenter');
    final createdUser = await doctorProv.createUser(
      email:       email,
      fullName:    fullName,
      password:    password,
      role: HspRoles.mdeidcalCenter,
      phoneNumber: phone,
      gps_location: gps,
      gender:      gender,
      firebaseUid: _isGmailRegistration ? widget.userCredentials!['uid'] : null,
    );
    if (createdUser == null || createdUser.id == null) {
      _setError('فشل إنشاء المستخدم الأساسي (مركز طبي)');
      return;
    }
    print('>>> [OK] createdUser.id=${createdUser.id}');

    // (Optional) Authenticate to get JWT
    final token = await doctorProv.authenticateUser(email, password);
    if (token == null || token.isEmpty) {
      _setError('تم إنشاء المستخدم لكن فشل تسجيل الدخول.');
      return;
    }
    await _saveToken(token);

    // 4) CREATE THE CENTER (nested user JSON)
    final centerProv = Provider.of<MedicalCentersRetroDisplayGetProvider>(context, listen: false);
    print('>>> [POST] createMedicalCenterWithUser');
    final createdCenter = await centerProv.createMedicalCenterWithUser(
      user             : createdUser.toJson(),
      centerName       : centerName,
      directorName     : director,
      bio              : bio,
      availabilityTime : availability,
      advertise        : true,
      address          : address,
      advertisePrice   : null,
      advertiseDuration: null,
      profileImage     : null,
    );
    if (createdCenter == null || createdCenter.id == null) {
      _setError('فشل إنشاء سجل المركز الطبي (انظر Console للتفاصيل).');
      return;
    }
    print('>>> [OK] createdCenter.id=${createdCenter.id}');

    // 5) UPLOAD IMAGE (optional)
    if (_profileImage != null && _profileImage!.existsSync()) {
      try {
        await _uploadProfileImage(_profileImage!, createdUser.id!);
        print('>>> [IMAGE] upload OK');
      } catch (e) {
        print('>>> [IMAGE] upload failed: $e');
        _statusMessage = 'تم الإنشاء لكن فشل رفع الصورة.';
      }
    }

    // 6) SAVE PREFS & NAVIGATE
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id',           createdUser.id!);
    await prefs.setString('medical_center_id', createdCenter.id!);
    await prefs.setString('role',              HspRoles.medicalCenter);
    await prefs.setBool('isRegistered',        true);

    await navigateToMedicalCenterDashboard(context);

    setState(() => _isLoading = false);
    print('>>> [MEDICAL-CENTER] submission done');
  }

/* ─── helpers ─── */
  void _setError(String msg) {
    setState(() {
      _statusMessage = msg;
      _isLoading = false;
    });
    print('>>> [ERROR] $msg');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Login_access_token', token);
    Provider.of<TokenProvider>(context, listen: false).updateToken(token);
  }

  Future<String?> _sendFirebaseAuth(
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

        // Make sure your server returns "access_token" or whatever key it uses
        final token = data["access_token"] as String?;
        if (token == null || token.isEmpty) {
          throw Exception("No 'access_token' found in Firebase Auth response");
        }

        // Return the actual token so _submitNurse() can store it
        return token;
      } else {
        throw Exception("Failed to send Firebase Auth data: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error sending Firebase Auth data: $e");
      return null;
    }
  }

  // ====================== IMAGE PICKING =========================

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  Future<void> _takePhoto() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error taking photo: $e");
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  /// Upload
  Future<void> _uploadProfileImage(File imageFile, String userId) async {
    try {
      if (!imageFile.existsSync()) {
        debugPrint("❌ Image file doesn't actually exist: ${imageFile.path}");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");
      if (token == null) {
        debugPrint("No token found - can't upload image");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";

      final formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(imageFile.path),
      });

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

  /// For location
  Future<void> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    final userConsent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("السماح بالدخول للموقع"),
        content: const Text("التطبيق يحتاج للدخول الى موقعك الحالي هل تسمح بذلك؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("رفض"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("سماح"),
          ),
        ],
      ),
    );
    if (userConsent != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location access denied.")),
      );
      return;
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services disabled.")),
      );
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location denied forever.")),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _gpsLocation = "${position.latitude}, ${position.longitude}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("موقعك الحالي: $_gpsLocation")),
      );
    } catch (e) {
      debugPrint("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch location.")),
      );
    }
  }

  Future<void> _uploadPharmacyImage(File imageFile, String pharmacyId) async {
    try {

      if (!imageFile.existsSync()) {
        debugPrint("❌ Image file doesn't actually exist: ${imageFile.path}");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");
      if (token == null) {
        debugPrint("No token found - can't upload image");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";

      final formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(imageFile.path,
            filename: "pharmacy_$pharmacyId.jpg"),
      });

      final response = await dio.patch(
        "https://racheeta.pythonanywhere.com/pharmacists/$pharmacyId/",
        data: formData,
      );

      if (response.statusCode == 200) {
        debugPrint("Pharmacy image uploaded successfully");
        // Update local pharmacy data if needed
      } else {
        debugPrint("Failed to upload pharmacy image: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error uploading pharmacy image: $e");
    }
  }

  ///uploading lab image
  Future<void> _uploadLabImage(File imageFile, String laboratoriesId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");
      if (token == null) {
        debugPrint("No token found - can't upload image");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";

      final formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(imageFile.path,
            filename: "pharmacy_$laboratoriesId.jpg"),
      });

      final response = await dio.patch(
        "https://racheeta.pythonanywhere.com/laboratories/$laboratoriesId/",
        data: formData,
      );

      if (response.statusCode == 200) {
        debugPrint("Pharmacy image uploaded successfully");
        // Update local pharmacy data if needed
      } else {
        debugPrint("Failed to upload pharmacy image: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error uploading pharmacy image: $e");
    }
  }

  Future<void> _uploadHospitalImage(File imageFile, String hospitalsId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");
      if (token == null) {
        debugPrint("No token found - can't upload image");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      dio.options.headers["Content-Type"] = "multipart/form-data";

      final formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(imageFile.path,
            filename: "pharmacy_$hospitalsId.jpg"),
      });

      final response = await dio.patch(
        "https://racheeta.pythonanywhere.com/hospitals/$hospitalsId/",
        data: formData,
      );

      if (response.statusCode == 200) {
        debugPrint("Pharmacy image uploaded successfully");
        // Update local pharmacy data if needed
      } else {
        debugPrint("Failed to upload pharmacy image: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error uploading pharmacy image: $e");
    }
  }
}
Future<void> navigateToMedicalCenterDashboard(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  final userId    = prefs.getString("user_id") ?? '';
  final centerId  = prefs.getString("medical_center_id") ?? '';
  final userType  = prefs.getString("role") ?? '';
  final userName  = 'مركز طبي'; // or fetch real name if stored

  if (userId.isEmpty || centerId.isEmpty) {
    debugPrint('❌ Missing user or center ID in prefs');
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResponsiveMDCenterDashboard(
        userId: userId,
        centerId: centerId,
        centerName: userName,
        userType: userType,
      ),
    ),
  );
}
