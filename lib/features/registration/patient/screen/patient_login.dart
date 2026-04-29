import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/features/screens/home_screen.dart';

import '../../../../token_provider.dart';
import '../../../common_screens/signup_login/screens/welcome_page.dart';
import '../../../reservations/providers/reservations_provider.dart';
import 'patient_signup_screen.dart';

class LoginPatientScreen extends StatefulWidget {
  @override
  _LoginPatientScreenState createState() => _LoginPatientScreenState();
}

class _LoginPatientScreenState extends State<LoginPatientScreen> {
  bool _isLoading = false;
  final Dio _dio = Dio();
  String _statusMessage = '';
  // Email/password controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Phone-login controllers
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  late String _verificationId;

  void _goToSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OldPatientsSignupScreen()),
    );
  }
  void setLoading(bool value) => setState(() => _isLoading = value);
  void _setLoading(bool v) => setState(() => _isLoading = v);

  // ------------------------
  // 1) PHONE NUMBER LOGIN
  // ------------------------
  void _loginWithPhone() {
    _setLoading(true);
    _startPhoneAuth();
  }
  Future<Map<String, dynamic>?> _fetchUserByPhone(String phone) async {
    // no auth header assumed for this endpoint; adjust if you need JWT
    final resp = await Dio().get(
      'https://racheeta.pythonanywhere.com/users/',
      queryParameters: {'phone_number': phone},
    );
    if (resp.statusCode == 200 && resp.data is List) {
      final list = List<Map<String, dynamic>>.from(resp.data);
      return list.firstWhere(
            (u) => u['phone_number'] == phone,
        orElse: () => {},
      );
    }
    return null;
  }

  Future<void> _startPhoneAuth() async {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty || raw.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال رقم هاتف صحيح'))
      );
      _setLoading(false);
      return;
    }

    // remove leading 0 if exists
    final normalized = raw.startsWith('0') ? raw.substring(1) : raw;
    final phone = '+964$normalized';

    debugPrint('📲 [DEBUG] Sending phone to Firebase: $phone');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (cred) async {
          debugPrint('📲 [DEBUG] verificationCompleted for $phone');
          final uc = await FirebaseAuth.instance.signInWithCredential(cred);
          await _onPhoneAuthSuccess(uc);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ [PhoneAuthError] code=${e.code}, message=${e.message}');

          String errorMsg;

          switch (e.code) {
            case 'invalid-phone-number':
              errorMsg = 'صيغة رقم الهاتف غير صحيحة. الرجاء التحقق وإعادة المحاولة.';
              break;
            case 'too-many-requests':
              errorMsg = 'تم حظرك مؤقتًا بسبب عدد كبير من المحاولات. يرجى الانتظار قليلاً قبل المحاولة مرة أخرى.';
              break;
            case 'session-expired':
              errorMsg = 'انتهت صلاحية رمز التحقق. الرجاء طلب رمز جديد.';
              break;
            case 'quota-exceeded':
              errorMsg = 'تم تجاوز حد الاستخدام. حاول لاحقًا.';
              break;
            default:
              errorMsg = 'حدث خطأ أثناء التحقق: ${e.message}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
          _setLoading(false);
        },
        codeSent: (vid, _) {
          debugPrint('📲 [DEBUG] codeSent: verificationId=$vid');
          _verificationId = vid;
          _setLoading(false);
          _showOtpDialog();
        },
        codeAutoRetrievalTimeout: (vid) {
          debugPrint('📲 [DEBUG] codeAutoRetrievalTimeout: verificationId=$vid');
          _verificationId = vid;
          _setLoading(false);
        },
      );
    } catch (e) {
      debugPrint('📲 [DEBUG] verifyPhoneNumber threw: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء تسجيل الرقم: $e'))
      );
      _setLoading(false);
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('أدخل رمز التحقق'),
        content: TextField(
          controller: _smsController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: 'رمز التحقق'),
        ),
        actions: [
          TextButton(
            child: const Text('تأكيد'),
            onPressed: () async {
              final code = _smsController.text.trim();
              if (code.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال رمز من 6 أرقام')),
                );
                return;
              }
              _setLoading(true);
              Navigator.pop(context);
              try {
                final cred = PhoneAuthProvider.credential(
                  verificationId: _verificationId,
                  smsCode: code,
                );
                final uc = await FirebaseAuth.instance.signInWithCredential(cred);
                await _onPhoneAuthSuccess(uc);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ تم تسجيل الدخول')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('رمز تحقق غير صالح')),
                );
              } finally {
                _setLoading(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onPhoneAuthSuccess(UserCredential uc) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = uc.user?.phoneNumber ?? '';

    debugPrint('📞 رقم الهاتف من Firebase: $phone');

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ رقم الهاتف غير متوفر.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final findUserResp = await _dio.post(
        'https://racheeta.pythonanywhere.com/find-user-by-phone/',
        data: {'phone_number': phone},
      );

      if (findUserResp.statusCode == 200) {
        final email = findUserResp.data['email'];
        final loginResp = await _dio.post(
          'https://racheeta.pythonanywhere.com/login/',
          data: {
            'email': email,
            'password': '10000001', // الباسوورد المعروف
          },
        );

        if (loginResp.statusCode == 200) {
          final access = loginResp.data['access'];
          final refresh = loginResp.data['refresh'];

          await prefs
            ..setString('access', access)
            ..setString('refresh', refresh)
            ..setBool('isLoggedIn', true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      }
    } on DioError catch (e) {
      debugPrint('❌ [Error]: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 فشل تسجيل الدخول، تحقق من معلوماتك.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Logs in using email and password
  // Future<void> loginWithEmail() async {
  //   setLoading(true);
  //   try {
  //     final response = await _dio.post(
  //       "https://racheeta.pythonanywhere.com/login/",
  //       data: {
  //         "email": _emailController.text.trim(),
  //         "password": _passwordController.text.trim(),
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final accessToken = response.data["access"];
  //       final refreshToken = response.data["refresh"];
  //       final userDetails = await _fetchUserDetails(accessToken);
  //
  //       if (userDetails == null) {
  //         throw Exception("No user found with the provided email.");
  //       }
  //
  //       final jobSeekerDetails =
  //       await _fetchJobSeekerDetails(userDetails["id"], accessToken);
  //       await _saveUserData(
  //           userDetails, jobSeekerDetails, accessToken, refreshToken);
  //       _navigateToScreen();
  //     } else {
  //       throw Exception("Login failed: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     setState(() => _statusMessage = "فشل تسجيل الدخول: $e");
  //     print("Login error: $e");
  //   } finally {
  //     setLoading(false);
  //   }
  // }
  Future<void> PatientloginWithEmail() async {
    setLoading(true);
    try {
      final response = await _dio.post(
        "https://racheeta.pythonanywhere.com/login/",
        data: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final accessToken = response.data["access"];
        final refreshToken = response.data["refresh"];
        final userDetails = await _fetchUserDetails(accessToken);

        if (userDetails == null) {
          throw Exception("No user found with the provided email.");
        }

        final jobSeekerDetails =
        await _fetchJobSeekerDetails(userDetails["id"], accessToken);

        await _saveUserData(
            userDetails, jobSeekerDetails, accessToken, refreshToken);

        _navigateToScreen(); // ✅ انتقل أولا

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // ✅ تحديث TokenProvider
          final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
          tokenProvider.updateToken(accessToken);

          // ✅ تحديث Reservation Provider
          final reservationProvider = Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false);
          reservationProvider.updateToken(accessToken);

          // ✅ تحميل الحجوزات
          await reservationProvider.fetchMyFullReservations(context);
        });
      } else {
        throw Exception("Login failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _statusMessage = "فشل تسجيل الدخول: $e");
      print("Login error: $e");
    } finally {
      setLoading(false);
    }
  }



  /// Logs in using Google authentication
  Future<void> loginWithGoogle() async {
    setLoading(true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) throw Exception("Failed to retrieve Firebase user.");

      final backendResp = await _dio.post(
        "https://racheeta.pythonanywhere.com/firebase-auth/",
        data: {"email": user.email, "firebase_uid": user.uid},
      );

      if (backendResp.statusCode == 200) {
        final accessToken = backendResp.data["access_token"];
        final refreshToken = backendResp.data["refresh_token"];
        final userDetails = await _fetchUserDetails(accessToken);

        if (userDetails == null) {
          throw Exception("Failed to fetch user details.");
        }

        final jobSeekerDetails =
        await _fetchJobSeekerDetails(userDetails["id"], accessToken);
        await _saveUserData(
            userDetails, jobSeekerDetails, accessToken, refreshToken);
        _navigateToScreen();
      }
    } catch (e) {
      setState(() => _statusMessage = "Gmail Login error: $e");
      print("Google login error: $e");
    } finally {
      setLoading(false);
    }
  }

  /// Fetches user details from the `/me/` endpoint
  Future<Map<String, dynamic>?> _fetchUserDetails(String accessToken) async {
    try {
      final dio = Dio()..options.headers["Authorization"] = "JWT $accessToken";
      final response = await dio.get("https://racheeta.pythonanywhere.com/me/");

      if (response.statusCode == 200) {
        return response.data["user"] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("User details error: $e");
      return null;
    }
  }

  /// Fetches job seeker details using the user ID
  Future<Map<String, dynamic>?> _fetchJobSeekerDetails(
      String userId, String accessToken) async {
    try {
      final dio = Dio()..options.headers["Authorization"] = "JWT $accessToken";
      final response = await dio
          .get("https://racheeta.pythonanywhere.com/users/?user=$userId");

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        return response.data[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("JobSeeker details error: $e");
      return null;
    }
  }

  /// Saves user and job seeker data in SharedPreferences
  Future<void> _saveUserData(
      Map<String, dynamic> userData,
      Map<String, dynamic>? jobSeekerData,
      String accessToken,
      String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
    await prefs.setString("user_id", userData["id"] ?? "");
    await prefs.setString("email", userData["email"] ?? "");
    await prefs.setString("full_name", userData["full_name"] ?? "");
    await prefs.setString("role", userData["role"] ?? "unknown");
    await prefs.setString("profile_image", userData["profile_image"] ?? "");
    await prefs.setString("phone_number", userData["phone_number"] ?? "");
    await prefs.setString("gender", userData["gender"] ?? "");
    await prefs.setString("gps_location", userData["gps_location"] ?? "");
    await prefs.setBool("isRegistered", true);

    // إذا كان المستخدم لديه ملف كباحث عن عمل
    if (jobSeekerData != null) {
      await prefs.setString("jobseeker_id", jobSeekerData["id"] ?? "");
      await prefs.setString("specialty", jobSeekerData["specialty"] ?? "");
      await prefs.setString("degree", jobSeekerData["degree"] ?? "");
      await prefs.setString("address", jobSeekerData["address"] ?? "");
      await prefs.setString("jobseeker_gps", jobSeekerData["gps_location"] ?? "");
    }

    // ✅ Debug
    print("✅ Access Token saved: $accessToken");
    print("🧠 Saved user_id: ${prefs.getString("user_id")}");
    print("🧠 Saved role: ${prefs.getString("role")}");
    print("🧠 Saved jobseeker_id: ${prefs.getString("jobseeker_id")}");
  }



  /// Navigates to the job postings screen after login
  void _navigateToScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => HomeScreen()),
    );


}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title:
            const Text('  تسجيل الدخول المرضى', style: TextStyle(color: Colors.black)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.blue),
              onPressed: () =>  Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WelcomeScreen()),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Phone login row
                // const Text('تسجيل باستخدام رقم الهاتف',
                //     style: TextStyle(fontSize: 16)),
                // const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Expanded(
                //       child: TextField(
                //         controller: _phoneController,
                //         keyboardType: TextInputType.number,
                //         maxLength: 10,
                //         inputFormatters: [
                //           FilteringTextInputFormatter.digitsOnly,
                //           LengthLimitingTextInputFormatter(10),
                //         ],
                //         decoration: InputDecoration(
                //           hintText: '7721837469',
                //           counterText: '',
                //           prefixText: '+964 ',
                //           border: const OutlineInputBorder(),
                //           contentPadding: const EdgeInsets.symmetric(
                //               horizontal: 12, vertical: 16),
                //         ),
                //         onChanged: (val) {
                //           if (val.startsWith('0')) {
                //             final fixed = val.substring(1);
                //             _phoneController.value = TextEditingValue(
                //               text: fixed,
                //               selection:
                //               TextSelection.collapsed(offset: fixed.length),
                //             );
                //           }
                //         },
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     ElevatedButton(
                //       onPressed: _isLoading ? null : _loginWithPhone,
                //       child: const Text('هاتف'),
                //     ),
                //   ],
                // ),

                const Divider(height: 40, thickness: 1),

                // Email/password login
                const Text('تسجيل بالبريد الإلكتروني',
                    style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'كلمة المرور', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : PatientloginWithEmail,
                  style: ElevatedButton.styleFrom( backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50)),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تسجيل بالبريد الإلكتروني',style: TextStyle(color: Colors.white),),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : loginWithGoogle,
                  icon: const Icon(Icons.g_translate, color: Colors.white),
                  label: const Text('تسجيل ب Google',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red),
                ),

                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'لا تملك حساباً؟ ',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'تسجيل جديد',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()..onTap = _goToSignup,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}