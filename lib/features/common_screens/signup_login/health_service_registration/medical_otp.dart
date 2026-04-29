import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constansts/constants.dart';
import '../../../beauty_centers/screens/beauty_profile_screen.dart';
import '../../../doctors/screens/doctor_profile_screen.dart';
import '../../../hospitals/screens/hospitals_profile_screen.dart';
import '../../../labrotary/screens/labrotary_profile.dart';
import '../../../medical_centre/screens/medical_profile_screen.dart';
import '../../../nurse/screens/nurse_profile_screen.dart';
import '../../../pharmacist/screens/pharma_profile_screen.dart';
import '../../../therapist/screens/therapist_profile_screen.dart';

class HospitalsOTP extends StatelessWidget {
  final String verificationId;
  final String role;
  final TextEditingController _otpController = TextEditingController();

  HospitalsOTP({required this.verificationId, required this.role});

  Future<void> signInWithPhoneNumber(BuildContext context) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: _otpController.text,
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

// Save the login state in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userRole', role); // Save the role as well

// Navigate to the correct profile page based on role
      Widget destinationPage;
      switch (role) {
        case 'doctor':
          destinationPage = DoctorProfilePage(
              // name: '',
              // specialty: '',
              // email: '',
              // phoneNumber: '',
              // address: '',
              // review: '',
              // experience: '',
              // qualifications: '',
              );
          break;
        case 'pharmacist':
          destinationPage = PharmacistSingleProfilePage();
          break;
        case 'hospital':
          destinationPage = HospitalSingleProfilePage();
          break;
        case 'physical therapist':
          destinationPage = TherapistSingleProfilePage();
          break;
        case 'nurse':
          destinationPage = NurseSingleProfilePage();
          break;
        case 'medical_center':
          destinationPage = MedicalCentreProfile();
          break;
        case 'lab':
        case 'laboratory':
          destinationPage = LabrotaryProfile();
          break;
        case 'beautician':
          destinationPage = BeautyCenterProfile();
          break;
        default:
          destinationPage =
              HospitalSingleProfilePage(); // Default to HospitalsProfile if role is unknown
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => destinationPage,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم التسجيل بنجاح")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حصل فشل في عملية الدخول: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'ادخال الرمز الخاص بتسجيل المستشفيات',
          style: kAppBarDoctorsTextStyle,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          TextField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'الرمز',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: kRedElevatedButtonStyle,
              onPressed: () => signInWithPhoneNumber(context),
              child: const Text('تسجيل الدخول'),
            ),
          ),
        ],
      ),
    );
  }
}
