import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../registration/hsps/screen/create_hsp_page.dart';
import '../../../registration/racheeta_rules_screen.dart';
import 'medical_otp.dart';

class MedicalSignupScreen extends StatefulWidget {
  final String role;

  MedicalSignupScreen({required this.role});

  @override
  _MedicalSignupScreenState createState() => _MedicalSignupScreenState();
}

class _MedicalSignupScreenState extends State<MedicalSignupScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _verificationId = "";
  bool _isLoading = false;

  // Function to validate phone number (ignores leading 0s)
  bool isValidPhoneNumber(String number) {
    number = number.replaceFirst(RegExp(r'^0+'), '');
    return RegExp(r'^\d{10}$').hasMatch(number);
  }

  // Function to verify the phone number using Firebase
  Future<void> verifyPhoneNumber(
      BuildContext context, String phoneNumber) async {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل التحقق من الرقم: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HospitalsOTP(
              verificationId: verificationId,
              role: widget.role,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Google Sign-In Method
  Future<void> signInWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);
    print('[DEBUG] Starting Google Sign-In for role: ${widget.role}');

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Check existing session
      final GoogleSignInAccount? currentUser = googleSignIn.currentUser;
      if (currentUser != null) {
        print('[DEBUG] Existing Google user detected: ${currentUser.email}');
        final bool? shouldSwitch = await showDialog<bool>(
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
          print('[DEBUG] User chose to keep existing Google account');
          setState(() => _isLoading = false);
          return;
        }
        await googleSignIn.signOut();
        print('[DEBUG] Signed out previous Google user');
      }

      // Initiate new sign-in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('[DEBUG] Google sign-in cancelled by user');
        setState(() => _isLoading = false);
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print('[DEBUG] Firebase authentication successful');
        print('┌────────── User Credentials ──────────');
        print('│ Role: ${widget.role}');
        print('│ UID: ${user.uid}');
        print('│ Email: ${user.email}');
        print('│ Display Name: ${user.displayName ?? "Not provided"}');
        print('│ Photo URL: ${user.photoURL ?? "Not provided"}');
        print('└──────────────────────────────────────');

        // Retrieve FCM token
        final String? fcmToken = await FirebaseMessaging.instance.getToken();
        print("[DEBUG] Retrieved FCM Token during signup: $fcmToken");

        // Store FCM locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("fcm_token", fcmToken ?? "");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CreateHSPPage(
              userType: widget.role,
              userCredentials: {
                'email': user.email ?? '',
                'uid': user.uid,
                'name': user.displayName ?? '',
                'photoUrl': user.photoURL ?? '',
                'fcmToken': fcmToken ?? '',
              },
            ),
          ),
        );
      } else {
        print('[ERROR] Firebase user is null after authentication');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تسجيل الدخول بنجاح باستخدام Google")),
      );
    } catch (e) {
      print('[ERROR] Google Sign-In failed: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل تسجيل الدخول باستخدام Google: ")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  /* ------------------ Firebase Messaging helper ------------------ */
  Future<String?> _getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );
    FirebaseMessaging.instance.onTokenRefresh
        .listen((t) => debugPrint('🔄 FCM refreshed: $t'));
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('🎫 FCM token: $token');
    return token;
  }

  ///sign up with email
  void navigateToEmailRegistration(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // Navigate to role-specific dashboard
      if (widget.role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'doctor',
            ),
            // ResponsiveDoctorDashboard(
            //   userType: 'doctor',
            // )),
          ),
        );
      } else if (widget.role == 'pharmacist') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'pharmacist',
            ),
          ),
        );
      } else if (widget.role == 'nurse') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'nurse',
            ),
          ),
        );
      } else if (widget.role == 'physical-therapist') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'physical-therapist',
            ),
          ),
        );
      } else if (widget.role == 'labrotary') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'labrotary',
            ),
          ),
        );
      } else if (widget.role == 'mdeidcal_center') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'mdeidcal_center',
            ),
          ),
        );
      } else if (widget.role == 'beauty-center' ||
          widget.role == 'beauty_center') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'beauty_center',
            ),
          ),
        );
      } else if (widget.role == 'hospital') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHSPPage(
              userType: 'hospital',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Role not supported")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'إنشاء حساب أو سجل الدخول',
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
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    'تستطيع الاستمرار عبر',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Email Registration Button
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => navigateToEmailRegistration(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("تسجيل بالبريد الإلكتروني"),
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-In Button
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => signInWithGoogle(context),
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

                  // Racheeta Rules
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
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
