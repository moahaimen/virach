import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/features/screens/home_screen.dart';
import '../../../../token_provider.dart';
import 'create_hsp_page.dart';
import '../../patient/provider/patient_registration_provider.dart';

class LoginHSPScreen extends StatefulWidget {
  @override
  _LoginHSPScreenState createState() => _LoginHSPScreenState();
}

class _LoginHSPScreenState extends State<LoginHSPScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();
  bool _isLoading = false;

  void setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> loginWithEmail() async {
    setLoading(true);
    try {
      // Step 1: Login and fetch tokens
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
        print("Access Token: $accessToken");

        // Step 2: Fetch user details from backend
        final userDetails = await emailFetchUserDetails(accessToken);

        if (userDetails == null) {
          throw Exception("Failed to fetch user details.");
        }

        // Step 3: Combine tokens and user details into a single map
        final userData = {
          ...userDetails,
          "access_token": accessToken,
          "refresh_token": refreshToken,
        };

        // Step 4: Save user details to SharedPreferences
        await emailSaveUserDataToPreferences(userData);

        // Step 5: Log success
        print("User logged in and details saved successfully!");

        // Step 6: Notify user and navigate to the dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تسجيل الدخول بنجاح")),
        );
        navigateToDashboard();
      } else {
        throw Exception("Login failed with status: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول: $e")),
      );
      print("Error during email login: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> emailSaveUserDataToPreferences(
      Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    print("<==== Start of emailSaveUserDataToPreferences ====>");

    // Log received user data
    print("Received User Data:");
    print(userData);

    // Save user data to SharedPreferences
    await prefs.setString("Login_access_token", userData["access_token"]);
    print("Saved Login_access_token");

    await prefs.setString("refresh_token", userData["refresh_token"]);
    print("Saved refresh_token");

    await prefs.setString("user_id", userData["id"] ?? "");
    print("Saved user_id");

    await prefs.setString("email", userData["email"] ?? "");
    print("Saved email");

    await prefs.setString("full_name", userData["full_name"] ?? "No Name");
    print("Saved full_name");

    await prefs.setString(
        "gps_location", userData["gps_location"] ?? "Unknown");
    print("Saved gps_location");

    await prefs.setString(
        "phone_number", userData["phone_number"] ?? "Unknown");
    print("Saved phone_number");

    await prefs.setString("gender", userData["gender"] ?? "Unknown");
    print("Saved gender");

    await prefs.setString("profile_image", userData["profile_image"] ?? "");
    print("Saved profile_image");

    await prefs.setBool("isRegistered", true);
    print("Saved isRegistered");

    // Log all saved data
    print("All Saved Data in SharedPreferences:");
    prefs.getKeys().forEach((key) {
      print("$key: ${prefs.get(key)}");
    });

    print("<==== End of emailSaveUserDataToPreferences ====>");
  }

  Future<Map<String, dynamic>?> emailFetchUserDetails(
      String accessToken) async {
    print("<==== Start of emailFetchUserDetails ====>");
    try {
      // Initialize Dio with authorization header
      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $accessToken";

      // Fetch user details
      final response = await dio.get(
        "https://racheeta.pythonanywhere.com/users/",
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = response.data;

        // Assuming we need the logged-in user's data
        final currentUser = users.firstWhere(
          (user) => user["email"] == _emailController.text.trim(),
          orElse: () => null,
        );

        if (currentUser == null) {
          throw Exception("No user found with the provided email.");
        }

        print("Email Login - User details fetched successfully:");
        print(currentUser);

        return currentUser;
      } else {
        throw Exception(
            "Failed to fetch user details. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during emailFetchUserDetails: $e");
      return null;
    } finally {
      print("<==== End of emailFetchUserDetails ====>");
    }
  }

  String _extractUserIdFromToken(String accessToken) {
    final parts = accessToken.split(".");
    if (parts.length != 3) {
      throw Exception("Invalid JWT token");
    }
    final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    return payload["user_id"];
  }

  Future<void> setupAuthorizationHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    if (accessToken != null) {
      _dio.options.headers["Authorization"] = "JWT $accessToken";
    } else {
      throw Exception("Access token not found");
    }
  }

  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString("refresh_token");

    if (refreshToken != null) {
      try {
        final response = await _dio.post(
          "https://racheeta.pythonanywhere.com/token/refresh/",
          data: {
            "refresh": refreshToken,
          },
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data["access"];
          await prefs.setString("access_token", newAccessToken);

          // Update Dio's header
          _dio.options.headers["Authorization"] = "JWT $newAccessToken";

          debugPrint("Access token refreshed successfully.");
        }
      } catch (e) {
        debugPrint("Failed to refresh token: $e");
      }
    } else {
      debugPrint("Refresh token not found.");
    }
  }

  void navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Future<void> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    setLoading(true);

    try {
      // Step 1: Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Google sign-in cancelled by user.");
        setLoading(false);
        return; // User canceled the sign-in
      }

      // Step 2: Retrieve authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Sign in with Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Failed to retrieve user from Firebase.");
      }

      final String uid = user.uid; // Firebase UID
      print("Firebase UID: $uid");
      print("User Email: ${user.email}");

      // Step 4: Fetch tokens from /firebase-auth/
      final dio = Dio();
      final backendResponse = await dio.post(
        "https://racheeta.pythonanywhere.com/firebase-auth/",
        data: {
          "email": user.email,
          "firebase_uid": uid,
        },
      );

      if (backendResponse.statusCode == 200) {
        final responseData = backendResponse.data;
        final accessToken = responseData["access_token"];
        final refreshToken = responseData["refresh_token"];
        final userId = responseData["user_id"]; // Ensure user_id is returned

        print("Access Token: $accessToken");
        print("User ID: $userId");

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("Login_access_token", accessToken);
        await prefs.setString("user_id", userId);
        print("Saved User ID to SharedPreferences: $userId");

        // Send token to TokenProvider
        final tokenProvider =
            Provider.of<TokenProvider>(context, listen: false);
        tokenProvider.updateToken(accessToken);

        // Step 5: Use Provider to Fetch Full User Details
        final provider =
            Provider.of<PatientRetroDisplayGetProvider>(context, listen: false);
        final fetchedUser = await provider.fetchCurrentUser();

        if (fetchedUser == null) {
          throw Exception("Failed to fetch user details.");
        }

        print("Fetched User Details: ${fetchedUser.toJson()}");

        // Save the fetched user details to SharedPreferences
        await saveUserDataToPreferences({
          "access_token": accessToken,
          "refresh_token": refreshToken,
          "user_id": fetchedUser.id,
          "email": fetchedUser.email,
          "full_name": fetchedUser.fullName,
          "gps_location": fetchedUser.gpsLocation,
          "phone_number": fetchedUser.phoneNumber,
          "gender": fetchedUser.gender,
          "profile_image": fetchedUser.profileImage,
        });

        // Step 6: Navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        throw Exception(
            "Backend authentication failed: ${backendResponse.data}");
      }
    } catch (e) {
      print("Error during Google Login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to log in with Google: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveUserDataToPreferences(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    print("Saving user data to SharedPreferences...");
    print("User Data: $userData");

    await prefs.setString("Login_access_token", userData["access_token"]);
    await prefs.setString("refresh_token", userData["refresh_token"]);
    await prefs.setString("user_id", userData["user_id"] ?? "Unknown");
    await prefs.setString("email", userData["email"] ?? "Unknown");
    await prefs.setString("full_name", userData["full_name"] ?? "No Name");
    await prefs.setString(
        "gps_location", userData["gps_location"] ?? "Unknown");
    await prefs.setString(
        "phone_number", userData["phone_number"] ?? "Unknown");
    await prefs.setString("gender", userData["gender"] ?? "Unknown");
    await prefs.setString("profile_image", userData["profile_image"] ?? "");
    await prefs.setBool("isRegistered", true);

    print("Data saved to SharedPreferences successfully.");
    print("Saved User ID: ${prefs.getString("user_id")}");
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String accessToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id");

      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }

      print("Fetching user details for user ID: $userId");

      final response = await Dio().get(
        "https://racheeta.pythonanywhere.com/users/$userId/",
        options: Options(
          headers: {"Authorization": "JWT $accessToken"},
        ),
      );

      if (response.statusCode == 200) {
        print("User details fetched successfully: ${response.data}");
        return response.data;
      } else {
        throw Exception("Failed to fetch user details: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
    print("Session cleared.");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'تسجيل الدخول',
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
                  const SizedBox(height: 100),
                  const Text(
                    'قم بتسجيل الدخول باستخدام',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Email Login
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : loginWithEmail,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("تسجيل الدخول بالبريد الإلكتروني"),
                  ),
                  const SizedBox(height: 20),

                  // Google Login
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : loginWithGoogle,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.g_translate, color: Colors.white),
                    label: const Text(
                      "تسجيل الدخول ب Google",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 50),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'اذا لم تكن مسجلا بالتطبيق سابقاً اذهب الى ',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold), // Default style
                      children: [
                        TextSpan(
                          text: 'تسجيل حساب',
                          style: const TextStyle(
                            color: Colors.blue, fontSize: 16,
                            fontWeight: FontWeight
                                .bold, // Blue color for the specific text
                            decoration:
                                TextDecoration.underline, // Underline the text
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateHSPPage(
                                    userType: 'doctor',
                                  ),
                                ),
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

        // Loading Indicator
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
