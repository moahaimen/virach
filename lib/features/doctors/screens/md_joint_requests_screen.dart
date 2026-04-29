import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/doctor_request_model.dart';
import '../../doctors/screens/dr_profile_reservation_screen.dart';
import '../providers/doctors_provider.dart';

class CenterRequestsScreen extends StatefulWidget {
  @override
  _CenterRequestsScreenState createState() => _CenterRequestsScreenState();
}

class _CenterRequestsScreenState extends State<CenterRequestsScreen> {
  bool _loading = true;
  List<DoctorRequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);

    final prefs    = await SharedPreferences.getInstance();
    final centerId = prefs.getString('medical_center_id');
    final token    = prefs.getString('access_token') ?? '';
    debugPrint('🔍 [CenterRequests] centerId = $centerId');
    debugPrint('🔍 [CenterRequests] access_token = $token');

    if (centerId == null) {
      debugPrint('🔍 [CenterRequests] ❌ no centerId in prefs!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: لم يُعثر على معرف المركز')),
      );
      setState(() => _loading = false);
      return;
    }

    final prov = context.read<DoctorRetroDisplayGetProvider>();
    // ─── re‑apply the token so your provider’s Dio gets the header ───
    prov.setAuthToken(token);

    try {
      debugPrint('🔍 [CenterRequests] calling fetchDoctorRequests(...)');
      final raw = await prov.fetchDoctorRequests(
        centerId:   centerId,
        isArchived: false,
      );
      debugPrint('🔍 [CenterRequests] got ${raw.length} requests:');
      for (var i = 0; i < raw.length; i++) {
        final r = raw[i];
        debugPrint(
            '   • [${i+1}] '
                'id=${r.id}, '
                'doctorId=${r.doctorId}, '
                'doctorName=${r.doctorName}, '
                'createDate=${r.createDate.toIso8601String()}, '
                'approved=${r.doctorApproved}, '
                'rejected=${r.rejected}'
        );
      }

      setState(() => _requests = raw);
    } on DioError catch (err) {
      debugPrint('🔍 [CenterRequests] DioError → '
          'status=${err.response?.statusCode} body=${err.response?.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب الطلبات (${err.response?.statusCode})')),
      );
    } catch (e, st) {
      debugPrint('🔍 [CenterRequests] Unknown error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ غير متوقع: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _badgeColor(DoctorRequestModel r) {
    if (r.doctorApproved) return Colors.green;
    if (r.rejected)       return Colors.red;
    return Colors.orange;
  }

  String _badgeText(DoctorRequestModel r) {
    if (r.doctorApproved) return 'مقبول';
    if (r.rejected)       return 'مرفوض';
    return 'قيد الانتظار';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الانضمام المرسلة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? const Center(child: Text('لا توجد طلبات'))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _requests.length,
        itemBuilder: (_, i) {
          final r    = _requests[i];
          final prov = context.read<DoctorRetroDisplayGetProvider>();

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              final doctor = await prov.fetchDoctorById(r.doctorId);
              Navigator.pop(context);
              if (doctor != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DrProfileReservationPage(
                      doctor: doctor,
                      userData: const {},
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('خطأ في جلب بيانات الطبيب')),
                );
              }
            },
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: r.profileImage != null
                          ? NetworkImage(r.profileImage!)
                          : null,
                      child: r.profileImage == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.specialty,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('dd-MM-yyyy • hh:mm a')
                                .format(r.createDate),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _badgeColor(r).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _badgeText(r),
                        style: TextStyle(
                          color: _badgeColor(r),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
