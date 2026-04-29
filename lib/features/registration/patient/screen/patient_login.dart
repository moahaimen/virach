import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../../token_provider.dart';
import '../../../common_screens/signup_login/screens/welcome_page.dart';
import '../../../reservations/providers/reservations_provider.dart';
import '../../../screens/home_screen.dart';
import 'patient_signup_screen.dart';

class LoginPatientScreen extends StatefulWidget {
  @override
  _LoginPatientScreenState createState() => _LoginPatientScreenState();
}

class _LoginPatientScreenState extends State<LoginPatientScreen> {
  bool _isLoading = false;
  final Dio _dio = Dio();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color _primaryColor = const Color(0xFF17B3A3);
  final Color _backgroundColor = const Color(0xFFF4F6F5);
  final Color _textColor = const Color(0xFF2C3135);

  void _setLoading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  void _goToSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OldPatientsSignupScreen()),
    );
  }

  Future<void> PatientloginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال بريد إلكتروني صحيح')));
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال كلمة المرور')));
      return;
    }

    _setLoading(true);
    try {
      final response = await _dio.post(
        "${AppConfig.baseUrl}login/",
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        await _handleLoginSuccess(response.data);
      } else {
        throw Exception("Login failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل تسجيل الدخول، يرجى التحقق من بياناتك.")),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) throw Exception("Failed to retrieve Firebase user.");

      final backendResp = await _dio.post(
        "${AppConfig.baseUrl}firebase-auth/",
        data: {"email": user.email, "firebase_uid": user.uid},
      );

      if (backendResp.statusCode == 200) {
        await _handleLoginSuccess(backendResp.data);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل تسجيل الدخول بواسطة Google")),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _loginWithPhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تسجيل الدخول بالهاتف غير متاح حالياً، يرجى استخدام البريد الإلكتروني أو Google."),
      ),
    );
  }

  Future<void> _handleLoginSuccess(dynamic data) async {
    final accessToken = data["access"] ?? data["access_token"];
    final refreshToken = data["refresh"] ?? data["refresh_token"];
    
    if (accessToken == null) throw Exception("No token received");

    final userDetails = await _fetchUserDetails(accessToken);
    if (userDetails == null) throw Exception("No user found");

    final jobSeekerDetails = await _fetchJobSeekerDetails(userDetails["id"].toString(), accessToken);
    await _saveUserData(userDetails, jobSeekerDetails, accessToken, refreshToken);

    _navigateToScreen();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      tokenProvider.updateToken(accessToken);

      final reservationProvider = Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false);
      reservationProvider.updateToken(accessToken);
      await reservationProvider.fetchMyFullReservations(context);
    });
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(String accessToken) async {
    try {
      final dio = Dio()..options.headers["Authorization"] = "${AppConfig.authorizationPrefix} $accessToken";
      final response = await dio.get("${AppConfig.baseUrl}me/");
      if (response.statusCode == 200) return response.data["user"] as Map<String, dynamic>;
    } catch (e) {
      // Ignored
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchJobSeekerDetails(String userId, String accessToken) async {
    try {
      final dio = Dio()..options.headers["Authorization"] = "${AppConfig.authorizationPrefix} $accessToken";
      final response = await dio.get("${AppConfig.baseUrl}users/?user=$userId");
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
        return response.data[0] as Map<String, dynamic>;
      }
    } catch (e) {
      // Ignored
    }
    return null;
  }

  Future<void> _saveUserData(Map<String, dynamic> userData, Map<String, dynamic>? jobSeekerData, String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);
    await prefs.setString("Login_access_token", accessToken); // For compatibility
    await prefs.setString("refresh_token", refreshToken);
    await prefs.setBool("isRegistered", true);

    await prefs.setString("user_id", userData["id"]?.toString() ?? "");
    await prefs.setString("email", userData["email"] ?? "");
    await prefs.setString("full_name", userData["full_name"] ?? "");
    await prefs.setString("role", userData["role"] ?? "unknown");
    await prefs.setString("profile_image", userData["profile_image"] ?? "");
    await prefs.setString("phone_number", userData["phone_number"] ?? "");
    await prefs.setString("gender", userData["gender"] ?? "");
    await prefs.setString("gps_location", userData["gps_location"] ?? "");

    if (jobSeekerData != null) {
      await prefs.setString("jobseeker_id", jobSeekerData["id"]?.toString() ?? "");
      await prefs.setString("specialty", jobSeekerData["specialty"] ?? "");
      await prefs.setString("degree", jobSeekerData["degree"] ?? "");
      await prefs.setString("address", jobSeekerData["address"] ?? "");
      await prefs.setString("jobseeker_gps", jobSeekerData["gps_location"] ?? "");
    }
  }

  void _navigateToScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => HomeScreen()),
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
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WelcomeScreen())),
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
                          'أهلاً بك في راجيتة',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textColor),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'احجز الخدمات الصحية، تابع حجوزاتك، وقدّم على الوظائف بسهولة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF7E8788)),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : PatientloginWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : loginWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
                          label: Text('تسجيل الدخول بواسطة Google', style: TextStyle(color: _textColor)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: Color(0xFFDDE7E4)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading ? null : _loginWithPhone,
                          child: Text('تسجيل الدخول برقم الهاتف', style: TextStyle(color: _primaryColor)),
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          text: TextSpan(
                            text: 'لا تملك حساباً؟ ',
                            style: TextStyle(color: _textColor, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'تسجيل جديد',
                                style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()..onTap = _goToSignup,
                              ),
                            ],
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