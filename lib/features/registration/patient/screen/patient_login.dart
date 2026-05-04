import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../../../../core/config/app_config.dart';
import '../../../../token_provider.dart';
import '../../../common_screens/signup_login/screens/welcome_page.dart';
import '../../../reservations/providers/reservations_provider.dart';
import '../../../screens/home_screen.dart';
import 'patient_signup_screen.dart';

class LoginPatientScreen extends StatefulWidget {
  const LoginPatientScreen({super.key});

  @override
  State<LoginPatientScreen> createState() => _LoginPatientScreenState();
}

class _LoginPatientScreenState extends State<LoginPatientScreen> {
  bool _isLoading = false;
  final Dio _dio = Dio();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _setLoading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  void _goToSignup() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OldPatientsSignupScreen()));
  }

  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError('الرجاء إدخال بريد إلكتروني صحيح');
      return;
    }
    if (password.isEmpty) {
      _showError('الرجاء إدخال كلمة المرور');
      return;
    }

    _setLoading(true);
    try {
      final response = await _dio.post("${AppConfig.baseUrl}login/", data: {"email": email, "password": password});
      if (response.statusCode == 200) {
        await _handleLoginSuccess(response.data);
      }
    } catch (e) {
      _showError("فشل تسجيل الدخول، يرجى التحقق من البيانات.");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loginWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) { _setLoading(false); return; }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) throw Exception();

      final resp = await _dio.post("${AppConfig.baseUrl}firebase-auth/", data: {"email": user.email, "firebase_uid": user.uid});
      if (resp.statusCode == 200) await _handleLoginSuccess(resp.data);
    } catch (e) {
      _showError("فشل تسجيل الدخول بواسطة Google");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleLoginSuccess(dynamic data) async {
    final accessToken = data["access"] ?? data["access_token"];
    final refreshToken = data["refresh"] ?? data["refresh_token"];
    if (accessToken == null) return;

    final dio = Dio()..options.headers["Authorization"] = "${AppConfig.authorizationPrefix} $accessToken";
    final meResp = await dio.get("${AppConfig.baseUrl}me/");
    final userData = meResp.data["user"];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken ?? "");
    await prefs.setBool("isRegistered", true);
    await prefs.setString("user_id", userData["id"]?.toString() ?? "");
    await prefs.setString("role", userData["role"] ?? "patient");
    await prefs.setString("full_name", userData["full_name"] ?? "");

    if (!mounted) return;
    context.read<TokenProvider>().updateToken(accessToken);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: RacheetaColors.danger));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_person_outlined, size: 64, color: RacheetaColors.primary),
              const SizedBox(height: 24),
              const Text('مرحباً بعودتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('سجل الدخول للمتابعة في عالم راجيتة الصحي', style: TextStyle(color: RacheetaColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _loginWithEmail,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('تسجيل الدخول'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('أو عبر', style: TextStyle(color: RacheetaColors.textSecondary, fontSize: 12))),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loginWithGoogle,
                icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
                label: const Text('المتابعة باستخدام جوجل'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
              ),
              const SizedBox(height: 32),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'ليس لديك حساب؟ ',
                    style: const TextStyle(color: RacheetaColors.textSecondary),
                    children: [
                      TextSpan(
                        text: 'أنشئ حساباً جديداً',
                        style: const TextStyle(color: RacheetaColors.primary, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()..onTap = _goToSignup,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
