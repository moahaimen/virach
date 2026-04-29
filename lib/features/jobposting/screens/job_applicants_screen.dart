import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../applicants/providers/applicants_provider.dart';
import '../../applicants/widgets/jobs_applicants_card.dart';
import '../../jobposting/models/jobposting_model.dart';
import '../../jobposting/provider/jobposting_provider.dart';

class JobApplicantsPage extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicantsPage({
    Key? key,
    required this.jobId,
    required this.jobTitle,
  }) : super(key: key);

  @override
  State<JobApplicantsPage> createState() => _JobApplicantsPageState();
}

class _JobApplicantsPageState extends State<JobApplicantsPage> {
  bool _isLoading = true;
  late ApplicantsProvider _appProvider;
  late JobPostingRetroDisplayGetProvider _jobProvider;

  @override
  void initState() {
    super.initState();
    _appProvider = Provider.of<ApplicantsProvider>(context, listen: false);
    _jobProvider = Provider.of<JobPostingRetroDisplayGetProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApplicants());
  }

  Future<void> _loadApplicants() async {
    await _appProvider.fetchApplicantsByJobId(widget.jobId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final applicants = _appProvider.applicants;
    final job = _jobProvider.jobPostings.firstWhere(
          (j) => j.id == widget.jobId,
      orElse: () => JobPostingModel(jobTitle: widget.jobTitle),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('المتقدمين – ${widget.jobTitle}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : applicants.isEmpty
          ? const Center(child: Text('لا يوجد متقدمين بعد'))
          : ListView.builder(
        itemCount: applicants.length,
        itemBuilder: (ctx, index) {
          final applicant = applicants[index];
          return ApplicantCard(
            applicant: applicant,
            job: job,

            // ←── patch one field (status) on the backend
            onRemotePatch: (newStatus) async {
              // 🔹 optimistic update is handled by the card itself
              return await _appProvider.updateApplicantStatusOnly(
                applicant.id!,
                newStatus,
              );
            },

            // ←── delete this application
            onDelete: () async {
              final ok = await _appProvider.deleteApplicant(applicant.id!);

              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الطلب بنجاح')),
                );
                setState(() {
                  applicants.removeAt(index);   // remove card from the list
                });
              }
              return ok;                       // must return bool
            },
          );
        },
      ),
    );
  }
}
