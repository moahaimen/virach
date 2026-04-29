import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../reservations/models/patient_model.dart';
import '../../reservations/providers/reservations_provider.dart';

class PatientHistoryandProfilePage extends StatefulWidget {
  final String reservationId;

  const PatientHistoryandProfilePage({
    Key? key,
    required this.reservationId,
  }) : super(key: key);

  @override
  _PatientHistoryandProfilePageState createState() =>
      _PatientHistoryandProfilePageState();
}

class _PatientHistoryandProfilePageState
    extends State<PatientHistoryandProfilePage> {
  bool _isLoading = false;
  PatientModel? _patient;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReservationRetroDisplayGetProvider>(
        context,
        listen: false,
      );

      // ✅ Use the correct method that includes token handling
      final reservation =
          await provider.fetchOneReservationById(widget.reservationId, context);

      if (reservation.patient != null) {
        setState(() {
          _patient = reservation.patient;
        });
        debugPrint(
            "✅ Loaded patient: ${_patient?.fullName}, ${_patient?.email}");
      } else {
        debugPrint(
            "⚠️ No patient info found for reservation ID: ${widget.reservationId}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching patient details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load patient details")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Profile",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patient == null
              ? const Center(child: Text("No patient details available"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🔵 Profile Header
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  (_patient!.profileImage != null &&
                                          _patient!.profileImage!.isNotEmpty)
                                      ? NetworkImage(_patient!.profileImage!)
                                      : const AssetImage(
                                              'assets/icons/patient1.png')
                                          as ImageProvider,
                              onBackgroundImageError: (_, __) {
                                setState(() => _patient!.profileImage = null);
                                debugPrint("Failed to load profile image.");
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _patient!.fullName ?? "Unknown Name",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _patient!.email ?? "Unknown Email",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔵 Info Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _buildInfoCard(
                              icon: Icons.phone,
                              title: "Phone",
                              value: _patient!.phoneNumber ?? "Not Available",
                            ),
                            _buildInfoCard(
                              icon: Icons.person,
                              title: "Gender",
                              value: _patient!.gender ?? "Not Available",
                            ),
                            _buildInfoCard(
                              icon: Icons.calendar_today,
                              title: "Date Created",
                              value: _patient!.createDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(_patient!.createDate!)
                                  : "Unknown",
                            ),
                            _buildInfoCard(
                              icon: Icons.update,
                              title: "Last Updated",
                              value: _patient!.updateDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(_patient!.updateDate!)
                                  : "Unknown",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔵 Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _makePhoneCall(_patient!.phoneNumber ?? ""),
                              icon: const Icon(Icons.call, color: Colors.white),
                              label: const Text("Call",
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                debugPrint("🗨️ Chat button pressed.");
                              },
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text("Chat",
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("❌ Could not launch phone call to $phoneNumber");
      }
    }
  }
}
