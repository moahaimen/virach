// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// Future<String> getTokenIfAbsent() async {
//   final prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString("Login_access_token");
//   if (token == null || token.isEmpty) {
//     // No token exists, so fetch one from your login endpoint.
//     // NOTE: In production, you’d likely prompt the user to log in.
//     final dio = Dio();
//     try {
//       final response = await dio.post(
//         "https://racheeta.pythonanywhere.com/login/",
//         data: {
//           "email": "mo@mo.com",
//           "password": 1
//         }, // replace with real credentials
//       );
//       token = response.data["access"];
//       await prefs.setString("Login_access_token", token);
//       print("Fetched token from login endpoint: $token");
//     } catch (e) {
//       print("Error during automatic login: $e");
//       // Handle error appropriately
//       token = '';
//     }
//   }
//   return token;
// }
