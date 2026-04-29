import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import '../../../doctors/models/doctors_model.dart';
import '../../../doctors/models/user_model.dart';
import '../../../reservations/models/reservation_model.dart';

// Providers
import '../../../reservations/providers/reservations_provider.dart';

// Screens (your custom profile pages)
import '../../../doctors/screens/dr_profile_reservation_screen.dart';
import '../../../screens/home_screen.dart';
import '../../../screens/hsp_profile_reservation_screen.dart';

// Widgets
import '../../../../constansts/constants.dart';
import '../../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';

class MyReservationsPage extends StatefulWidget {
  final bool standAlone;
  const MyReservationsPage({Key? key, this.standAlone = false}) : super(key: key);

  @override
  _MyReservationsPageState createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  String? userId;
  bool isLoading = true;
  List<ReservationModel> reservations = [];
  int _currentIndex = 0;
  Map<String, String> _userData = {};
////git fucking shit
  @override
  void initState() {
    super.initState();
    fetchUserReservations();
  }

  /// Load cached reservations from SharedPreferences.
  Future<List<ReservationModel>> _loadReservationsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("cached_reservations");
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((json) => ReservationModel.fromJson(json)).toList();
      } catch (e) {
        debugPrint("Error decoding cached reservations: $e");
      }
    }
    return [];
  }

  /// Save the list of reservations to cache.
  Future<void> _saveReservationsToCache(
    List<ReservationModel> reservations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final reservationsJson =
        jsonEncode(reservations.map((r) => r.toJson()).toList());
    await prefs.setString("cached_reservations", reservationsJson);
  }

  Future<void> fetchUserReservations() async {
    try {
      // Some date-based logic
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final yesterdayMidnight = todayMidnight.subtract(const Duration(days: 1));

      // 1. Load cached reservations
      final cachedReservations = await _loadReservationsFromCache();

      // Filter from yesterday onward
      final cachedRecent = cachedReservations.where((r) {
        if (r.appointmentDate == null) return false;
        final apptDate = DateTime.tryParse(r.appointmentDate!);
        if (apptDate == null) return false;
        return !apptDate.isBefore(yesterdayMidnight);
      }).toList();

      if (cachedRecent.isNotEmpty) {
        setState(() {
          reservations = cachedRecent;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = true;
        });
      }

      // 2. Fetch fresh from network
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('user_id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found. Please log in.')),
        );
        return;
      }

      final provider = Provider.of<ReservationRetroDisplayGetProvider>(
        context,
        listen: false,
      );
      List<ReservationModel> fetchedReservations =
          await provider.fetchReservationsByUser(userId!, context);

      // Filter out CANCELLED
      fetchedReservations = fetchedReservations.where((r) {
        if (r.status == null || r.status!.toUpperCase() == 'CANCELLED') {
          return false;
        }
        if (r.appointmentDate == null) return false;
        final apptDate = DateTime.tryParse(r.appointmentDate!);
        if (apptDate == null) return false;
        return !apptDate.isBefore(yesterdayMidnight);
      }).toList();

      // Sort
      fetchedReservations.sort((a, b) {
        final dtA = _parseDateTime(a.appointmentDate, a.appointmentTime);
        final dtB = _parseDateTime(b.appointmentDate, b.appointmentTime);
        return dtA.compareTo(dtB);
      });

      // Limit to next 10
      if (fetchedReservations.length > 10) {
        fetchedReservations = fetchedReservations.sublist(0, 10);
      }

      setState(() {
        reservations = fetchedReservations;
        isLoading = false;
      });

      // Cache them
      await _saveReservationsToCache(fetchedReservations);
    } catch (e) {
      debugPrint("Error fetching reservations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch reservations: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime _parseDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null) return DateTime(1970);
    final combined = '$dateStr ${timeStr ?? '00:00:00'}';
    final parsed = DateTime.tryParse(combined);
    return parsed ?? DateTime(1970);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(child: Text('لاتـــوجــد حــجــوزات'))
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return ReservationCard(
                      reservation: reservation,
                      onCancel: () async => await fetchUserReservations(),
                    );
                  },
                ),




    );
  }
}

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback? onCancel;

  const ReservationCard({
    Key? key,
    required this.reservation,
    this.onCancel,
  }) : super(key: key);

  String _translateStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return 'انتظار';
      case 'CONFIRMED':
        return 'مؤكدة';
      default:
        return 'غير معروف';
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  bool _notEmpty(dynamic val) =>
      val != null && val.toString().trim().isNotEmpty;

  /// Derive a name for the HSP:
  /// We assume the server data is in snake_case:
  ///   "hospital_name", "profile_image", "phone_number", etc.
  String _deriveHspName(Map<String, dynamic>? hspUser) {
    if (hspUser == null) return "مزود خدمة غير معروف";
    if (_notEmpty(hspUser["full_name"])) return hspUser["full_name"];
    if (_notEmpty(hspUser["hospital_name"])) return hspUser["hospital_name"];
    if (_notEmpty(hspUser["nurse_name"])) return hspUser["nurse_name"];
    if (_notEmpty(hspUser["pharmacy_name"])) return hspUser["pharmacy_name"];
    if (_notEmpty(hspUser["therapist_name"])) return hspUser["therapist_name"];
    if (_notEmpty(hspUser["beauty_center_name"]))
      return hspUser["beauty_center_name"];
    if (_notEmpty(hspUser["laboratory_name"]))
      return hspUser["laboratory_name"];
    return "مزود خدمة غير معروف";
  }

  String _buildProviderNameAndType() {
    final hspType = reservation.serviceProviderType ?? '';
    final rawName = _deriveHspName(reservation.hspUser);
    return "$rawName\n($hspType)";
  }

  Future<void> _cancelReservation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("تأكيد الإلغاء"),
          content: const Text("هل أنت متأكد من إلغاء الحجز؟"),
          actions: [
            TextButton(
              child: const Text("لا"),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            TextButton(
              child: const Text("نعم"),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final provider = Provider.of<ReservationRetroDisplayGetProvider>(
        context,
        listen: false,
      );
      try {
        await provider.updateReservationStatusdashboard(
          context: context,
          reservationId: reservation.id!,
          newStatus: "CANCELLED",
          pickedDateTime: DateTime.now(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إلغاء الحجز بنجاح")),
        );
        if (onCancel != null) onCancel!();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء إلغاء الحجز: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hspUser = reservation.hspUser;
    final providerImage = hspUser?["profile_image"] ?? ""; // <=== snake_case
    final statusText = _translateStatus(reservation.status);
    final statusClr = _statusColor(reservation.status);
    final providerName = _buildProviderNameAndType();
    bool hideBioAndAddress;
    return InkWell(
      onTap: () {
        // Decide which page to navigate to
        final spType = (reservation.serviceProviderType ?? '').toLowerCase();

        if (spType == 'doctor') {
          // Build a minimal DoctorModel
          final docUserMap = hspUser ?? {};
          debugPrint(
              "Navigating to DrProfileReservationPage with docUserMap: $docUserMap");

          final docModel = DoctorModel(
            id: reservation.serviceProviderId,
            user: UserModel(
              id: docUserMap['id']?.toString(),
              fullName: docUserMap['full_name']?.toString() ?? '',
              profileImage: docUserMap['profile_image']?.toString(),
              phoneNumber: docUserMap['phone_number']?.toString(),
              // **Add the doc's GPS if present**:
              gpsLocation: docUserMap['gps_location']?.toString(),
            ),
            bio: docUserMap['bio']?.toString(),
            address: docUserMap['address']?.toString(),
            // ...
          );

          debugPrint(
              "DoctorModel => id=${docModel.id}, name=${docModel.user?.fullName}, bio=${docModel.bio}, address=${docModel.address}");

          // Build userData map if needed
          final userData = {
            'full_name': docUserMap['full_name']?.toString() ?? 'Unknown',
            'phone_number': docUserMap['phone_number']?.toString() ?? '',
          };

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DrProfileReservationPage(
                doctor: docModel,
                userData: userData,
                hideBioAndAddress: true,
              ),
            ),
          );
        } else {
          // Build an HSP map
          final hspMap = {
            'id': reservation.serviceProviderId,
            'hspType': reservation.serviceProviderType ?? '',
            ...?hspUser,
          };
          debugPrint(
              "Navigating to HSPProfileReservationPage with hspMap=$hspMap");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HSPProfileReservationPage(hsp: hspMap),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: providerImage.isNotEmpty
                        ? NetworkImage(providerImage)
                        : const AssetImage('assets/icons/doctor_icon.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      providerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: statusClr.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusClr,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _cancelReservation(context),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              // Date & Time
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'التاريخ: ${reservation.appointmentDate ?? 'غير معروف'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'الوقت: ${reservation.appointmentTime ?? 'غير معروف'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// now i need when the user make reservation sends   a notification , to the hsp that i want to make reservation in, i will give you the main.dart , to check if i installed correctly the notications""
