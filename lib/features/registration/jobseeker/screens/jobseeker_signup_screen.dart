import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../racheeta_rules_screen.dart';
import 'jobseeker_login_screen.dart';
import 'jobseeker_phone_registration_screen.dart';
import 'jobseeker_registration_screen.dart';

class JobSeekerSignUpScreen extends StatefulWidget {
  const JobSeekerSignUpScreen({Key? key}) : super(key: key);

  @override
  State<JobSeekerSignUpScreen> createState() => _JobSeekerSignUpScreenState();
}

class _JobSeekerSignUpScreenState extends State<JobSeekerSignUpScreen> {
  bool _isLoading = false;

  /// Example: Sign Up with Google
  Future<void> _signUpWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn();
      // Check if user is already signed in
      final currentUser = googleSignIn.currentUser;
      if (currentUser != null) {
        // Ask if user wants to switch accounts
        final bool? shouldSwitch = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تسجيل الدخول'),
            content: const Text(
                'أنت مسجل الدخول بحساب Google بالفعل. هل ترغب في تسجيل الدخول بحساب آخر؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('لا'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('نعم'),
              ),
            ],
          ),
        );
        if (shouldSwitch == false) {
          setState(() => _isLoading = false);
          return;
        }
        // Sign out current account to allow switching
        await googleSignIn.signOut();
      }

      // Proceed with the Google sign-in
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final userCredentials = {
        "email": userCredential.user?.email ?? '',
        "uid": userCredential.user?.uid ?? '',
      };

      // Navigate to jobseeker profile form page with user credentials
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobSeekerRegistrationProfileFormPage(
            userCredentials: userCredentials,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تسجيل الدخول بنجاح باستخدام Google")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول باستخدام Google: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Example: Go to Email Registration
  void _navigateToEmailRegistration(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      // Navigate to JobSeekerRegistrationProfileFormPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const JobSeekerRegistrationProfileFormPage(
            userCredentials: {}, // No prefilled data
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Example: Go to Phone Registration
  void _navigateToPhoneRegistration(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      // Navigate to a phone registration screen for jobseeker
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const JobSeekerPhoneRegistrationScreen(),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // If you have Apple sign-in
  // Future<void> _signInWithApple() async {
  //   // ...
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'إنشاء حساب JobSeeker',
              style: TextStyle(color: Colors.black),
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
                  const SizedBox(height: 60),
                  const Text(
                    'تستطيع الاستمرار عبر',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Register by Email
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _navigateToEmailRegistration(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("تسجيل بالبريد الإلكتروني"),
                  ),
                  const SizedBox(height: 20),

                  // Register by Phone
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _navigateToPhoneRegistration(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      "تسجيل برقم الهاتف",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register by Google
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _signUpWithGoogle(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red, // Google button color
                    ),
                    icon: const Icon(Icons.g_translate, color: Colors.white),
                    label: const Text(
                      "تسجيل ب Google",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // If Apple sign in is desired:
                  // ElevatedButton(
                  //   onPressed: _isLoading ? null : _signInWithApple,
                  //   child: const Text("تسجيل الدخول ب Apple"),
                  // ),

                  const SizedBox(height: 40),

                  // Already Registered? -> go to login
                  InkWell(
                    onTap: () {
                      // If you have a jobseeker login screen:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobSeekerLoginPage(),
                        ),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'اذا كنت مسجلا اذهب الى ',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'تسجيل الدخول',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobSeekerLoginPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms & Conditions
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RacheetaRulesPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'بالضغط فانت توافق على شروط واحكام تطبيق راجيته',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.2),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
