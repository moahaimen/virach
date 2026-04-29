import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Added for FCM
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import all dashboard screens
import '../../../../routing/root_decider.dart';
import '../../../../token_provider.dart';
import '../../../beauty_centers/screens/beauty_dashboard_screen.dart';
import '../../../doctors/screens/doctors_dashboard_screen.dart';
import '../../../hospitals/screens/hospital_dashboard_screen.dart';
import '../../../labrotary/screens/labrotary_dashboard_screen.dart';
import '../../../nurse/screens/nurse_dashboard_screen.dart';
import '../../../pharmacist/screens/pharmacy_dashboard_screen.dart';
import '../../../therapist/screens/therapist_dashboard_screen.dart';
import '../../patient/screen/patient_signup_screen.dart';

class HSPLoginPage extends StatefulWidget {
  const HSPLoginPage({Key? key}) : super(key: key);

  @override
  _HSPLoginPageState createState() => _HSPLoginPageState();
}

class _HSPLoginPageState extends State<HSPLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();
  bool _isLoading = false;
  String _statusMessage = '';

  void setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  /// Function to retrieve the current FCM token.
  Future<String?> getFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print("✅ FCM Token retrieved: $fcmToken");
      return fcmToken;
    } catch (e) {
      print("❌ Error retrieving FCM Token: $e");
      return null;
    }
  }

  // -----------------------
  // 1) EMAIL/PASSWORD LOGIN
  // -----------------------
// ---------------------------------------------------------------------------
// 0) HELPERS  ▸ keep them in the same State class
// ---------------------------------------------------------------------------

  /// Fast path: query the endpoint that supports ?user=<userId>
  Future<String?> _fetchHSPId(
      String token,
      String userId,
      String endpoint,           // e.g. '/medical-centers/'
      ) async {
    try {
      final dio = Dio()..options.headers['Authorization'] = 'JWT $token';
      final url = 'https://racheeta.pythonanywhere.com$endpoint';
      final resp = await dio.get(url, queryParameters: {'user': userId});

      if (resp.statusCode == 200 &&
          resp.data is List &&
          resp.data.isNotEmpty) {
        return resp.data[0]['id'] as String;
      }
    } catch (e) {
      debugPrint('❌ _fetchHSPId error → $e');
    }
    return null;
  }

  /// Slow fallback: scan the full list when the fast path fails
  Future<String?> _resolveCenterId(String token, String userId) async {
    final dio = Dio()..options.headers['Authorization'] = 'JWT $token';
    const url = 'https://racheeta.pythonanywhere.com/medical-centers/';

    try {
      final resp = await dio.get(url);
      if (resp.statusCode == 200 && resp.data is List) {
        for (final c in resp.data) {
          final match = c['create_user'] == userId || c['update_user'] == userId;
          if (match) return c['id'] as String;
        }
      }
    } catch (e) {
      debugPrint('❌ _resolveCenterId error → $e');
    }
    return null;
  }

// ---------------------------------------------------------------------------
// 1) EMAIL / PASSWORD LOGIN  (rewritten)
// ---------------------------------------------------------------------------

  Future<void> loginWithEmail() async {
    setLoading(true);
    debugPrint('🔄 [LOGIN] Starting loginWithEmail');

    try {
      final email    = _emailController.text.trim();
      final password = _passwordController.text.trim();

      debugPrint('📧 Email: $email');
      debugPrint('🔐 Password length: ${password.length}');

      // ➊  authenticate
      final resp = await _dio.post(
        'https://racheeta.pythonanywhere.com/login/',
        data: {'email': email, 'password': password},
      );
      if (resp.statusCode != 200) throw Exception('Status ${resp.statusCode}');

      final accessToken  = resp.data['access']  as String;
      final refreshToken = resp.data['refresh'] as String;

      // ➋  fetch /users/me/  ➜ details
      final userDetails = await _fetchHSPUserDetails(accessToken);
      if (userDetails == null) throw Exception('Failed to fetch user details');

      final prefs     = await SharedPreferences.getInstance();
      final userId    = userDetails['id'].toString();
      final role      = userDetails['role'].toString().toLowerCase();
      final fullName  = userDetails['full_name']?.toString() ?? '';

      // ➌  store common fields
      await prefs
        ..setString('Login_access_token', accessToken)
        ..setString('refresh_token',     refreshToken)
        ..setString('user_id',           userId)
        ..setString('role',              role)
        ..setString('full_name',         fullName)
        ..setBool   ('isRegistered',     true);

      // ➍  role-specific IDs ---------------------------------------------------
      if (role == 'doctor') {
        final doctorId = await _fetchHSPId(accessToken, userId, '/doctor/');
        if (doctorId != null) {
          await prefs.setString('doctor_id', doctorId);
          debugPrint('💾 doctor_id = $doctorId');
        }
      }

      if (role == 'medical_center' || role == 'mdeidcal_center') {
        // try quick ?user=<id> first
        String? centerId =
        await _fetchHSPId(accessToken, userId, '/medical-centers/');
        // fallback: brute-force search
        centerId ??= await _resolveCenterId(accessToken, userId);

        if (centerId != null) {
          await prefs.setString('medical_center_id', centerId);
          debugPrint('💾 medical_center_id = $centerId');
        } else {
          debugPrint('⚠️  medical_center_id NOT found for user $userId');
        }
      }

      // ➎  flush check (just in case)
      for (int i = 0; i < 10; i++) {
        if ((prefs.getString('role') ?? '').isNotEmpty &&
            (prefs.getString('user_id') ?? '').isNotEmpty) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // ➏  update global token & navigate
      Provider.of<TokenProvider>(context, listen: false)
          .updateToken(accessToken);

      debugPrint('✅ Login successful → RootDecider');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RootDecider()),
            (_) => false,
      );
    } catch (e) {
      debugPrint('❌ loginWithEmail ERROR → $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('فشل تسجيل الدخول')));
    } finally {
      setLoading(false);
    }
  }

  // Future<String?> _fetchHspId(Dio dio, String endpoint, String userId) async {
  //   try {
  //     final resp = await dio.get(
  //       'https://racheeta.pythonanywhere.com$endpoint',
  //       queryParameters: {'user': userId},
  //     );
  //     if (resp.statusCode == 200 &&
  //         resp.data is List &&
  //         (resp.data as List).isNotEmpty) {
  //       return resp.data[0]['id'] as String;
  //     }
  //   } catch (e) {
  //     debugPrint('fetchHspId error for $endpoint → $e');
  //   }
  //   return null;
  // }

  // --------------------------------
  // 2) GMAIL LOGIN
  // --------------------------------
// Google Sign-In Logic
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      setLoading(true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Failed to retrieve Firebase user from Google sign-in.");
      }

      final String googleEmail = user.email ?? '';
      if (googleEmail.isEmpty) {
        throw Exception("Google user has no email. Cannot proceed.");
      }

      final response = await _dio.post(
        "https://racheeta.pythonanywhere.com/login/",
        data: {
          "email": googleEmail.trim(),
          "password": "10000001", // the default password
        },
      );

      if (response.statusCode == 200) {
        final accessToken = response.data["access"];
        final refreshToken = response.data["refresh"];
        final userDetails = await _fetchHSPUserDetails(accessToken);
        if (userDetails == null) {
          throw Exception("Failed to fetch user details from the server.");
        }

        // ✅ استخدم دالة getFcmToken بدل الطريقة اليدوية
        final fcmToken = await getFcmToken();
        print("Retrieved FCM Token on Google login: $fcmToken");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("fcm_token", fcmToken ?? "");

        userDetails["fcm"] = fcmToken;

        await _sendFcmTokenToBackend(
          userDetails["id"].toString(),
          accessToken,
        );

        final userId = userDetails["id"]?.toString() ?? "unknown_id";
        final userName = userDetails["full_name"]?.toString() ?? "NoName";
        final userRole = userDetails["role"]?.toString().toLowerCase() ?? "unknown";

        await _saveHSPDataToPreferences(userDetails, accessToken, refreshToken);
        _navigateToDashboard(userRole, userId, userName);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تسجيل الدخول بنجاح باستخدام Google"),
          ),
        );
      } else {
        throw Exception("فشل تسجيل الدخول.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "فشل تسجيل الدخول باستخدام Google. تأكد أن حسابك مسجل مسبقًا أو أن لديك اتصالاً بالإنترنت.",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      print("Google login error: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> _sendFcmTokenToBackend(String userId, String accessToken) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print("\ud83d\udcf2 Sending FCM token to backend: $fcmToken");
      await Dio().patch(
        "https://racheeta.pythonanywhere.com/users/$userId/",
        data: {"fcm": fcmToken},
        options: Options(headers: {"Authorization": "JWT $accessToken"}),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchHSPUserDetails(String accessToken) async {
    try {
      final dio = Dio()..options.headers["Authorization"] = "JWT $accessToken";
      final response =
      await dio.get("https://racheeta.pythonanywhere.com/users/me/");
      print("The response from server ============>$response");
      if (response.statusCode == 200) {
        final Map<String, dynamic> userData =
        response.data as Map<String, dynamic>;
        print("User data retrieved successfully.");

        if (userData.containsKey('nurse_profile')) {
          final nurseProfile =
          userData['nurse_profile'] as Map<String, dynamic>;
          print("Nurse profile found: $nurseProfile");

          final combinedProfile = {
            ...userData,
            'nurse_profile': nurseProfile,
          };
          return combinedProfile;
        } else {
          print("No nurse profile found in user data.");
        }
        return userData;
      }
      return null;
    } catch (e) {
      print("User details error: $e");
      return null;
    }
  }

  Future<void> _saveHSPDataToPreferences(
      Map<String, dynamic> userData,
      String accessToken,
      String refreshToken,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
      ..setString("Login_access_token", accessToken)
      ..setString("refresh_token", refreshToken)
      ..setString("user_id", userData["id"]?.toString() ?? "")
      ..setString("email", userData["email"]?.toString() ?? "")
      ..setString("full_name", userData["full_name"]?.toString() ?? "")
      ..setString("role", userData["role"]?.toString() ?? "unknown")
      ..setBool("isRegistered", true);
  }

  // --------------------------
  // 3) NAVIGATION
  // --------------------------
  void _navigateToDashboard(String role, String userId, String userName) {
    debugPrint("🚦 _navigateToDashboard → role: $role, userId: $userId, userName: $userName");

    switch (role) {
      case 'doctor':
        debugPrint("🏥 Routing to DoctorDashboard");
        _navigateToScreen(ResponsiveDoctorDashboard(
          userType: 'doctor', userId: userId, userName: userName, doctorId: '',
        ));
        break;

      case 'nurse':
        debugPrint("🩺 Routing to NurseDashboard");
        _navigateToScreen(ResponsiveNurseDashboard(
          userType: 'nurse', userId: userId, userName: userName, nurseId: '',
        ));
        break;

      case 'pharmacist':
        debugPrint("💊 Routing to PharmacyDashboard");
        _navigateToScreen(ResponsivePharmacyDashboard(
          userType: 'pharmacist', userId: userId, userName: userName, pharmaId: '',
        ));
        break;

      case 'hospital':
        debugPrint("🏨 Routing to HospitalDashboard");
        _navigateToScreen(ResponsiveHospitalDashboard(
          userType: 'hospital', userId: userId, userName: userName, hospitalId: '',
        ));
        break;

      case 'beauty-center':
      case 'beauty_center':
        debugPrint("💅 Routing to BeautyDashboard");
        _navigateToScreen(ResponsiveBeautyDashboard(
          userType: 'beauty_center', userId: userId, userName: userName, beautyId: '',
        ));
        break;

      case 'therapist':
        debugPrint("🧘 Routing to TherapistDashboard");
        _navigateToScreen(ResponsiveTherapistDashboard(
          userType: 'therapist', userId: userId, userName: userName, therapistId: '',
        ));
        break;

      case 'lab':
      case 'laboratory':
        debugPrint("🔬 Routing to LabrotaryDashboard");
        _navigateToScreen(ResponsiveLabrotaryDashboard(
          userType: 'laboratory', userId: userId, userName: userName, labrotaryId: '',
        ));
        break;

      default:
        debugPrint("❓ Unsupported role in _navigateToDashboard: $role");
        setState(() => _statusMessage = "Unsupported role: $role");
        break;
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => screen),
    );
  }

  // --------------------------
  // 4) UI BUILD
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              '  تسجيل الدخول لمزودي الخدمة الصحية',
              style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 100),
                  const Text('قم بتسجيل الدخول باستخدام',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'كلمة المرور', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : loginWithEmail,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue, // Google button color
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "تسجيل الدخول بالبريد الإلكتروني",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'اذا لم تكن مسجلا بالتطبيق سابقاً اذهب الى ',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'تسجيل حساب',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OldPatientsSignupScreen()),
                              );
                            },
                        ),
                      ],
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
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
