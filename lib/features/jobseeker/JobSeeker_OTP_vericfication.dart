import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:racheeta/features/jobseeker/screens/job_seeker_side/job_seeker_profile_form.dart';
import 'package:shared_preferences/shared_preferences.dart';


class JobSeekerOTPVerificationPage extends StatelessWidget {
  final String verificationId;
  final TextEditingController _otpController = TextEditingController();

  JobSeekerOTPVerificationPage({required this.verificationId});

  Future<void> jobseekersignInWithPhoneNumber(BuildContext context) async {
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
          builder: (context) => JobSeekerForm(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in successfully")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () => jobseekersignInWithPhoneNumber(context),
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
