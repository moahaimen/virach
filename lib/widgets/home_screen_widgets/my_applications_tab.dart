import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import '../../features/applicants/models/applicants_model.dart';
import '../../features/applicants/providers/applicants_provider.dart';
import '../../features/jobposting/models/jobposting_model.dart';
import '../../features/jobposting/provider/jobposting_provider.dart';
import '../../features/jobposting/widgets/my_applicants_card.dart';

class MyApplicationsTab extends StatefulWidget {
  final String jobSeekerId;
  const MyApplicationsTab({super.key, required this.jobSeekerId});

  @override
  State<MyApplicationsTab> createState() => _MyApplicationsTabState();
}

class _MyApplicationsTabState extends State<MyApplicationsTab> {
  bool _loading = true;
  List<ApplicantsModel> _apps = [];
  late final ApplicantsProvider _appProv;
  late final JobPostingRetroDisplayGetProvider _jobProv;

  @override
  void initState() {
    super.initState();
    _appProv = context.read<ApplicantsProvider>();
    _jobProv = context.read<JobPostingRetroDisplayGetProvider>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await Future.wait([
        _jobProv.fetchAllJobPostings(),
        _appProv.fetchCurrentUserApplications(widget.jobSeekerId),
      ]);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _apps = _appProv.applicants;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: RacheetaColors.primary));
    }

    if (_apps.isEmpty) {
      return const RacheetaEmptyState(
        icon: Icons.history_edu_outlined,
        title: "لا توجد طلبات توظيف",
        subtitle: "عند التقديم على وظيفة، ستظهر حالة طلبك هنا.",
      );
    }

    final allJobs = _jobProv.jobPostings;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _apps.length,
      itemBuilder: (_, i) {
        final app = _apps[i];
        final job = allJobs.firstWhere(
          (j) => j.id == app.job,
          orElse: () => JobPostingModel(jobTitle: 'غير معروف'),
        );
        return MyApplicationCard(application: app, job: job);
      },
    );
  }
}
