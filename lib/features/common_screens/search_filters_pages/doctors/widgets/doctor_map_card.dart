import 'package:flutter/material.dart';
import 'package:racheeta/features/doctors/models/doctors_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../doctors/screens/dr_profile_reservation_screen.dart';

class DoctorMapCard extends StatelessWidget {
  final DoctorModel doctor;

  DoctorMapCard({required this.doctor});
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user data is already saved
    final userId = prefs.getString("user_id");
    final fullName = prefs.getString("full_name");
    final email = prefs.getString("email");
    final gpsLocation = prefs.getString("gps_location");
    final phoneNumber = prefs.getString("phone_number");
    final gender = prefs.getString("gender");

    // If any data is missing, fetch from backend
    if (userId == null || fullName == null || email == null) {
      print("Fetching user data from backend...");
      final accessToken = prefs.getString("access_token");
    }

    return {
      "user_id": userId,
      "full_name": fullName,
      "email": email,
      "gps_location": gpsLocation,
      "phone_number": phoneNumber,
      "gender": gender,
    };
  }

  Future<void> _initializeUserData() async {
    final userData = await getUserData();

    if (userData.isNotEmpty) {
      print("User data fetched successfully: $userData");
    } else {
      print("Failed to fetch user data.");
      // Optionally, you can show a message or redirect the user to the login page
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final userData = await getUserData();

        if (userData["user_id"] == null ||
            userData["full_name"] == null ||
            userData["email"] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("معلوماتك غير كاملة، يرجى تسجيل الدخول مرة أخرى")),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrProfileReservationPage(
              doctor: doctor,
              userData: userData,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Doctor image (Circle Avatar)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: doctor.user?.profileImage != null
                      ? NetworkImage(doctor.user!.profileImage!)
                      : const AssetImage('assets/images/default_doctor.png')
                          as ImageProvider,
                ),
              ),
              // Doctor Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      doctor.user?.fullName ?? 'اسم غير متوفر',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      doctor.bio ?? 'لا يوجد وصف متوفر',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doctor.availabilityTime ?? 'الوقت غير متوفر',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Rating & reviews
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < (doctor.reviewsAvg ?? 0).floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'التقييم العام: ${doctor.reviewsAvg ?? 0}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
