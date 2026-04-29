import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../../../registration/patient/screen/patient_profile_screen.dart';
import '../../../screens/home_screen.dart';
import 'help_page_widget.dart';
import 'menu_item_widget.dart';

/* ──────────────────────────────── JOB SEEKER ACCOUNT ───────────────────────── */
class JobSeekerAccount extends StatefulWidget {
  final Map<String, String> userData;
  const JobSeekerAccount({Key? key, required this.userData}) : super(key: key);

  @override
  State<JobSeekerAccount> createState() => _JobSeekerAccountState();
}

class _JobSeekerAccountState extends State<JobSeekerAccount> {
  int _currentIndex = 0;
  bool _isLoading = true;
  late Map<String, String> _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData; // seed
    _loadUserDataFromPrefs();
  }

  Future<void> _loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        'user_id': prefs.getString('user_id') ?? '',
        'full_name': prefs.getString('full_name') ?? 'غير محدد',
        'email': prefs.getString('email') ?? 'غير محدد',
        'phone_number': prefs.getString('phone_number') ?? 'غير محدد',
        'gps_location': prefs.getString('gps_location') ?? 'غير محدد',
        'gender': prefs.getString('gender') ?? 'غير محدد',
        'degree': prefs.getString('degree') ?? 'غير محدد',
        'specialty': prefs.getString('specialty') ?? 'غير محدد',
        'address': prefs.getString('address') ?? 'غير محدد',
        'jobseeker_id': prefs.getString('jobseeker_id') ?? '',
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.blue,
      //   centerTitle: true,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () => Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (_) => HomeScreen()),
      //           (route) => false, // يمسح كل الرُوتات السابقة
      //     )
      //
      //   ),
      //   title: const Text(
      //     'مرحبا بك في راجيتة',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),

      body: ListView(
              children: [
                _UserHeader(data: _userData),
                MenuItem(
                  icon: Icons.person,
                  label: 'حسابي',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JobSeekerJobseekerSideProfilePage(),
                    ),
                  ),
                ),
                MenuItem(
                  icon: Icons.headset_mic,
                  label: 'مساعدة',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HelpPage()),
                  ),
                ),
                MenuItem(
                  icon: Icons.settings,
                  label: 'إعدادات',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JobSeekerJobseekerSideProfilePage(),
                    ),
                  ),
                ),
                MenuItem(
                  icon: Icons.reviews,
                  label: 'تقييم الأبليكشن',
                  onTap: () async {
                    const url = 'https://play.google.com/store/apps/details?id=com.example.racheeta'; // Replace with your real package ID
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('لا يمكن فتح متجر Google Play')),
                      );
                    }
                  },
                ),



    ]
            ),
            // bottomNavigationBar: MainBottomNavBar(
            //   currentIndex: 4,
            //   userData: _userData,
            // ),
          );
  }
}

class _UserHeader extends StatelessWidget {
  final Map<String, String> data;
  const _UserHeader({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('الاسم: ${data['full_name']}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('رقم الهاتف: ${data['phone_number']}'),
          ],
        ),
      );
}
