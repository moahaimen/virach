import 'package:flutter/material.dart';

// ───────────────────────── IMPORTS ─────────────────────────
import '../../features/common_screens/signup_login/health_service_registration/beauty_centers_fields.dart';
import '../../features/common_screens/signup_login/health_service_registration/doctor_fields.dart';
import '../../features/common_screens/signup_login/health_service_registration/hospital_fields.dart';
import '../../features/common_screens/signup_login/health_service_registration/laboratory_fields.dart';
import '../../features/common_screens/signup_login/health_service_registration/medical_center_fields.dart';
import '../../features/common_screens/signup_login/health_service_registration/nurse_fields.dart';
import '../../features/common_screens/signup_login/health_service_registration/pharmacist_fields.dart';
import '../../features/common_screens/signup_login/health_service_registration/therapist_fields.dart';

// ───────────────────────── WIDGET ─────────────────────────
/// Renders the role‑specific form that lives in **Step 1 (تخصصية)** of the
/// main *CreateHSPPage* stepper.  The parent injects every `GlobalKey<FormState>`
/// via **`specializedFormKeys`** so it can validate generically.
///
/// ▸ *mdeidcal_center*  ⇢ we treat this backend typo exactly like
///   *medical_center* but keep the string unchanged so your server still works.
class SpecialFormWidget extends StatelessWidget {
  final String userType;                                        // e.g. doctor / mdeidcal_center
  final Map<String, GlobalKey<FormState>> specializedFormKeys;  // keys for every role

  // field‑widget GlobalKeys — needed so the parent can read their internal state
  final GlobalKey<DoctorFieldsState>       doctorFieldsKey;
  final GlobalKey<NurseFieldsState>        nurseFieldsKey;
  final GlobalKey<TherapistFieldsState>    therapistFieldsKey;
  final GlobalKey<PharmacistFieldsState>   pharmacyFieldsKey;
  final GlobalKey<LaboratoryFieldsState>   labFieldsKey;
  final GlobalKey<HospitalFieldsState>     hospitalFieldsKey;
  final GlobalKey<BeautyCentersFieldsState> beauticianFieldsKey;

  // ───────────── MEDICAL‑CENTER specific controllers & callbacks ─────────────
  final TextEditingController centerNameController;
  final TextEditingController directorNameController;
  final TextEditingController bioController;
  final TextEditingController phoneController;

  final String               selectedCity;
  final String               selectedDistrict;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onDistrictChanged;

  const SpecialFormWidget({
    super.key,
    required this.userType,
    required this.specializedFormKeys,
    required this.doctorFieldsKey,
    required this.nurseFieldsKey,
    required this.therapistFieldsKey,
    required this.pharmacyFieldsKey,
    required this.labFieldsKey,
    required this.hospitalFieldsKey,
    required this.beauticianFieldsKey,
    // medical‑center ↓
    required this.centerNameController,
    required this.directorNameController,
    required this.bioController,
    required this.phoneController,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.onCityChanged,
    required this.onDistrictChanged,
  });

  // Helpers for readability
  bool get _isDoctor        => userType == 'doctor';
  bool get _isNurse         => userType == 'nurse';
  bool get _isTherapist     => userType == 'therapist' || userType == 'physical-therapist';
  bool get _isPharmacist    => userType == 'pharmacist';
  bool get _isLab           => userType == 'labrotary';
  bool get _isHospital      => userType == 'hospital';
  bool get _isMedicalCenter => userType == 'medical_center' || userType == 'mdeidcal_center';
  bool get _isBeautyCenter  => userType == 'beauty_center';

  /// Returns the correct `Form` key for the current role.
  GlobalKey<FormState> get _formKeyForRole => specializedFormKeys[userType]!
      // fallback for legacy string without the typo
      ?? specializedFormKeys['medical_center']!;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_isDoctor)
            DoctorFields(
              key    : doctorFieldsKey,
              formKey: _formKeyForRole,
            ),

          if (_isNurse)
            NurseFields(
              key    : nurseFieldsKey,
              formKey: _formKeyForRole,
            ),

          if (_isTherapist)
            TherapistFields(
              key    : therapistFieldsKey,
              formKey: _formKeyForRole,
            ),

          if (_isPharmacist)
            PharmacistFields(
              key    : pharmacyFieldsKey,
              formKey: _formKeyForRole,
            ),

          if (_isLab)
            LaboratoryFields(
              key    : labFieldsKey,
              formKey: _formKeyForRole,
            ),

          if (_isHospital)
            Form(
              key : _formKeyForRole,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: HospitalFields(
                key    : hospitalFieldsKey,
                formKey: _formKeyForRole,
              ),
            ),

          if (_isMedicalCenter)
            Form(
              key : _formKeyForRole,
              child: MedicalCenterFields(
                formKey               : _formKeyForRole,
                centerNameController  : centerNameController,
                directorNameController: directorNameController,
                bioController         : bioController,
                phoneController       : phoneController,
                selectedCity          : selectedCity,
                selectedDistrict      : selectedDistrict,
                onCityChanged         : onCityChanged,
                onDistrictChanged     : onDistrictChanged,
              ),
            ),

          if (_isBeautyCenter)
            BeautyCentersFields(
              key    : beauticianFieldsKey,
              formKey: _formKeyForRole,
            ),
        ],
      ),
    );
  }
}
