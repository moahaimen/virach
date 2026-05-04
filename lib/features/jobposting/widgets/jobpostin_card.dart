import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import '../models/jobposting_model.dart';

class JobPostingCard extends StatelessWidget {
  final JobPostingModel job;
  final VoidCallback onTap;

  const JobPostingCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = (job.jobStatus?.toLowerCase() == 'urgent');

    return RacheetaCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: RacheetaColors.danger,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Text(
                'عاجل',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: RacheetaColors.mintLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.work_outline, color: RacheetaColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle ?? 'عنوان غير متوفر',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: RacheetaColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.serviceProviderType ?? 'مزود خدمة',
                        style: const TextStyle(color: RacheetaColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      _infoRow(Icons.location_on_outlined, job.jobLocation ?? 'غير محدد'),
                      const SizedBox(height: 4),
                      _infoRow(Icons.monetization_on_outlined, job.salary ?? 'غير محدد'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: RacheetaColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RacheetaStatusChip(
                  label: job.jobStatus ?? 'نشط',
                  color: isUrgent ? RacheetaColors.danger : RacheetaColors.primary,
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RacheetaColors.surface,
                    foregroundColor: RacheetaColors.primary,
                    minimumSize: const Size(100, 36),
                    elevation: 0,
                    side: const BorderSide(color: RacheetaColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('تفاصيل / تقديم', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: RacheetaColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: RacheetaColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
