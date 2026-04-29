import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../constansts/constants.dart';
import '../../../../di/dependency_ingection.dart';
import '../providers/login_provider.dart';

class PatientsLoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _verificationId = "";

  // Google Sign-In Logic
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم تسجيل الدخول بنجاح باستخدام Google")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل تسجيل الدخول باستخدام Google: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إنشاء حساب أو سجل الدخول',
          style: kAppBarTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
              const Text(
                'تستطيع الاستمرار عبر',
                textAlign: TextAlign.center,
                style: kFieldsTextStyle,
              ),
              const SizedBox(height: 20),

              // Phone Number Field
              TextField(
                textAlign: TextAlign.right,
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  labelText: 'الايميل',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                textAlign: TextAlign.right,
                controller: _passwordController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  labelText: 'كلمة السر',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  String email = _emailController.value.text;
                  String password = _passwordController.value.text;
                  locator<LoginProvider>().login(email, password);
                  print('ffff');
                },
                child: const Text("اضغط هنا للتسجيل"),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => signInWithGoogle(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.red, // Google button color
                ),
                icon: Icon(Icons.g_translate, color: Colors.white),
                label: const Text(
                  "تسجيل ب Google",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {},
                child: const Text(
                  'بالضغط فانت توافق على شروط واحكام تطبيق راجيته',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
