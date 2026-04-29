import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../racheeta_rules_screen.dart';
import 'patient_login.dart';
import 'patient_registration_profile_form.dart';

class OldPatientsSignupScreen extends StatefulWidget {
  @override
  _OldPatientsSignupScreenState createState() =>
      _OldPatientsSignupScreenState();
}

class _OldPatientsSignupScreenState extends State<OldPatientsSignupScreen> {
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();


  bool _codeSent = false;
  final _phoneCtrl = TextEditingController();
  final _smsCtrl   = TextEditingController();
  late String _verificationId;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://racheeta.pythonanywhere.com',
    headers: {'Content-Type': 'application/json'},
  ));

  /* -------- log every request so you can see JSON sent ------------ */
  @override
  void initState() {
    super.initState();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o,h){debugPrint('➡️ ${o.method} ${o.path}\n   ${o.data}');h.next(o);},
        onResponse:(r,h){debugPrint('⬅️ ${r.statusCode} ${r.data}');h.next(r);},
        onError:   (e,h){debugPrint('❌ ${e.response?.statusCode} ${e.message}');h.next(e);},
      ),
    );
  }
  /// Returns a valid E.164 (+964… ) string or null if the user input is invalid.
  void _setLoading(bool value) => setState(() => _isLoading = value);
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

  /* -------------------------- PHONE FLOW -------------------------- */
  /*───────────────────────────────────────────────────────────────*/
/* 1) Helper: build a valid Iraqi E.164 number (+964770xxxxxxx)  */
/*───────────────────────────────────────────────────────────────*/
  String? _buildIraqE164(String input) {
    print('👀 Original input: $input');

    // Step 1: Clean non-digit characters
    String digits = input.replaceAll(RegExp(r'\D'), '');
    print('🔢 After removing non-digits: $digits');

    // Step 2: Remove country code or leading zero
    if (digits.startsWith('00964')) {
      print('🛠 Found prefix 00964, removing it');
      digits = digits.substring(5);
    } else if (digits.startsWith('964')) {
      print('🛠 Found prefix 964, removing it');
      digits = digits.substring(3);
    } else if (digits.startsWith('0')) {
      print('🛠 Found leading 0, removing it');
      digits = digits.substring(1);
    }

    print('🎯 After cleaning: $digits');

    // Step 3: Validate only length (no need to start with 7)
    if (digits.length != 10) {
      print('❌ Invalid: Number is not 10 digits (currently ${digits.length})');
      return null;
    }

    final formatted = '+964$digits';
    print('✅ Valid number: $formatted');
    return formatted;
  }



/*───────────────────────────────────────────────────────────────*/
/* 2) Rewritten _signUpWithPhone()                               */
/*───────────────────────────────────────────────────────────────*/
  void _signUpWithPhone() async {
    final e164 = _buildIraqE164(_phoneController.text);

    if (e164 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📵 رقم غير صالح. أدخل مثل 7701234567')),
      );
      return;
    }

    _setLoading(true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: e164,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('✅ verificationCompleted: ${credential.smsCode}');

        if (credential.smsCode != null) {
          // ✅ عبي الكود تلقائيًا بحقل الادخال
          _smsController.text = credential.smsCode!;

          // ✅ وأيضًا سجل دخول تلقائي لو تحب
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _afterFirebaseSignIn(FirebaseAuth.instance.currentUser);
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        debugPrint('❌ verificationFailed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحقق: ${e.message}')),
        );
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        debugPrint('📨 codeSent: verificationId=$_verificationId');
        setState(() {
          _isLoading = false;
          _codeSent = true;
        });
        _showSmsDialog();
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        debugPrint('⌛ codeAutoRetrievalTimeout: $verificationId');
      },
    );
  }
//


  void _showSmsDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('رمز التحقق'),
      content: TextField(
        controller: _smsCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'أدخل رمز التحقق هنا'),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            _setLoading(true);
            try {
              final cred = PhoneAuthProvider.credential(
                  verificationId: _verificationId,
                  smsCode: _smsCtrl.text.trim());
              final uc = await FirebaseAuth.instance.signInWithCredential(cred);
              await _afterFirebaseSignIn(uc.user);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('رمز غير صالح: $e')),
              );
            } finally {
              _setLoading(false);
            }
          },
          child: const Text('تأكيد'),
        ),
      ],
    ),
  );

  /* -------- called after any successful Firebase sign-in --------- */
  Future<void> _afterFirebaseSignIn(User? user) async {
    if (user == null) return;
    final fcm = await _getFcmToken();

    final creds = <String, String>{
      'uid'  : user.uid,
      'phone': user.phoneNumber ?? '',
      'fcm'  : fcm ?? '',
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PatientRegistrationProfileFormPage(
          userCredentials: creds,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  /// the one that can sign in multiple google accounts
  Future<void> signUPWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Check if the user is already signed in
      final GoogleSignInAccount? currentUser = googleSignIn.currentUser;
      if (currentUser != null) {
        final bool? shouldSwitch = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تسجيل الدخول'),
            content: const Text('أنت مسجل الدخول بحساب Google بالفعل. هل ترغب في تسجيل الدخول بحساب آخر؟'),
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

        // Sign out the current account to allow switching
        await googleSignIn.signOut();
      }

      // Proceed with the Google sign-in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Fetch FCM Token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('🎫 Retrieved FCM token: $fcmToken');

      // Build user credentials map
      final userCredentials = {
        "email": userCredential.user?.email ?? '',
        "uid": userCredential.user?.uid ?? '',
        "fcm": fcmToken ?? '',
      };

      debugPrint('🚀 Passing userCredentials to next page: $userCredentials');

      // Navigate to registration profile form
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientRegistrationProfileFormPage(
            userCredentials: userCredentials,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تسجيل الدخول بنجاح باستخدام Google")),
      );
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول باستخدام Google: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }




  /// Fetches the user object from /users/?email=<email>
  /// Returns the first matching user map, or null if none found.
  Future<Map<String, dynamic>?> _fetchUserDetails(
      String jwtToken,
      String email,
      ) async {
    final resp = await _dio.get(
      '/users/',
      queryParameters: {'email': email},
      options: Options(
        headers: {'Authorization': 'JWT $jwtToken'},
        validateStatus: (s) => s! < 500,
      ),
    );

    if (resp.statusCode == 200 && resp.data is List && (resp.data as List).isNotEmpty) {
      return (resp.data as List).first as Map<String, dynamic>;
    }

    debugPrint('⚠️ No user found for email $email (status ${resp.statusCode})');
    return null;
  }



  void navigateToEmailRegistration(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientRegistrationProfileFormPage(
            userCredentials: {}, // Empty for now
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }




  /// BUILD UI
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
                  Row(
                    children: [
                      // // حقل النص: يستقبل 10 أرقام ويقص الصفر الأول
                      // Expanded(
                      //   child: TextFormField(
                      //     controller: _phoneController,
                      //     textDirection: TextDirection.ltr, // ✅ اجبره يكتب من اليسار لليمين داخل الحقل
                      //     keyboardType: TextInputType.phone,
                      //     maxLength: 10,
                      //     inputFormatters: [
                      //       FilteringTextInputFormatter.digitsOnly,
                      //       LengthLimitingTextInputFormatter(10),
                      //     ],
                      //     decoration: InputDecoration(
                      //       hintText: '7701234567',
                      //       counterText: '',
                      //       border: const OutlineInputBorder(
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(4),
                      //           bottomRight: Radius.circular(4),
                      //         ),
                      //       ),
                      //       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      //     ),
                      //     onChanged: (val) {
                      //       if (val.startsWith('0')) {
                      //         final fixed = val.substring(1);
                      //         _phoneController.value = TextEditingValue(
                      //           text: fixed,
                      //           selection: TextSelection.collapsed(offset: fixed.length),
                      //         );
                      //       }
                      //     },
                      //     validator: (val) {
                      //       if (val == null || val.isEmpty) {
                      //         return 'الرجاء إدخال رقم الهاتف';
                      //       }
                      //       if (val.length != 10) {
                      //         return 'يجب أن يتكون رقم الهاتف من 10 أرقام';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      //
                      // ),
                      // الجزء الأيسر: +964 داخل صندوق مع حدود
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey),
                      //     borderRadius: const BorderRadius.only(
                      //       topLeft: Radius.circular(4),
                      //       bottomLeft: Radius.circular(4),
                      //     ),
                      //   ),
                      //   height: 56,
                      //   alignment: Alignment.center,
                      //   child: const Text(
                      //     '+964',
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 16,
                      //     ),
                      //   ),
                      // ),
                      //
                      // // الخط العمودي الفاصل
                      // Container(
                      //   width: 1,
                      //   height: 56,
                      //   color: Colors.grey,
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

// // بدّل مكان الكود السابق:
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _signUpWithPhone,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       backgroundColor: Colors.green,
//                     ),
//                     child: const Text(
//                       "تسجيل باستخدام رقم الهاتف",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
                  // const SizedBox(height: 20),

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
                        _isLoading ? null : () => signUPWithGoogle(context),
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
                  // if (Platform.isIOS)
                  //   SignInWithAppleButton(
                  //     onPressed: _handleAppleSignIn,
                  //     text: "تسجيل الدخول ب Apple",
                  //   ),
                  InkWell(
                    onTap: () {
                      // Navigate to Racheeta Rules page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPatientScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'اذا كنت مسجلا اذهب الى ',
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16), // Default style
                        children: [
                          TextSpan(
                            text: 'تسجيل الدخول',
                            style: const TextStyle(
                              color: Colors
                                  .blue, // Blue color for the specific text
                              decoration: TextDecoration
                                  .underline, // Underline the text
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPatientScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
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
