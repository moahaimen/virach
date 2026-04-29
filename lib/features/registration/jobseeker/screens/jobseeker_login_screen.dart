import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../jobposting/screens/alljob_postings_screen.dart';
import '../../../reservations/providers/reservations_provider.dart';

class JobSeekerLoginPage extends StatefulWidget {
  @override
  _JobSeekerLoginPageState createState() => _JobSeekerLoginPageState();
}

class _JobSeekerLoginPageState extends State<JobSeekerLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = "";
  bool isOtpSent = false;
  bool _isLoading = false;
  String _statusMessage = '';
  final Dio _dio = Dio();

  /// Send OTP to Phone
  /// Sends OTP to the phone number using Firebase Authentication
// 📞 Send OTP to phone number using Firebase Authentication
  Future<void> _sendOtp(String formattedPhone) async {
    setState(() => _isLoading = true);

    try {
      await _auth.signOut();

      // 🧪 Check if using a test number
      if (formattedPhone == "+9647721837469") {
        setState(() {
          verificationId = "TEST_VERIFICATION_ID"; // Mock ID for test
          isOtpSent = true;
          _isLoading = false;
        });
        print("🧪 Test OTP sent (use 123456 as verification code)");
        return;
      }

      // 🔐 Real OTP sending
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          print("✅ Auto-login successful!");
          _onLoginSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Verification Failed: Code=${e.code}, Message=${e.message}");
          setState(() => _isLoading = false);
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            isOtpSent = true;
            _isLoading = false;
          });
          print("📩 OTP Sent Successfully!");
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
          print("⌛ Auto-retrieval timeout reached.");
        },
      );
    } catch (e) {
      print("❌ Error sending OTP: $e");
      setState(() => _isLoading = false);
    }
  }

  String formatPhoneNumber(String number) {
    if (number.startsWith("0")) {
      number = number.substring(1);
    }
    return "+964$number";
  }

  /// Verify OTP
  /// Verify OTP (Handles Test Number Verification)
  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      String enteredCode = _otpController.text.trim();

      // 🔍 Automatically verify if using a predefined test number
      if (_phoneController.text.trim() == "7721837469" &&
          enteredCode == "123456") {
        print("✅ Test number verified successfully (auto-verification)");
        _onLoginSuccess();
        return;
      }

      // Normal verification for real numbers
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: enteredCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print("✅ Login Successful: ${userCredential.user?.uid}");
      _onLoginSuccess();
    } catch (e) {
      print("❌ Error verifying OTP: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle Successful Login
  void _onLoginSuccess() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      // Call your backend to get JWT tokens using Firebase UID
      final response = await _dio.post(
        "https://racheeta.pythonanywhere.com/firebase-auth/",
        data: {
          "firebase_uid": firebaseUser.uid,
          // Add any other required parameters
        },
      );

      if (response.statusCode == 200) {
        final accessToken = response.data["Login_access_token"];
        final refreshToken = response.data["refresh_token"];

        // Save tokens and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isRegistered", true);
        await prefs.setString("access_token", accessToken);
        await prefs.setString("refresh_token", refreshToken);
        await prefs.setString("user_id", firebaseUser.uid);

        // Fetch additional user details if needed
        final userDetails = await _fetchUserDetails(accessToken);
        if (userDetails != null) {
          await prefs.setString("role", userDetails["role"] ?? "unknown");
          await prefs.setString("email", userDetails["email"] ?? "");
          await prefs.setString("full_name", userDetails["full_name"] ?? "");
          await prefs.setString(
              "phone_number", userDetails["phone_number"] ?? "");
          await prefs.setString("gender", userDetails["gender"] ?? "");
          await prefs.setString("address", userDetails["full_name"] ?? "");
        }

        print("🎯 Redirecting to Home Screen...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AllJobPostingsPage()),
        );
      }
    } catch (e) {
      print("Error completing phone login: $e");
    }
  }

  void setLoading(bool value) => setState(() => _isLoading = value);

  /// Logs in using email and password
  Future<void> loginWithEmail() async {
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
        Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false)
            .updateToken(accessToken);

        _navigateToScreen();
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

        // ✅ تحديث التوكن في مزود الحجوزات
        Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false)
            .updateToken(accessToken);

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
          .get("https://racheeta.pythonanywhere.com/jobseekers/?user=$userId");

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
    await prefs.setBool("isRegistered", true);

    if (jobSeekerData != null) {
      await prefs.setString("jobseeker_id", jobSeekerData["id"] ?? "");
      await prefs.setString("specialty", jobSeekerData["specialty"] ?? "");
      await prefs.setString("degree", jobSeekerData["degree"] ?? "");
      await prefs.setString("address", jobSeekerData["address"] ?? "");
    }
  }

  /// Navigates to the job postings screen after login
  void _navigateToScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => AllJobPostingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('تسجيل الدخول', style: TextStyle(color: Colors.black)),
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
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
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
                child: const Text("تسجيل الدخول بالبريد الإلكتروني"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : loginWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.g_translate),
                label: const Text("تسجيل الدخول بـ Google"),
              ),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              Column(
                children: [
                  if (!isOtpSent) ...[
                    // Phone Input & Send OTP Button
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "رقم الهاتف",
                        hintText: "7XXXXXXXX",
                        prefixText: "+964 ",
                        prefixStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      onChanged: (value) {
                        if (value.startsWith("0")) {
                          _phoneController.text = value.substring(1);
                          _phoneController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: _phoneController.text.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String formattedPhone =
                            formatPhoneNumber(_phoneController.text.trim());
                        await _sendOtp(formattedPhone);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("إرسال الرمز"),
                    ),
                  ] else ...[
                    // OTP Input & Verify Button
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "أدخل الرمز المرسل",
                        prefixIcon: Icon(Icons.sms),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("تحقق من الرمز"),
                    ),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
