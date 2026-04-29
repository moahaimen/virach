import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constansts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/doctor_profile_screen.dart';

class OTPVerificationPage extends StatelessWidget {
  final String verificationId;
  final TextEditingController _otpController = TextEditingController();

  OTPVerificationPage({required this.verificationId});

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

      // Navigate to HomeScreen after successful sign-in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DoctorProfilePage(
              // name: '',
              // specialty: '',
              // email: '',
              // phoneNumber: '',
              // address: '',
              // review: '',
              // experience: '',
              // qualifications: '',
              ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم التسجيل بنجاح")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل التسجيل: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'قم بادخال الرمز',
          style: kAppBarDoctorsTextStyle,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          TextField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'الرمز',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () => signInWithPhoneNumber(context),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
