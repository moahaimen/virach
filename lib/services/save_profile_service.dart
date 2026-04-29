import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveProfileService {
  static Future<void> saveProfile({
    required Map<String, dynamic> meData,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String selectedGender,
    required LatLng? gpsLocation,
    required String centerName,
    required String bio,
    required String availabilityTime,
    required String city,
    required String district,
    Map<String, dynamic>? customCenterFields, // ✅ إضافة هذا
    String updateEndpoint = 'beauty-centers', // ✅ تعيين القيمة الافتراضية هنا
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Login_access_token') ?? '';
    final dio = Dio()..options.headers['Authorization'] = 'JWT $token';

    final userId = meData['user']['id'].toString();
    final centerId = meData['role']['details']['id'].toString();

    // تحديث بيانات المستخدم
    await dio.patch(
      'https://racheeta.pythonanywhere.com/users/$userId/',
      data: {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone_number': phoneNumber.trim(),
        'gender': (selectedGender == 'انثى') ? 'f' : 'm',
        if (gpsLocation != null)
          'gps_location': '${gpsLocation.latitude}, ${gpsLocation.longitude}',
      },
    );

    // تحديث بيانات المركز
    final payload = {
      'center_name': centerName.trim(),
      'bio': bio.trim(),
      'availability_time': availabilityTime.trim(),
      'address': '$city - $district',
      if (customCenterFields != null) ...customCenterFields, // ✅ دمج الاختياري
    };

    await dio.patch(
      'https://racheeta.pythonanywhere.com/$updateEndpoint/$centerId/',
      data: payload,
    );
  }
}
