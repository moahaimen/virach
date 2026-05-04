import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/token_provider.dart';
import 'package:racheeta/widgets/home_screen_widgets/appBar_widget.dart';
import 'package:racheeta/widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import 'package:racheeta/widgets/home_screen_widgets/bottom_navbar_widgets/main_tab_widget.dart';

import '../jobposting/screens/alljob_postings_screen.dart';
import '../jobposting/screens/my_application_page.dart';
import '../jobseeker/widgets/myaccount_widgets/my_account_drawer_widget.dart';
import '../notifications/screens/notification_list_page.dart';
import '../registration/patient/screen/my_reservations.dart';
import '../registration/patient/screen/patient_login.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  Map<String, String> _userData = {
    'user_id': '',
    'full_name': '',
    'jobseeker_id': '',
  };

  final List<String> _appBarTitles = [
    'الرئيسية',
    'حجوزاتي',
    'وظائف طبية',
    'طلبات التوظيف',
    'حسابي',
  ];

  List<Widget>? _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    _userData = {
      'user_id': prefs.getString('user_id') ?? '',
      'jobseeker_id': prefs.getString('jobseeker_id') ?? '',
    };

    if (_userData['user_id']!.isEmpty) return;

    _tabs = [
      const HomeTabPage(),
      const MyReservationsPage(),
      const AllJobPostingsPage(),
      MyJobApplicationsPage(
        jobSeekerId: _userData['jobseeker_id']!.isNotEmpty ? _userData['jobseeker_id']! : _userData['user_id']!,
      ),
      JobSeekerAccount(userData: _userData),
    ];

    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    context.read<TokenProvider>().updateToken('');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPatientScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs == null || _tabs!.isEmpty) {
      return const Scaffold(
        backgroundColor: RacheetaColors.surface,
        body: Center(child: CircularProgressIndicator(color: RacheetaColors.primary)),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: RacheetaAppBar(
          title: _appBarTitles[_currentIndex],
          showNotification: true,
          showLogout: true,
          onLogout: _logout,
          onNotificationTap: () {
            final userId = _userData['user_id'] ?? '';
            if (userId.isNotEmpty) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationListPage(userId: userId)));
            }
          },
        ),
        body: _tabs![_currentIndex],
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _currentIndex,
          userData: _userData,
          useNavigation: false,
          onTabSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
