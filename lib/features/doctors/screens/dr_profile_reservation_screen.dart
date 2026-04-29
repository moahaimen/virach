import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:racheeta/features/doctors/models/doctors_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constansts/constants.dart';
import '../../../services/notification_service.dart';
import '../../../utitlites/buid_stars.dart';
import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/my_account.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../registration/patient/provider/patient_registration_provider.dart';
import '../../reservations/providers/reservations_provider.dart';
import '../../screens/home_screen.dart';
import '../providers/doctors_provider.dart';
import 'chatting_screen.dart';

class DrProfileReservationPage extends StatefulWidget {
  final DoctorModel doctor;
  final Map<String, dynamic> userData;
  final bool? hideBioAndAddress;

  DrProfileReservationPage({
    required this.doctor,
    required this.userData,
    this.hideBioAndAddress = false,
  });

  @override
  _DrProfileReservationPageState createState() =>
      _DrProfileReservationPageState();
}

class _DrProfileReservationPageState extends State<DrProfileReservationPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  int _currentIndex = 0;
  bool _isLoading = false;

  Map<String, String> _userData = {}; // Add this to your class if not defined.
  DateTime? _selectedDate; // Variable to store the selected date
  DateTime? _lastRequestTimestamp; // Tracks the timestamp of the last request
  int _reservationCount =
      0; // Tracks the number of reservations made for the doctor
  DateTime?
      _blockTimestamp; // Tracks the timestamp when the 5-minute block started

  final List<Widget> _screens = [
    HomeScreen(),
    const Center(
        child: Text('حجوزاتي قيد الإنشاء')), // Placeholder for MyReservations
    HesabiScreen(),
  ];


  @override
  void initState() {
    super.initState();
    final doctorId = widget.doctor.id;
    print("Navigating to ChatScreen with doctorId: ${widget.doctor.id}");

    print("Navigated to DrProfileReservationPage with: ${widget.doctor}");
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error fetching current location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to fetch current location')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Store the selected date
      });
      print("Selected date: ${_selectedDate?.toIso8601String()}");
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حجوزاتي قيد الإنشاء')),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HesabiScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

  LatLng? _parseGpsLocation(String? gpsLocation) {
    if (gpsLocation == null) return null;
    try {
      final parts = gpsLocation.split(' '); // Split by space
      if (parts.length == 2) {
        final latitude = double.tryParse(parts[0]);
        final longitude = double.tryParse(parts[1]);
        if (latitude != null && longitude != null) {
          return LatLng(latitude, longitude);
        }
      }
    } catch (e) {
      print("Error parsing GPS location: $e");
    }
    return null; // Return null if parsing fails
  }

  @override
  Widget build(BuildContext context) {
    // Decide whether to hide bio and address
    final bool hideFields = widget.hideBioAndAddress == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.doctor.user?.fullName ?? 'اسم غير متوفر',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Doctor Name: ${widget.doctor.user?.fullName ?? "N/A"}"),
              Text("User Name: ${widget.userData['full_name'] ?? "Unknown"}"),

              // Doctor Profile Section
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.doctor.user?.profileImage != null
                      ? NetworkImage(widget.doctor.user!.profileImage!)
                      : const AssetImage('assets/icons/doctor.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.doctor.user?.fullName ?? 'اسم غير متوفر',
                  style: kDoctorProfileReservationNamePageTextStyle.copyWith(
                    fontSize: 24,
                  ),
                ),
              ),

              // Contact Information
              const SizedBox(height: 8),
              // Conditionally hide bio and address
              if (!hideFields) ...[
                Center(
                  child: Text(
                    widget.doctor.bio ?? 'لا يوجد وصف',
                    style: kDoctorProfileReservationNamePageTextStyle.copyWith(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                /*──────── تقييم + عدد المراجعات ────────*/
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...buildStars(widget.doctor.reviewsAvg, size: 22),
                      const SizedBox(width: 6),
                      Text('(${widget.doctor.reviewsCount})',
                          style: const TextStyle(fontSize: 15, color: Colors.grey)),
                    ],
                  ),
                ),


                const SizedBox(height: 10),
                Text(
                  'العنوان: ${widget.doctor.address ?? 'غير متوفر'}',
                  style: kDoctorProfileReservationPageTextStyle,
                )
              ],
              const SizedBox(height: 24),

              // Contact Information
              _buildInfoRow(
                icon: Icons.phone,
                label: 'رقم المحمول',
                value: widget.doctor.user?.phoneNumber ?? 'غير متوفر',
                onTap: () => _makePhoneCall(widget.doctor.user?.phoneNumber),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.chat,
                label: 'الدردشة',
                value: widget.doctor.user?.phoneNumber ?? 'غير متوفر',
                onTap: () {
                  // Open WhatsApp chat with the doctor's phone number
                  _openWhatsAppChat(widget.doctor.user?.phoneNumber);
                },
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'التاريخ',
                value: _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : 'اختر التاريخ',
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 8),

              /// Map Section
              Container(
                height: 200,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _parseGpsLocation(
                                widget.doctor.user?.gpsLocation) ??
                            LatLng(0.0, 0.0),
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        if (_parseGpsLocation(
                                widget.doctor.user?.gpsLocation) !=
                            null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: _parseGpsLocation(
                                    widget.doctor.user?.gpsLocation)!,
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
                            onPressed: () => _openCareem(32.5544, 44.5555),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('كريم'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _openBaly(
                              _parseGpsLocation(widget.doctor.user?.gpsLocation)
                                  ?.latitude,
                              _parseGpsLocation(widget.doctor.user?.gpsLocation)
                                  ?.longitude,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('بلي'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _openWaze(
                              _parseGpsLocation(widget.doctor.user?.gpsLocation)
                                  ?.latitude,
                              _parseGpsLocation(widget.doctor.user?.gpsLocation)
                                  ?.longitude,
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

              // Reservation Button
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final now = DateTime.now();

                        // Check if pressed within last 30 seconds.
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

                        // Update the last press timestamp.
                        _lastRequestTimestamp = now;

                        // Increase the reservation attempt counter.
                        _reservationCount++;

                        // Initialize or update the block timestamp if this is the first press in a new series.
                        if (_reservationCount == 1) {
                          _blockTimestamp = now;
                        }

                        // Check if there have been 3 attempts in a 3‑minute window.
                        if (_reservationCount >= 3) {
                          if (now.difference(_blockTimestamp!).inMinutes < 3) {
                            // Still within the 3‑minute window. Now check if the ban period is active (5 minutes from _blockTimestamp).
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
                              // Ban period expired; reset the counters.
                              _reservationCount = 1;
                              _blockTimestamp = now;
                            }
                          } else {
                            // More than 3 minutes have passed since the first attempt,
                            // so reset the counter and block timestamp.
                            _reservationCount = 1;
                            _blockTimestamp = now;
                          }
                        }

                        try {
                          print(
                              "Reservation button clicked, starting process...");

                          // Fetch current patient user details.
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

                          // Get the access token from SharedPreferences.
                          final prefs = await SharedPreferences.getInstance();
                          final accessToken =
                              prefs.getString("Login_access_token");
                          if (accessToken == null || accessToken.isEmpty) {
                            throw Exception(
                                "Access token is missing. Please login again.");
                          }
                          print("Access Token retrieved: $accessToken");

                          // Ensure a date was selected.
                          if (_selectedDate == null) {
                            print("No date selected by user.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('يرجى اختيار التاريخ')),
                            );
                            return;
                          }

                          // Format selected date and current time.
                          final formattedDate =
                              DateFormat('yyyy-MM-dd').format(_selectedDate!);
                          final formattedTime =
                              DateFormat('HH:mm:ss').format(DateTime.now());
                          print("Formatted Date: $formattedDate");
                          print("Formatted Time: $formattedTime");

                          // Create the reservation payload.
                          final payload = {
                            "patient": {
                              "id": fetchedUser.id!,
                              "email": fetchedUser.email!,
                              "full_name": fetchedUser.fullName!,
                            },
                            "service_provider_type": "doctor",
                            "service_provider_id": widget.doctor.id!,
                            "appointment_date": formattedDate,
                            "appointment_time": formattedTime,
                            "status": "PENDING",
                          };

                          print("Reservation Payload: $payload");

                          // Send the reservation request.
                          final dio = Dio();
                          dio.options.headers["Authorization"] =
                              "JWT $accessToken";
                          print("Sending reservation request to backend...");
                          final response = await dio.post(
                            "https://racheeta.pythonanywhere.com/reservations/",
                            data: payload,
                          );

                          print(
                              "Backend response status code: ${response.statusCode}");
                          if (response.statusCode == 201) {
                            print(
                                "Reservation created successfully: ${response.data}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم ارسال الحجز بنجاح!'),
                              ),
                            );

                            // 1) Remote push to the doctor.
                            final doctorFcm = widget.doctor.user?.fcm;
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

                            // 2) Persist notifications in backend (via local cache) for both patient and doctor.
                            try {
                              final notifProv = Provider.of<
                                  NotificationsRetroDisplayGetProvider>(
                                context,
                                listen: false,
                              );

                              // Notification for the patient.
                              await notifProv.createNotification(
                                user: fetchedUser.id!,
                                notificationText:
                                    'تم إرسال طلب حجزك إلى الدكتور ${widget.doctor.user?.fullName ?? ''}',
                                isRead: false,
                                createUser: fetchedUser.id!,
                              );

                              // Notification for the doctor.
                              await notifProv.createNotification(
                                user: widget.doctor.user?.id ?? '',
                                notificationText:
                                    'حجز جديد من المريض ${fetchedUser.fullName} بتاريخ $formattedDate',
                                isRead: false,
                                createUser: fetchedUser.id!,
                              );
                            } catch (e) {
                              debugPrint('❌ failed to save notification: $e');
                            }

                            // 3) Show a local confirmation notification.
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
                              content: Text('عزيزي المستخدم حصل فشل في الحجز'),
                            ),
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
        userData: _userData.isNotEmpty
            ? _userData
            : {
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

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print("Could not make phone call to $phoneNumber");
      }
    }
  }

  void _openCareem(double destinationLat, double destinationLng) async {
    final url =
        'careem://rides?pickup=my_location&dropoff_latitude=$destinationLat&dropoff_longitude=$destinationLng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Careem';
    }
  }

  Future<void> _openBaly(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      final Uri balyUri = Uri(
        scheme: 'https',
        host: 'baly.app',
        queryParameters: {
          'pickup_latitude': _currentLocation?.latitude.toString() ?? '',
          'pickup_longitude': _currentLocation?.longitude.toString() ?? '',
          'dropoff_latitude': latitude.toString(),
          'dropoff_longitude': longitude.toString(),
        },
      );
      if (await canLaunchUrl(balyUri)) {
        await launchUrl(balyUri);
      } else {
        throw 'Could not launch Baly.';
      }
    }
  }

  Future<void> _openWaze(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      final Uri wazeUri = Uri(
        scheme: 'https',
        host: 'waze.com',
        path: '/ul',
        queryParameters: {
          'll': '$latitude,$longitude',
          'navigate': 'yes',
        },
      );
      if (await canLaunchUrl(wazeUri)) {
        await launchUrl(wazeUri);
      } else {
        print("Could not open Waze.");
      }
    }
  }

  Future<void> _openWhatsAppChat(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Add the country code to the phone number
      String internationalPhoneNumber = "964$phoneNumber"; // Example for Iraq

      // Build the WhatsApp URL
      final String whatsappUrl = "https://wa.me/$internationalPhoneNumber";

      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        // Show an error if WhatsApp cannot be opened
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp is not installed")),
        );
      }
    } else {
      // Handle case where phone number is invalid or missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor's phone number is not available")),
      );
    }
  }
}
