import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../../services/notification_service.dart';
import '../../utitlites/buid_stars.dart';
import '../notifications/providers/notifications_provider.dart';
import '../registration/patient/provider/patient_registration_provider.dart';
import 'package:racheeta/core/config/app_config.dart';

class HSPProfileReservationPage extends StatefulWidget {
  final Map<String, dynamic> hsp;
  const HSPProfileReservationPage({super.key, required this.hsp});

  @override
  State<HSPProfileReservationPage> createState() => _HSPProfileReservationPageState();
}

class _HSPProfileReservationPageState extends State<HSPProfileReservationPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  LatLng? _parseGpsLocation(dynamic gpsLocation) {
    if (gpsLocation == null || gpsLocation.toString().isEmpty) return null;
    try {
      final String s = gpsLocation.toString();
      final parts = s
          .trim()
          .split(RegExp(r'[\s,]+'))
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) return LatLng(lat, lng);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _makeReservation() async {
    if (_selectedDate == null) {
      _showError('يرجى اختيار تاريخ الحجز أولاً');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final patientProv = context.read<PatientRetroDisplayGetProvider>();
      final user = await patientProv.fetchCurrentUser();
      if (user == null) throw Exception("User not found");

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? prefs.getString("Login_access_token");

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());

      final payload = {
        "patient": {"id": user.id, "email": user.email, "full_name": user.fullName},
        "service_provider_type": widget.hsp['hspType'] ?? 'unknown',
        "service_provider_id": widget.hsp['id'],
        "appointment_date": formattedDate,
        "appointment_time": formattedTime,
        "status": "PENDING",
      };

      final dio = Dio();
      dio.options.headers["Authorization"] = "${AppConfig.authorizationPrefix} $token";
      final response = await dio.post("${AppConfig.baseUrl}reservations/", data: payload);

      if (response.statusCode == 201) {
        _showInfo('تم إرسال طلب الحجز بنجاح');
        
        // Notifications...
        final fcm = widget.hsp['fcm']?.toString();
        if (fcm != null && fcm.isNotEmpty) {
          await NotificationService.instance.sendPush(to: fcm, title: 'حجز جديد', body: 'لديك طلب حجز جديد من ${user.fullName}');
        }
        
        try {
          final notiProv = context.read<NotificationsRetroDisplayGetProvider>();
          await notiProv.createNotification(user: user.id!, notificationText: 'تم إرسال طلب حجزك إلى ${widget.hsp["name"]}', createUser: user.id);
          await notiProv.createNotification(user: widget.hsp['id'].toString(), notificationText: 'حجز جديد من المريض ${user.fullName}', createUser: user.id);
        } catch (_) {}

        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showError('فشل إرسال الحجز، يرجى المحاولة لاحقاً');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: RacheetaColors.danger));
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: RacheetaColors.primary));
  }

  @override
  Widget build(BuildContext context) {
    final hsp = widget.hsp;
    final String name = hsp['name'] ?? hsp['full_name'] ?? 'مزود خدمة';
    final String bio = hsp['bio'] ?? hsp['description'] ?? 'لا يوجد وصف متاح.';
    final String address = hsp['address'] ?? 'غير محدد';
    final String phone = hsp['phone'] ?? hsp['phone_number'] ?? '—';
    final double rating = (hsp['rating'] ?? hsp['reviewsAvg'] ?? 4.5).toDouble();
    final LatLng? latLng = _parseGpsLocation(hsp['gps_location'] ?? hsp['gpsLocation']);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(title: Text(name), backgroundColor: Colors.white, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RacheetaCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: RacheetaColors.mintLight,
                      backgroundImage: hsp['profileImage'] != null && hsp['profileImage'].toString().startsWith('http')
                          ? NetworkImage(hsp['profileImage'] as String)
                          : null,
                      child: hsp['profileImage'] == null ? const Icon(Icons.person, size: 40, color: RacheetaColors.primary) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(hsp['hspType'] ?? '', style: const TextStyle(color: RacheetaColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...buildStars(rating, size: 18),
                        const SizedBox(width: 8),
                        Text('($rating)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RacheetaCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('عن مزود الخدمة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(bio, style: const TextStyle(fontSize: 14, height: 1.5, color: RacheetaColors.textPrimary)),
                    const Divider(height: 32),
                    _infoRow(Icons.location_on_outlined, 'العنوان', address),
                    const SizedBox(height: 12),
                    _infoRow(Icons.phone_android_outlined, 'رقم التواصل', phone),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const RacheetaSectionHeader(title: 'تحديد موعد'),
              RacheetaCard(
                padding: const EdgeInsets.all(16),
                onTap: _selectDate,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: RacheetaColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.calendar_month_outlined, color: RacheetaColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('تاريخ الحجز', style: TextStyle(fontSize: 12, color: RacheetaColors.textSecondary)),
                          Text(_selectedDate == null ? 'اضغط لاختيار التاريخ' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_back_ios_new, size: 16, color: RacheetaColors.textSecondary),
                  ],
                ),
              ),
              if (latLng != null) ...[
                const SizedBox(height: 24),
                const RacheetaSectionHeader(title: 'الموقع على الخريطة'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(initialCenter: latLng, initialZoom: 14),
                          children: [
                            TileLayer(
                              urlTemplate: "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
                              subdomains: const ['a', 'b', 'c', 'd'],
                              userAgentPackageName: 'com.racheeta.app',
                            ),
                            MarkerLayer(markers: [
                              Marker(point: latLng, width: 40, height: 40, child: const Icon(Icons.location_on, color: RacheetaColors.danger, size: 40)),
                            ]),
                          ],
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Column(
                            children: [
                              _mapBtn(Icons.directions_car, Colors.green, () => _openNav('careem', latLng)),
                              const SizedBox(height: 8),
                              _mapBtn(Icons.map, Colors.blue, () => _openNav('waze', latLng)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _makeReservation,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('تأكيد طلب الحجز'),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RacheetaColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: RacheetaColors.textSecondary)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _mapBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _openNav(String app, LatLng target) async {
    String url = app == 'careem'
        ? 'careem://rides?pickup=my_location&dropoff_latitude=${target.latitude}&dropoff_longitude=${target.longitude}'
        : 'https://waze.com/ul?ll=${target.latitude},${target.longitude}&navigate=yes';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
