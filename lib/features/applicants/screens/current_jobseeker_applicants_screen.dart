import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../token_provider.dart';
import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../../common_screens/signup_login/screens/welcome_page.dart';
import '../../doctors/widgets/notification_widgets/notification_badge_widget.dart';
import '../../jobposting/models/jobposting_model.dart';
import '../../jobposting/provider/jobposting_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../providers/applicants_provider.dart';
import '../widgets/jobs_applicants_card.dart';

class JobSeekerApplicationsPage extends StatefulWidget {
  final String jobSeekerId; // ← passed in from caller

  const JobSeekerApplicationsPage({Key? key, required this.jobSeekerId})
      : super(key: key);

  @override
  State<JobSeekerApplicationsPage> createState() =>
      _JobSeekerApplicationsPageState();
}

  // Providers
  class _JobSeekerApplicationsPageState extends State<JobSeekerApplicationsPage> {
  // providers
  late ApplicantsProvider                _applicantsProvider;
  late JobPostingRetroDisplayGetProvider _jobProvider;

  // local copy we can mutate
  late String _jobSeekerId;

  bool _isFetching = true;        // true → show spinner
  Map<String, String> _userData = { /* … same as before … */ };

  /*────────────────────────── init ──────────────────────────*/
  // late String _jobSeekerId;     // keep a local copy for convenience

  @override
  void initState() {
    super.initState();

    _applicantsProvider = context.read<ApplicantsProvider>();
    _jobProvider        = context.read<JobPostingRetroDisplayGetProvider>();

    _jobSeekerId = widget.jobSeekerId;          // whatever was sent by caller
    _kickOffLoads();                            // <‑ helper
    _loadUserDataFromPrefs();                   // existing helper
  }

  /// fetch prefs → id → parallel loads
  Future<void> _kickOffLoads() async {
    if (_jobSeekerId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _jobSeekerId = prefs.getString('jobseeker_id') ?? '';
      debugPrint('⚠️ jobSeekerId came empty, fetched from prefs → $_jobSeekerId');
    }

    await Future.wait([
      _applicantsProvider.fetchCurrentUserApplications(_jobSeekerId),
      _jobProvider.fetchAllJobPostings(),
    ]);

    if (mounted) setState(() => _isFetching = false);
  }

  //
  // /* async helper --------------------------------------------------*/
  // Future<void> _kickOffLoads() async {
  // // 1️⃣ if caller didn’t pass the id, try prefs
  // if (_jobSeekerId.isEmpty) {
  // debugPrint('⚠️ jobSeekerId empty – reading from prefs');
  // final prefs      = await SharedPreferences.getInstance();
  // _jobSeekerId     = prefs.getString('jobseeker_id') ?? '';
  // }
  //
  // // 2️⃣ fetch applications & jobs in parallel
  // await Future.wait([
  // _applicantsProvider.fetchCurrentUserApplications(_jobSeekerId),
  // _jobProvider.fetchAllJobPostings(),
  // ]);
  //
  // if (mounted) setState(() => _isFetching = false);
  // }
  // /*──────────────────────── end init helpers ─────────────────────*/


  /*───────────────────────────────────────────────────────────────*/
  Future<void> _loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        "full_name": prefs.getString("full_name") ?? "غير محدد",
        "email": prefs.getString("email") ?? "غير محدد",
        "phone_number": prefs.getString("phone_number") ?? "غير محدد",
        "gps_location": prefs.getString("gps_location") ?? "غير محدد",
        "gender": prefs.getString("gender") ?? "غير محدد",
        "degree": prefs.getString("degree") ?? "غير محدد",
        "specialty": prefs.getString("specialty") ?? "غير محدد",
        "address": prefs.getString("address") ?? "غير محدد",
      };
    });
  }
  /*───────────────────────────────────────────────────────────────*/

  JobPostingModel _unknownJob = JobPostingModel(jobTitle: 'غير معروف');

  JobPostingModel _getJobDetails(String jobId) {
    return _jobProvider.jobPostings.firstWhere(
          (job) => job.id == jobId,
      orElse: () => _unknownJob,
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Provider.of<TokenProvider>(context, listen: false).updateToken("");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
    );
  }

  /*───────────────────────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    // right at the top of build:
    debugPrint('🔎 Filtering for jobSeekerId = "$_jobSeekerId"');
    debugPrint('📦 ApplicantsProvider has ${_applicantsProvider.applicants.length} items total');

    final notifProvider =
        Provider.of<NotificationsRetroDisplayGetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title:
            const Text('عروض الوظائف', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: NotificationBadge(
              unreadCount: notifProvider.unreadNotificationsCount,
            ),
            onPressed: () {}, // TODO: open notifications page
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/messages'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ApplicantsProvider>(
        builder: (_, provider, __) {
          // 🔒 extra local filter – guarantees we only show *my* applications
          final myApps = provider.applicants
              .where((a) => a.jobSeekerUser?.id == widget.jobSeekerId)
              .toList();
          debugPrint('➡️ myApps.length = ${myApps.length}');

          if (myApps.isEmpty) {
            return const Center(child: Text('لا يوجد طلبات حتى الآن'));
          }

          myApps.sort((a, b) => DateTime.parse(b.createDate ?? '')
              .compareTo(DateTime.parse(a.createDate ?? '')));

          return ListView.builder(
            itemCount: myApps.length,
            itemBuilder: (_, i) {
              final applicant = myApps[i];
              final job = _getJobDetails(applicant.job ?? '');

              return ApplicantCard(
                applicant: applicant,
                job: job,
                showActions: false,

                // required: patch one field on the backend
                onRemotePatch: (newStatus) async {
                  /// return TRUE on success, FALSE on failure
                  final ok = await _applicantsProvider
                      .updateApplicantStatusOnly(applicant.id!, newStatus);
                  return ok;
                },

                // delete (must return bool too)
                onDelete: () async {
                  final ok = await _applicantsProvider.deleteApplicant(applicant.id!);
                  if (ok) {
                    // remove card from list UI
                    setState(() {
                      myApps.removeAt(i);
                    });
                  }
                  return ok; // satisfies the Future<bool> contract
                },
              );
            },
          );
        },
      ),
//   setState(() => myApps.removeAt(i));
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: 3, // or 2, 3, etc.
        userData: _userData,
      ),

    );
  }
}
