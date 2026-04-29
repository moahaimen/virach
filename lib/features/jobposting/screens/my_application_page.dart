import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constansts/constants.dart';
import '../../../widgets/home_screen_widgets/appBar_widget.dart';
import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';

import '../../applicants/models/applicants_model.dart';
import '../../applicants/providers/applicants_provider.dart';
import '../../applicants/widgets/jobs_applicants_card.dart';
import '../../jobposting/models/jobposting_model.dart';
import '../../jobposting/provider/jobposting_provider.dart';
import '../../jobseeker/providers/jobseeker_provider.dart';
import '../../screens/home_screen.dart';
import '../widgets/my_applicants_card.dart';

class MyJobApplicationsPage extends StatefulWidget {
  final String? jobSeekerId;
  final bool   standAlone;           // ⇦ add this flag (default = false)
  const MyJobApplicationsPage({
    Key? key,
    this.jobSeekerId,
    this.standAlone = false,
  }) : super(key: key);

  @override
  State<MyJobApplicationsPage> createState() => _MyJobApplicationsPageState();
}

class _MyJobApplicationsPageState extends State<MyJobApplicationsPage> {
  /* ── state ────────────────────────────────────────────── */
  bool _loading = true;
  final _cacheKey   = 'cached_my_applications';
  final _fallbackJob = JobPostingModel(jobTitle: 'غير معروف');

  List<ApplicantsModel> _apps = [];
  Map<String,String>   _user  = {};

  /* ── providers ────────────────────────────────────────── */
  late ApplicantsProvider                _app;
  late JobPostingRetroDisplayGetProvider _jobs;

  @override
  void initState() {
    super.initState();
    _app  = context.read<ApplicantsProvider>();
    _jobs = context.read<JobPostingRetroDisplayGetProvider>();
    _bootstrap();
  }

  /* ── bootstrap (cache → network) ──────────────────────── */
  Future<void> _bootstrap() async {
    // 1) show the spinner
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id')?.trim();
    debugPrint("🔍 prefs['user_id'] = $userId");
    debugPrint("🔍 widget.jobSeekerId = ${widget.jobSeekerId}");

    // 2) show any cached applications
    final cached = await _readCache();
    if (cached.isNotEmpty) {
      _apps = cached;
      setState(() => _loading = false);
    }

    // 3) if no userId, bail early
    if (userId == null || userId.isEmpty) {
      debugPrint("⚠️ No user_id; skipping live fetch");
      return;
    }

    try {
      // 4) fetch all job postings (needed to resolve the job details)
      await _jobs.fetchAllJobPostings();

      // 5) fetch *this user’s* applications
      //    (server expects job_seeker=<USER_ID>)
      await _app.fetchCurrentUserApplications(userId);

      // 6) sort newest→oldest
      _apps = _app.applicants
        ..sort((a, b) {
          final da = DateTime.parse(a.createDate ?? '');
          final db = DateTime.parse(b.createDate ?? '');
          return db.compareTo(da);
        });

      debugPrint("✅ Fetched ${_apps.length} live applications");

      // 7) cache them
      await _writeCache(_apps);

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint("❌ fetchCurrentUserApplications failed: $e");
      // leave whatever is in _apps (either cache or empty)
      if (mounted) setState(() => _loading = false);
    }
  }

  /* ── cache helpers ────────────────────────────────────── */
  Future<List<ApplicantsModel>> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_cacheKey);
    if (raw==null) return [];
    try{
      final list = jsonDecode(raw) as List;
      return list.map((e)=>ApplicantsModel.fromJson(e)).toList();
    }catch(_){return [];}
  }
  Future<void> _writeCache(List<ApplicantsModel> list) async{
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((e)=>e.toJson()).toList());
    await prefs.setString(_cacheKey, raw);
  }

/*  build()  -------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    final allJobs = _jobs.jobPostings;

    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _apps.isEmpty
        ? const Center(child: Text('لا توجد طلبات بعد'))
        : ListView.builder(
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

    /* ▸ If we opened the page      via Navigator.push(... standAlone:true)
     ▸ we wrap the body with a Scaffold + RacheetaAppBar
     ▸ Otherwise (inside HomeScreen tab) we return only the body.        */
    if (widget.standAlone) {
      return Scaffold(
        appBar: const RacheetaAppBar(
          title           : 'طلباتي الوظيفية',
          showNotification: true,
          showLogout      : true,
        ),
        body: body,
      );
    }

    // inside the tab-shell → no extra bar
    return body;
  }

}
