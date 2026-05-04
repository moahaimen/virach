import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'package:racheeta/widgets/racheeta_ui/reservation_card.dart' as ui;

import '../../../doctors/models/doctors_model.dart';
import '../../../doctors/models/user_model.dart';
import '../../../reservations/models/reservation_model.dart';
import '../../../reservations/providers/reservations_provider.dart';
import '../../../doctors/screens/dr_profile_reservation_screen.dart';
import '../../../screens/hsp_profile_reservation_screen.dart';

class MyReservationsPage extends StatefulWidget {
  final bool standAlone;
  const MyReservationsPage({super.key, this.standAlone = false});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  bool _isLoading = true;
  List<ReservationModel> _reservations = [];

  @override
  void initState() {
    super.initState();
    _fetchUserReservations();
  }

  Future<void> _fetchUserReservations() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return;

      final provider = Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false);
      final fetched = await provider.fetchReservationsByUser(userId, context);
      
      if (mounted) {
        setState(() {
          _reservations = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTapReservation(ReservationModel reservation) {
    final spType = (reservation.serviceProviderType ?? '').toLowerCase();
    final hspUser = reservation.hspUser;

    if (spType == 'doctor') {
      final docUserMap = hspUser ?? {};
      final docModel = DoctorModel(
        id: reservation.serviceProviderId,
        user: UserModel(
          id: docUserMap['id']?.toString(),
          fullName: docUserMap['full_name']?.toString() ?? '',
          profileImage: docUserMap['profile_image']?.toString(),
          phoneNumber: docUserMap['phone_number']?.toString(),
          gpsLocation: docUserMap['gps_location']?.toString(),
        ),
        bio: docUserMap['bio']?.toString(),
        address: docUserMap['address']?.toString(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DrProfileReservationPage(
            doctor: docModel,
            userData: {
              'full_name': docUserMap['full_name']?.toString() ?? 'Unknown',
              'phone_number': docUserMap['phone_number']?.toString() ?? '',
            },
            hideBioAndAddress: true,
          ),
        ),
      );
    } else {
      final hspMap = {
        'id': reservation.serviceProviderId,
        'hspType': reservation.serviceProviderType ?? '',
        ...?hspUser,
      };
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HSPProfileReservationPage(hsp: hspMap)),
      );
    }
  }

  Future<void> _cancelReservation(ReservationModel reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("إلغاء الحجز", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("تراجع")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: RacheetaColors.danger),
            child: const Text("إلغاء الحجز", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false);
      await provider.updateReservationStatusdashboard(
        context: context,
        reservationId: reservation.id!,
        newStatus: "CANCELLED",
        pickedDateTime: DateTime.now(),
      );
      _fetchUserReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: RacheetaColors.primary));
    }

    if (_reservations.isEmpty) {
      return const RacheetaEmptyState(
        icon: Icons.calendar_month_outlined,
        title: "لا توجد حجوزات حالياً",
        subtitle: "ابدأ بحجز خدمة صحية من الصفحة الرئيسية.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return ui.ReservationCard(
          reservation: reservation,
          onTap: () => _onTapReservation(reservation),
          onCancel: () => _cancelReservation(reservation),
        );
      },
    );
  }
}
