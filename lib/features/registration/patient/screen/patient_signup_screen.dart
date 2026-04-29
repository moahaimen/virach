import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../racheeta_rules_screen.dart';
import 'patient_login.dart';
import 'patient_registration_profile_form.dart';

class OldPatientsSignupScreen extends StatefulWidget {
  @override
  _OldPatientsSignupScreenState createState() => _OldPatientsSignupScreenState();
}

class _OldPatientsSignupScreenState extends State<OldPatientsSignupScreen> {
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFF17B3A3);
  final Color _backgroundColor = const Color(0xFFF4F6F5);
  final Color _textColor = const Color(0xFF2C3135);

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  void _signUpWithPhone() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تسجيل الدخول بالهاتف غير متاح حالياً، يرجى استخدام البريد الإلكتروني أو Google.')),
    );
  }

  Future<void> signUPWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? currentUser = googleSignIn.currentUser;
      
      if (currentUser != null) {
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final userCredentials = {
        "email": userCredential.user?.email ?? '',
        "uid": userCredential.user?.uid ?? '',
        "fcm": fcmToken ?? '',
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientRegistrationProfileFormPage(userCredentials: userCredentials),
        ),
      );
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل التسجيل باستخدام Google: $e")),
      );
    } finally {
      _setLoading(false);
    }
  }

  void navigateToEmailRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientRegistrationProfileFormPage(userCredentials: {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo2.png',
                          height: 80,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.health_and_safety, size: 80, color: _primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textColor),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'انضم إلى راجيتة للوصول إلى أفضل الخدمات الصحية.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF7E8788)),
                        ),
                        const SizedBox(height: 32),
                        
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => navigateToEmailRegistration(context),
                          icon: const Icon(Icons.email_outlined, color: Colors.white),
                          label: const Text('المتابعة بالبريد الإلكتروني', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : () => signUPWithGoogle(context),
                          icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
                          label: Text('المتابعة بواسطة Google', style: TextStyle(color: _textColor)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: Color(0xFFDDE7E4)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextButton(
                          onPressed: _isLoading ? null : _signUpWithPhone,
                          child: Text('المتابعة برقم الهاتف', style: TextStyle(color: _primaryColor)),
                        ),
                        const SizedBox(height: 24),
                        
                        RichText(
                          text: TextSpan(
                            text: 'لديك حساب بالفعل؟ ',
                            style: TextStyle(color: _textColor, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'تسجيل الدخول',
                                style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginPatientScreen()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RacheetaRulesPage()),
                            );
                          },
                          child: const Text(
                            'بالمتابعة أنت توافق على شروط وأحكام تطبيق راجيتة',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
