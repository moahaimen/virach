import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constansts/constants.dart';
import '../../services/notification_service.dart';
import '../../utitlites/buid_stars.dart';
import '../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../notifications/providers/notifications_provider.dart';
import '../registration/patient/provider/patient_registration_provider.dart';
import 'package:racheeta/features/screens/home_screen.dart';
import 'package:racheeta/widgets/home_screen_widgets/bottom_navbar_widgets/my_account.dart'
    as myaccount;

class HSPProfileReservationPage extends StatefulWidget {
  final Map<String, dynamic> hsp;

  HSPProfileReservationPage({required this.hsp});

  @override
  _HSPProfileReservationPageState createState() =>
      _HSPProfileReservationPageState();
}

class _HSPProfileReservationPageState extends State<HSPProfileReservationPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  DateTime? _selectedDate;
  int _currentIndex = 0;
  bool _isLoading = false;

  // For rate-limiting reservation attempts:
  int _reservationCount = 0; // Count of button presses (attempts)
  DateTime?
      _blockTimestamp; // Marks the start time of the current attempt window or ban period
  DateTime?
      _lastRequestTimestamp; // Stores the last time the button was pressed

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    debugPrint("HSPProfileReservationPage initialized with:");
    debugPrint("HSP ID: ${widget.hsp['id']}");
    debugPrint("HSP Type: ${widget.hsp['hspType']}");
    debugPrint("HSP Full data: ${widget.hsp}");
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Error fetching current location: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2035),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      debugPrint("Selected date: ${_selectedDate?.toIso8601String()}");
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حجوزاتي قيد الإنشاء')),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => myaccount.HesabiScreen()),
        );
        break;
      default:
        break;
    }
  }

  // Fallback for both "gps_location" and "gpsLocation" fields.
  LatLng? _parseGpsLocation(dynamic gpsLocation) {
    if (gpsLocation == null) return null;
    try {
      final String locationStr = gpsLocation.toString();
      final parts = locationStr.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint("Error parsing GPS location: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building HSPProfileReservationPage with => ${widget.hsp}");
    final double averageRating = (widget.hsp['rating'] as double?) ?? 0.0;
    final rating = widget.hsp['rating'] ?? 0.0;
    final String reviewsCountStr = widget.hsp['reviews']?.toString() ??
        widget.hsp['reviewsCount']?.toString() ??
        widget.hsp['numReviews']?.toString() ??
        '0';


    // 1) Name fallback
    // final String hspName = widget.hsp['hospital_name']?.toString() ??
    //     widget.hsp['hospitalName']?.toString() ??
    //     widget.hsp['nurse_name']?.toString() ??
    //     widget.hsp['nurseName']?.toString() ??
    //     widget.hsp['pharmacy_name']?.toString() ??
    //     widget.hsp['pharmacyName']?.toString() ??
    //     widget.hsp['therapist_name']?.toString() ??
    //     widget.hsp['therapistName']?.toString() ??
    //     widget.hsp['beauty_center_name']?.toString() ??
    //     widget.hsp['beautyCenterName']?.toString() ??
    //     widget.hsp['centerName']?.toString() ??
    //     widget.hsp['laboratory_name']?.toString() ??
    //     widget.hsp['laboratoryName']?.toString() ??
    //     widget.hsp['full_name']?.toString() ??
    //     widget.hsp['fullName']?.toString() ??
    //     'Unknown';
    final String hspName =
    /* أولاً الاسم الجاهز إن وُجد */
    widget.hsp['name']?.toString() ??
        /* ثم باقى السلسلة كما هى */
        widget.hsp['hospital_name']          ??
        widget.hsp['hospitalName']           ??
        widget.hsp['pharmacy_name']          ??
        widget.hsp['pharmacyName']           ??
        widget.hsp['center_name']            ??
        widget.hsp['beauty_center_name']     ??
        widget.hsp['beauty_center_name']?.toString() ??
            widget.hsp['beautyCenterName']?.toString() ??
        widget.hsp['medical_center_name']    ??
        widget.hsp['centerName']             ??
        widget.hsp['laboratory_name']        ??
        widget.hsp['labrotary_name']         ??
        widget.hsp['laboratoryName']         ??
        widget.hsp['nurse_name']             ??
        widget.hsp['nurseName']              ??
        widget.hsp['therapist_name']         ??
        widget.hsp['therapistName']          ??
        widget.hsp['full_name']              ??
        widget.hsp['fullName']               ??
        'Unknown';


    // 2) Bio / address fallback
    final String bio = widget.hsp['bio']?.toString() ??
        widget.hsp['description']?.toString() ??
        'No bio available';
    final String address = widget.hsp['address']?.toString() ??
        widget.hsp['location']?.toString() ??
        'No address';

    // 3) Profile image fallback
    final String profileImage = widget.hsp['profile_image']?.toString() ??
        widget.hsp['profileImage']?.toString() ??
        '';

    // 4) Phone fallback
    final String phoneNumber = widget.hsp['phone']?.toString() ??           // ✅
        widget.hsp['phone_number']?.toString() ??
        widget.hsp['phoneNumber']?.toString() ??
        widget.hsp['user']?['phone_number']?.toString() ??
        widget.hsp['user']?['phoneNumber']?.toString() ??
        'N/A';

    // 5) Rating / reviews fallback
    final String ratingStr = widget.hsp['rating']?.toString() ??
        widget.hsp['ratingValue']?.toString() ??
        (Random().nextDouble() * 1.25 + 3.0).toStringAsFixed(1);





    // 6) Determine avatar image
    ImageProvider avatar;
    if (profileImage.isNotEmpty && profileImage.startsWith('http')) {
      avatar = NetworkImage(profileImage);
    } else if (profileImage.isNotEmpty) {
      avatar = AssetImage(profileImage);
    } else {
      avatar = const AssetImage("assets/icons/doctor.png");
    }

    // 7) GPS location fallback
    final dynamic rawGps =
        widget.hsp['gps_location'] ?? widget.hsp['gpsLocation'];
    final LatLng? latLng = _parseGpsLocation(rawGps);

    return Scaffold(
      appBar: AppBar(
        title: Text(hspName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: avatar,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  hspName,
                  style: kDoctorProfileReservationNamePageTextStyle.copyWith(
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  bio,
                  style: kDoctorProfileReservationNamePageTextStyle.copyWith(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...buildStars(rating.toDouble(), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '($reviewsCountStr مراجعة)',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Text(
                'العنوان: $address',
                style: kDoctorProfileReservationPageTextStyle,
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                icon: Icons.phone,
                label: 'رقم المحمول',
                value: phoneNumber,
                onTap: () => _makePhoneCall(phoneNumber),
              ),
              _buildInfoRow(
                icon: Icons.chat,
                label: 'الدردشة',
                value: 'ابدأ الدردشة',
                onTap: () {
                  // Your chat logic
                },
              ),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'التاريخ',
                value: 'اختر تاريخ ووقت الحجز',
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: latLng ?? LatLng(0, 0),
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        if (latLng != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: latLng,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => _openCareem(
                              latLng?.latitude ?? 0.0,
                              latLng?.longitude ?? 0.0,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('كريم'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _openBaly(
                              latLng?.latitude ?? 0.0,
                              latLng?.longitude ?? 0.0,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('بلي'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _openWaze(
                              latLng?.latitude ?? 0.0,
                              latLng?.longitude ?? 0.0,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('ويز'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Reservation Button with rate-limiting logic.
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final now = DateTime.now();

                        // 1. Enforce 30-second gap between attempts.
                        if (_lastRequestTimestamp != null &&
                            now.difference(_lastRequestTimestamp!).inSeconds <
                                30) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('يرجى الانتظار 30 ثانية بين المحاولات'),
                            ),
                          );
                          return;
                        }

                        // Update the timestamp for this attempt.
                        _lastRequestTimestamp = now;

                        // 2. Increment the reservation attempt counter.
                        _reservationCount++;
                        if (_reservationCount == 1) {
                          _blockTimestamp = now;
                        }

                        // 3. If there have been 3 or more attempts within 3 minutes, enforce a ban.
                        if (_reservationCount >= 3) {
                          if (_blockTimestamp != null &&
                              now.difference(_blockTimestamp!).inMinutes < 3) {
                            // If still within 5 minutes from the block timestamp, show ban message.
                            if (now.difference(_blockTimestamp!).inMinutes <
                                5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'لقد قمت بمحاولات كثيرة، انتظر 5 دقائق لإرسال حجز آخر'),
                                ),
                              );
                              return;
                            } else {
                              // Ban period expired; reset counter and block timestamp.
                              _reservationCount = 1;
                              _blockTimestamp = now;
                            }
                          } else {
                            // More than 3 minutes have passed since first attempt; reset.
                            _reservationCount = 1;
                            _blockTimestamp = now;
                          }
                        }

                        try {
                          print(
                              "Reservation button clicked, starting process...");

                          // 4. Fetch current patient user details.
                          final provider =
                              Provider.of<PatientRetroDisplayGetProvider>(
                            context,
                            listen: false,
                          );
                          final fetchedUser = await provider.fetchCurrentUser();
                          if (fetchedUser == null) {
                            throw Exception("Failed to fetch user details.");
                          }
                          print(
                              "Fetched User Details: ${fetchedUser.toJson()}");

                          // 5. Get the access token from SharedPreferences.
                          final prefs = await SharedPreferences.getInstance();
                          final accessToken = prefs.getString("access_token");
                          if (accessToken == null || accessToken.isEmpty) {
                            throw Exception(
                                "Access token is missing. Please login again.");
                          }
                          print("Access Token retrieved: $accessToken");

                          // 6. Check that a date has been selected.
                          if (_selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('يرجى اختيار التاريخ')),
                            );
                            return;
                          }

                          // 7. Format the selected date and current time.
                          final formattedDate =
                              DateFormat('yyyy-MM-dd').format(_selectedDate!);
                          final formattedTime =
                              DateFormat('HH:mm:ss').format(DateTime.now());
                          print("Formatted Date: $formattedDate");
                          print("Formatted Time: $formattedTime");

                          // 8. Validate HSP data.
                          final hspType =
                              widget.hsp['hspType']?.toString() ?? 'unknown';
                          final hspId = widget.hsp['id']?.toString() ?? 'null';
                          if (hspType == 'unknown' || hspId == 'null') {
                            throw Exception("HSP type or ID is missing.");
                          }

                          // 9. Build the reservation payload.
                          final payload = {
                            "patient": {
                              "id": fetchedUser.id!,
                              "email": fetchedUser.email!,
                              "full_name": fetchedUser.fullName!,
                            },
                            "service_provider_type": hspType,
                            "service_provider_id": hspId,
                            "appointment_date": formattedDate,
                            "appointment_time": formattedTime,
                            "status": "PENDING",
                          };
                          print("Reservation Payload: $payload");

                          // 10. Send the reservation request to the backend.
                          final dio = Dio();
                          dio.options.headers["Authorization"] =
                              "JWT $accessToken";
                          final response = await dio.post(
                            "https://racheeta.pythonanywhere.com/reservations/",
                            data: payload,
                          );
                          print(
                              "Backend response status code: ${response.statusCode}");
                          if (response.statusCode == 201) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('تم ارسال الحجز بنجاح!')),
                            );

                            // 11. Push notification to the doctor.
                            // Note: Using 'widget.hsp['user']' causes error if widget.hsp is a Map.
                            // Instead, we assume the doctor's FCM token is stored under the key 'fcm' at the top-level.
                            final String? doctorFcm =
                                widget.hsp['fcm']?.toString();
                            if (doctorFcm != null && doctorFcm.isNotEmpty) {
                              await NotificationService.instance.sendPush(
                                to: doctorFcm,
                                title: 'حجز جديد',
                                body:
                                    'قام ${fetchedUser.fullName} بحجز موعد بتاريخ $formattedDate',
                                data: {
                                  'reservation_id': response.data['id'],
                                  'type': 'new_reservation',
                                },
                              );
                            }

                            // 12. Persist notifications locally for both patient and doctor.
                            try {
                              final notifProv = Provider.of<
                                  NotificationsRetroDisplayGetProvider>(
                                context,
                                listen: false,
                              );
                              // Notification visible to the patient.
                              await notifProv.createNotification(
                                user: fetchedUser.id!,
                                notificationText:
                                    'تم إرسال طلب حجزك إلى ${widget.hsp["full_name"] ?? "مزود الخدمة"}',
                                isRead: false,
                                createUser: fetchedUser.id!,
                              );
                              // Notification visible to the doctor/HSP.
                              await notifProv.createNotification(
                                user: widget.hsp['id'] ?? '',
                                notificationText:
                                    'حجز جديد من المريض ${fetchedUser.fullName} بتاريخ $formattedDate',
                                isRead: false,
                                createUser: fetchedUser.id!,
                              );
                            } catch (e) {
                              debugPrint('❌ failed to save notification: $e');
                            }

                            // 13. Show a local confirmation notification and cache it.
                            await NotificationService.instance.showLocal(
                              title: 'تم إرسال الحجز',
                              body: 'سيتم إشعارك عند تأكيد الموعد',
                              alsoCache: true,
                            );
                          } else {
                            print(
                                "Failed to create reservation. Response: ${response.data}");
                            throw Exception("Failed to create reservation");
                          }
                        } catch (e) {
                          print("Error encountered during reservation: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('عزيزي المستخدم حصل فشل في الحجز')),
                          );
                        } finally {
                          setState(() => _isLoading = false);
                          print("Reservation process completed.");
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'تأكيد الحجز',
                        style: TextStyle(color: Colors.white),
                      ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        userData: {
          'user_id': '',
          'full_name': 'مستخدم مجهول',
          'email': 'غير معروف',
          'phone_number': 'غير معروف',
          'degree': 'غير محدد',
          'specialty': 'غير محدد',
          'address': 'غير متوفر',
          'gender': 'غير معروف',
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: Text(value),
      onTap: onTap,
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    if (phone.isNotEmpty && phone != 'N/A') {
      final Uri launchUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("Could not call phone: $phone");
      }
    }
  }

  void _openCareem(double lat, double lng) async {
    final url =
        'careem://rides?pickup=my_location&dropoff_latitude=$lat&dropoff_longitude=$lng';
    if (await canLaunch(url)) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch Careem');
    }
  }

  void _openBaly(double lat, double lng) async {
    final Uri balyUri = Uri(
      scheme: 'https',
      host: 'baly.app',
      queryParameters: {
        'pickup_latitude': _currentLocation?.latitude.toString() ?? '',
        'pickup_longitude': _currentLocation?.longitude.toString() ?? '',
        'dropoff_latitude': lat.toString(),
        'dropoff_longitude': lng.toString(),
      },
    );
    if (await canLaunchUrl(balyUri)) {
      await launchUrl(balyUri);
    } else {
      debugPrint('Could not launch Baly');
    }
  }

  void _openWaze(double lat, double lng) async {
    final Uri wazeUri = Uri(
      scheme: 'https',
      host: 'waze.com',
      path: '/ul',
      queryParameters: {
        'll': '$lat,$lng',
        'navigate': 'yes',
      },
    );
    if (await canLaunchUrl(wazeUri)) {
      await launchUrl(wazeUri);
    } else {
      debugPrint('Could not launch Waze');
    }
  }
}
