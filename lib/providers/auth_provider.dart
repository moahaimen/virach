import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/screens/home_screen.dart';

class Auth {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Method to save user data in SharedPreferences
  static Future<void> saveUserDataToPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('phone', user.phoneNumber ?? '');
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('name', user.displayName ?? '');
    await prefs.setString('photoUrl', user.photoURL ?? '');
    await prefs.setBool('isRegistered', true); // Set the registration status
  }

  // Method to initiate Google Sign-In
  static Future<void> googleLogin(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          await saveUserDataToPreferences(user);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    } catch (e) {
      print("Google sign-in or Firebase authentication failed: $e");
    }
  }

  // Method to initiate phone verification
  static void verifyPhoneNumber(
      BuildContext context,
      String phoneNumber,
      Function(String, int?) onCodeSent,
      Function(FirebaseAuthException) onVerificationFailed) {
    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await saveUserDataToPreferences(userCredential.user!);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      },
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Method to sign in with SMS verification code
  static Future<void> signInWithPhoneNumber(
      BuildContext context, String verificationId, String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await saveUserDataToPreferences(user);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to sign in with SMS code: ${e.toString()}')));
    }
  }

  // Method to sign out from Google and Firebase
  static Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clearing all stored keys
      print("User details cleared and signed out from Firebase");
    } catch (e) {
      print("Google/Firebase sign out error: $e");
    }
  }
}
