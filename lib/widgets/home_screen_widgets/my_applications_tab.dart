// lib/widgets/home_screen_widgets/my_applications_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/applicants/models/applicants_model.dart';
import '../../features/applicants/providers/applicants_provider.dart';
import '../../features/jobposting/models/jobposting_model.dart';
import '../../features/jobposting/provider/jobposting_provider.dart';
import '../../features/jobposting/widgets/my_applicants_card.dart';

class MyApplicationsTab extends StatefulWidget {
  final String jobSeekerId;
  const MyApplicationsTab({Key? key, required this.jobSeekerId})
      : super(key: key);

  @override
  _MyApplicationsTabState createState() => _MyApplicationsTabState();
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
    await Future.wait([
      _jobProv.fetchAllJobPostings(),
      _appProv.fetchCurrentUserApplications(widget.jobSeekerId),
    ]);
    setState(() {
      _apps = _appProv.applicants;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_apps.isEmpty) return const Center(child: Text('لا توجد طلبات بعد'));
    final allJobs = _jobProv.jobPostings;
    return ListView.builder(
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
