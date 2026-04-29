import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../constansts/constants.dart';

import '../widgets/doctors_otp_verification_page.dart';

class DoctorsSignupPage extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = "";

  bool isValidPhoneNumber(String number) {
    RegExp regex = RegExp(r'^\+964\d{10}$'); // Adjust the regex as needed
    return regex.hasMatch(number);
  }

  void verifyPhoneNumber(BuildContext context, String phoneNumber) {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optionally handle auto sign-in if Firebase automatically verifies the number
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("فشل التحقق من الرقم: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إنشاء حساب أو سجل الدخول كطبيب',
          style: kAppBarDoctorsTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              const Text(
                'تستطيع الاستمرار عبر',
                textAlign: TextAlign.center,
                style: kFieldsTextStyle,
              ),
              const SizedBox(height: 20),
              TextField(
                textAlign: TextAlign.right,
                controller: _phoneController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: 'رقم المحمول',
                  alignLabelWithHint: true,
                  prefixText: '+964 ',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: kRedElevatedButtonStyle,
                  onPressed: () {
                    String phoneNumber = "+964" + _phoneController.text;
                    if (isValidPhoneNumber(phoneNumber)) {
                      verifyPhoneNumber(context, phoneNumber);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("قم بادخال رقم الهاتف")));
                    }
                  },
                  child: const Text(
                    "اضغط هنا للتسجيل",
                    style: kButtonTextStyle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'بالضفط فانت توافق على شروط واحكام تطبيق راجيته',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
