import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/doctor_request_model.dart';
import '../../../constansts/constants.dart';
import '../../../services/notification_service.dart';
import '../../../token_provider.dart';
import '../../../widgets/dashboard_widget/drawer_widget.dart';
import '../../../widgets/home_screen_widgets/appBar_widget.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../notifications/screens/notification_list_page.dart';
import '../../registration/hsps/screen/hsp_login_screen.dart';
import '../../registration/patient/screen/patient_login.dart';
import '../../reservations/providers/reservations_provider.dart';
import '../providers/doctors_provider.dart';
import '../widgets/dashboard_widgets/action_buttons_widget.dart';
import '../widgets/dashboard_widgets/stastics_widgets.dart';
import '../widgets/dashboard_widgets/today_appointments_widget.dart';

/// Simple full list page for doctor join requests.
class DoctorRequestsListPage extends StatelessWidget {
  final String doctorId;
  const DoctorRequestsListPage({super.key, required this.doctorId});

  String _extractCenterName(dynamic r) {
    final raw = (r is DoctorRequestModel)
        ? r.toJson()
        : (r is Map<String, dynamic> ? r : <String, dynamic>{});
    if (raw['center'] is Map && raw['center']['center_name'] != null) {
      return raw['center']['center_name'].toString();
    } else if (raw['center_data'] is Map && raw['center_data']['name'] != null) {
      return raw['center_data']['name'].toString();
    } else if (raw['center_id'] != null) {
      return raw['center_id'].toString();
    } else if (raw['center'] is String) {
      return raw['center'];
    }
    return 'مركز غير معروف';
  }

  Future<void> _onApprove(BuildContext context, dynamic r) async {
    try {
      final prov = context.read<DoctorRetroDisplayGetProvider>();
      String centerId = '';
      if (r is DoctorRequestModel) {
        centerId = r.centerId;
      } else if (r is Map<String, dynamic>) {
        centerId = (r['center']?['id'] ?? r['center_id'] ?? '') as String;
      }
      if (centerId.isEmpty) return;
      await prov.approveInvite(centerId);
      // refresh list
      await prov.fetchMyDoctorRequests();
    } catch (e) {
      debugPrint('[RequestsPage] approve error: $e');
    }
  }

  Future<void> _onReject(BuildContext context, dynamic r) async {
    try {
      final prov = context.read<DoctorRetroDisplayGetProvider>();
      String centerId = '';
      if (r is DoctorRequestModel) {
        centerId = r.centerId;
      } else if (r is Map<String, dynamic>) {
        centerId = (r['center']?['id'] ?? r['center_id'] ?? '') as String;
      }
      if (centerId.isEmpty) return;
      await prov.rejectInvite(centerId);
      await prov.fetchMyDoctorRequests();
    } catch (e) {
      debugPrint('[RequestsPage] reject error: $e');
    }
  }

  Widget _buildRequestCard(BuildContext context, dynamic r) {
    final centerName = _extractCenterName(r);
    final Map<String, dynamic> raw = (r is DoctorRequestModel)
        ? r.toJson()
        : (r is Map<String, dynamic> ? r : {});
    final created = raw['create_date'] ?? raw['createDate'];
    final dateStr = (created is String)
        ? created.split('T').first
        : (created != null ? created.toString().split('T').first : '-');

    bool doctorApproved = false;
    bool centerApproved = false;
    bool rejected = false;
    if (r is DoctorRequestModel) {
      doctorApproved = r.doctorApproved ?? false;
      centerApproved = r.centerApproved ?? false;
      rejected = r.rejected ?? false;
    } else {
      doctorApproved = raw['doctor_approved'] == true;
      centerApproved = raw['center_approved'] == true;
      rejected = raw['rejected'] == true;
    }

    String statusText = 'قيد الانتظار';
    Color statusColor = Colors.orange;
    if (rejected) {
      statusText = 'مرفوض';
      statusColor = Colors.red;
    } else if (doctorApproved) {
      statusText = 'مقبول من الطبيب';
      statusColor = Colors.green;
    } else if (centerApproved) {
      statusText = 'مقبول من المركز';
      statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.local_hospital, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(centerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('أُرسلت: $dateStr',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, size: 24),
                  color: Colors.green,
                  tooltip: 'قبول',
                  onPressed: (doctorApproved || rejected)
                      ? null
                      : () => _onApprove(context, r),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, size: 24),
                  color: Colors.red,
                  tooltip: 'رفض',
                  onPressed: (rejected)
                      ? null
                      : () => _onReject(context, r),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorProv = context.watch<DoctorRetroDisplayGetProvider>();
    final reqs = doctorProv.myDoctorRequests;
    final doctor = doctorProv.currentDoctor;

    return Scaffold(
      appBar: AppBar(title: const Text('طلبات انضمام من المراكز')),
      body: RefreshIndicator(
        onRefresh: () async {
          await doctorProv.fetchMyDoctorRequests();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (doctor == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('جارٍ تحميل ملف الطبيب...'),
                ),
              if (reqs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text('لا توجد طلبات انضمام حالياً.',
                      style: TextStyle(fontSize: 16)),
                ),
              if (reqs.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reqs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) => _buildRequestCard(context, reqs[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

