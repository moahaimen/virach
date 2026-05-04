import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import '../../../registration/patient/screen/patient_profile_screen.dart';
import 'help_page_widget.dart';

class JobSeekerAccount extends StatefulWidget {
  final Map<String, String> userData;
  const JobSeekerAccount({super.key, required this.userData});

  @override
  State<JobSeekerAccount> createState() => _JobSeekerAccountState();
}

class _JobSeekerAccountState extends State<JobSeekerAccount> {
  bool _isLoading = true;
  late Map<String, String> _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadUserDataFromPrefs();
  }

  Future<void> _loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: RacheetaColors.primary));
    }

    return Scaffold(
      backgroundColor: RacheetaColors.surface,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildUserCard(context),
          const SizedBox(height: 24),
          const RacheetaSectionHeader(title: 'إعدادات الحساب'),
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            label: 'الملف الشخصي',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobSeekerJobseekerSideProfilePage())),
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            label: 'المساعدة والدعم',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpPage())),
          ),
          _buildMenuItem(
            context,
            icon: Icons.star_outline,
            label: 'تقييم التطبيق',
            onTap: () async {
              const url = 'https://play.google.com/store/apps/details?id=com.softwork.racheeta';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.verified_user_outlined,
            label: 'سياسة الخصوصية',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return RacheetaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: RacheetaColors.mintLight,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const Icon(Icons.person, size: 40, color: RacheetaColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['full_name'] ?? '—',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['phone_number'] ?? '—',
            style: const TextStyle(fontSize: 14, color: RacheetaColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return RacheetaCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 16,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: RacheetaColors.mintLight.withOpacity(0.4), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: RacheetaColors.primary),
          ),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: RacheetaColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.arrow_back_ios_new, size: 14, color: RacheetaColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // Handled by HomeScreen callback if needed, but we can do local logout too
        _performLogout(context);
      },
      icon: const Icon(Icons.logout, color: RacheetaColors.danger),
      label: const Text('تسجيل الخروج', style: TextStyle(color: RacheetaColors.danger, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: RacheetaColors.danger, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigator logic is usually in HomeScreen but can be repeated or signaled
  }
}
