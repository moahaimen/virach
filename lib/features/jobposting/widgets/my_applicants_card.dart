import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import '../../applicants/models/applicants_model.dart';
import '../../applicants/models/job_details.dart';
import '../../jobposting/models/jobposting_model.dart';

class MyApplicationCard extends StatelessWidget {
  final ApplicantsModel application;
  final JobPostingModel job;

  const MyApplicationCard({
    super.key,
    required this.application,
    required this.job,
  });

  Color get _statusColor => switch (application.applicationStatus?.toLowerCase()) {
        'accepted' => RacheetaColors.success,
        'rejected' => RacheetaColors.danger,
        'pending' => RacheetaColors.warning,
        _ => RacheetaColors.textSecondary,
      };

  String get _statusLabel => switch (application.applicationStatus?.toLowerCase()) {
        'accepted' => 'مقبول',
        'rejected' => 'مرفوض',
        'pending' => 'قيد الانتظار',
        _ => application.applicationStatus ?? 'قيد المراجعة',
      };

  @override
  Widget build(BuildContext context) {
    final JobDetails? fromDetails = application.jobDetails;
    final jobTitle = fromDetails?.jobTitle ?? job.jobTitle;
    final location = fromDetails?.jobLocation ?? job.jobLocation;
    final salary = (fromDetails?.salary ?? job.salary)?.toString();

    return RacheetaCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  jobTitle ?? 'عنوان غير معروف',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: RacheetaColors.textPrimary,
                      ),
                ),
              ),
              RacheetaStatusChip(
                label: _statusLabel,
                color: _statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on_outlined, location ?? 'غير محدد'),
          const SizedBox(height: 6),
          _infoRow(Icons.monetization_on_outlined, salary != null ? '$salary د.ع' : 'غير محدد'),
          const Divider(height: 32, color: RacheetaColors.border),
          Row(
            children: [
              const Icon(Icons.history_outlined, size: 14, color: RacheetaColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'تاريخ التقديم: ${application.createDate != null ? application.createDate!.split('T').first : "—"}',
                style: const TextStyle(fontSize: 11, color: RacheetaColors.textSecondary),
              ),
              const Spacer(),
              const Text(
                'تفاصيل الطلب',
                style: TextStyle(
                  color: RacheetaColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_back_ios_new, size: 12, color: RacheetaColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: RacheetaColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: RacheetaColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
