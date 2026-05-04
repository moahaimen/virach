import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'package:racheeta/widgets/home_screen_widgets/appBar_widget.dart';

import '../../applicants/models/applicants_model.dart';
import '../../applicants/providers/applicants_provider.dart';
import '../../jobposting/models/jobposting_model.dart';
import '../../jobposting/provider/jobposting_provider.dart';
import '../widgets/my_applicants_card.dart';

class MyJobApplicationsPage extends StatefulWidget {
  final String? jobSeekerId;
  final bool standAlone;
  const MyJobApplicationsPage({
    super.key,
    this.jobSeekerId,
    this.standAlone = false,
  });

  @override
  State<MyJobApplicationsPage> createState() => _MyJobApplicationsPageState();
}

class _MyJobApplicationsPageState extends State<MyJobApplicationsPage> {
  bool _loading = true;
  final _cacheKey = 'cached_my_applications';
  final _fallbackJob = JobPostingModel(jobTitle: 'غير معروف');

  List<ApplicantsModel> _apps = [];

  late ApplicantsProvider _app;
  late JobPostingRetroDisplayGetProvider _jobs;

  @override
  void initState() {
    super.initState();
    _app = context.read<ApplicantsProvider>();
    _jobs = context.read<JobPostingRetroDisplayGetProvider>();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id')?.trim();

    final cached = await _readCache();
    if (cached.isNotEmpty) {
      if (mounted) {
        setState(() {
          _apps = cached;
          _loading = false;
        });
      }
    }

    if (userId == null || userId.isEmpty) return;

    try {
      await _jobs.fetchAllJobPostings();
      await _app.fetchCurrentUserApplications(userId);

      final liveApps = List<ApplicantsModel>.from(_app.applicants)
        ..sort((a, b) {
          final da = DateTime.tryParse(a.createDate ?? '') ?? DateTime(1970);
          final db = DateTime.tryParse(b.createDate ?? '') ?? DateTime(1970);
          return db.compareTo(da);
        });

      await _writeCache(liveApps);

      if (mounted) {
        setState(() {
          _apps = liveApps;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<ApplicantsModel>> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ApplicantsModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeCache(List<ApplicantsModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey, raw);
  }

  @override
  Widget build(BuildContext context) {
    final allJobs = _jobs.jobPostings;

    final Widget content = _loading && _apps.isEmpty
        ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
        : _apps.isEmpty
            ? const RacheetaEmptyState(
                icon: Icons.history_edu_outlined,
                title: "لا توجد طلبات توظيف",
                subtitle: "عند التقديم على وظيفة، ستظهر حالة طلبك هنا.",
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _apps.length,
                itemBuilder: (_, i) {
                  final app = _apps[i];
                  final job = allJobs.firstWhere(
                    (j) => j.id == app.job,
                    orElse: () => _fallbackJob,
                  );
                  return MyApplicationCard(application: app, job: job);
                },
              );

    if (widget.standAlone) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: RacheetaColors.surface,
          appBar: const RacheetaAppBar(
            title: 'طلبات التوظيف الخاصة بي',
            showNotification: true,
            showLogout: false,
          ),
          body: content,
        ),
      );
    }

    return content;
  }
}
