// lib/features/jobposting/widgets/my_application_card.dart
import 'package:flutter/material.dart';

import '../../applicants/models/applicants_model.dart';
import '../../applicants/models/job_details.dart';
import '../../jobposting/models/jobposting_model.dart';

class MyApplicationCard extends StatelessWidget {
  final ApplicantsModel application;        // يحوي jobDetails
  final JobPostingModel job;                // نسخة سهلة للحقول الأساسية

  const MyApplicationCard({
    Key? key,
    required this.application,
    required this.job,
  }) : super(key: key);

  /*──────────────────────── ألوان الحالة ────────────────────────*/
  Color get _statusColor => switch (application.applicationStatus) {
    'accepted' => Colors.green,
    'rejected' => Colors.red,
    _          => Colors.grey,
  };

  String get _statusLabel => switch (application.applicationStatus) {
    'accepted' => 'مقبول',
    'rejected' => 'مرفوض',
    _          => 'قيد المراجعة',
  };

  /*──────────────────────── ويدجت مفتاح/قيمة ─────────────────────*/
  Widget _kv(String k, String? v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(v?.isNotEmpty == true ? v! : '—')),
      ],
    ),
  );

  /*──────────────────────── البناء ───────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    /// إذا كان الـ backend أرجع jobDetails استخدمه، وإلا fallback إلى JobPostingModel
    final JobDetails? fromDetails = application.jobDetails;
    final jobTitle       = fromDetails?.jobTitle       ?? job.jobTitle;
    final location       = fromDetails?.jobLocation    ?? job.jobLocation;
    final description    = fromDetails?.jobDescription ?? job.jobDescription;
    final qualifications = fromDetails?.qualifications ?? job.qualifications;
    final salary         = (fromDetails?.salary ?? job.salary)?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*──────── عنوان الوظيفة ────────*/
            Center(
              child: Text(
                jobTitle ?? 'عنوان غير معروف',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            /*──────── تفاصيل الوظيفة ───────*/
            _kv('الموقع', location),
            _kv('الراتب', salary),
            _kv('المؤهلات', qualifications),
            _kv('الوصف الوظيفي', description),
            const Divider(height: 24),
            /*──────── حالة الطلب ───────────*/
            Row(
              children: [
                const Text('حالة الطلب: '),
                Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
