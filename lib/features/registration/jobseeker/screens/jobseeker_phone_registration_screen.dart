import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:racheeta/features/registration/jobseeker/screens/jobseeker_registration_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';
class JobSeekerPhoneRegistrationScreen extends StatefulWidget {
  const JobSeekerPhoneRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<JobSeekerPhoneRegistrationScreen> createState() =>
      _JobSeekerPhoneRegistrationScreenState();
}

class _JobSeekerPhoneRegistrationScreenState
    extends State<JobSeekerPhoneRegistrationScreen> with CodeAutoFill {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;
  int? _forceResendingToken;

  @override
  void codeUpdated() {
    setState(() {
      _otpController.text = code ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _listenForCode();
  }

  void _listenForCode() {
    SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Step 1: Send OTP to the phone
  Future<void> _sendOtp() async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ادخال رقم الهاتف")),
      );
      return;
    }

    // Ensure the number is 10 digits and add +964 prefix
    if (phone.length == 10) {
      phone = "+964$phone";
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("رقم الهاتف غير صحيح، أدخل 10 أرقام فقط")),
      );
      return;
    }

    debugPrint("📞 Sending OTP to: $phone");

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            // ADDED FOR DUPLICATE CHECK:
            final result =
                await FirebaseAuth.instance.signInWithCredential(credential);
            if (result.additionalUserInfo != null &&
                !result.additionalUserInfo!.isNewUser) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("هذا الرقم مسجل سابقا")),
              );
              await FirebaseAuth.instance.signOut();
              setState(() => _isLoading = false);
              return;
            }
            _onPhoneAuthSuccess();
          } catch (e) {
            debugPrint("Auto sign-in failed: $e");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sending OTP failed: ${e.message}")),
          );
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _otpSent = true;
            _verificationId = verificationId;
            _forceResendingToken = resendToken;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم إرسال الرمز")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint("codeAutoRetrievalTimeout => $verificationId");
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      debugPrint("Error during phone verification: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Step 2: Verify OTP and check if user already exists
  Future<void> _verifyOtp() async {
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No verification ID found.")),
      );
      return;
    }
    final smsCode = _otpController.text.trim();
    if (smsCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the OTP code.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // ADDED FOR DUPLICATE CHECK:
      if (result.additionalUserInfo != null &&
          !result.additionalUserInfo!.isNewUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("هذا الرقم مسجل سابقا")),
        );
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
        return;
      }

      _onPhoneAuthSuccess();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: ${e.message}")),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onPhoneAuthSuccess() {
    setState(() => _isLoading = false);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not sign in. Please try again.")),
      );
      return;
    }

    // Build userCredentials for the next page
    final userCredentials = {
      "phoneNumber": user.phoneNumber ?? '',
      "email": user.email ?? '',
      "uid": user.uid,
    };
    debugPrint("✅ Sending userCredentials: $userCredentials");

    // Go to the jobseeker registration form
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JobSeekerRegistrationProfileFormPage(
          userCredentials: userCredentials,
        ),
      ),
    );
  }

  Future<void> _resendOtp() async {
    await _sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    final showOtpStep = _otpSent && _verificationId != null;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("تسجيل برقم الهاتف"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: showOtpStep ? _buildOtpUI() : _buildPhoneUI(),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildPhoneUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
        const Text(
          "أدخل رقم هاتفك لإرسال رمز التحقق",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        TextFormField(
          textAlign: TextAlign.right,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone),
            labelText: 'رقم المحمول',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.fromLTRB(12, 16, 16, 16),
          ),
          validator: (value) {
            if (value == null || value.length != 10) {
              return "ادخل رقم هاتف مناسب من 10 ارقام";
            }
            return null;
          },
          onChanged: (value) {
            String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (cleaned.startsWith('0')) {
              cleaned = cleaned.substring(1);
            }
            if (cleaned.length > 10) {
              cleaned = cleaned.substring(0, 10);
            }
            _phoneController.text = cleaned;
            _phoneController.selection = TextSelection.collapsed(
              offset: _phoneController.text.length,
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          child: const Text("إرسال الرمز"),
        ),
      ],
    );
  }

  Widget _buildOtpUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
        const Text(
          "تم إرسال الرمز إلى رقم هاتفك. سيحاول التطبيق اكتشافه تلقائيًا. إن لم ينجح، أدخل الرمز يدويًا:",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        PinFieldAutoFill(
          codeLength: 6,
          controller: _otpController,
          decoration: UnderlineDecoration(
            colorBuilder: FixedColorBuilder(Colors.black),
            textStyle: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          currentCode: _otpController.text,
          onCodeChanged: (code) {
            if (code?.length == 6) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          child: const Text("تحقق"),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : _resendOtp,
          child: const Text("إعادة إرسال الرمز"),
        ),
      ],
    );
  }
}
