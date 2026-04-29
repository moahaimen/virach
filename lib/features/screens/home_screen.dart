// lib/widgets/home_screen_widgets/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../token_provider.dart';
import '../../widgets/home_screen_widgets/appBar_widget.dart';
import '../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../../widgets/home_screen_widgets/bottom_navbar_widgets/main_tab_widget.dart';

import '../../widgets/home_screen_widgets/my_applications_tab.dart';
import '../jobposting/provider/jobposting_provider.dart';
import '../jobposting/screens/alljob_postings_screen.dart';
import '../jobposting/screens/my_application_page.dart';
import '../jobseeker/widgets/myaccount_widgets/my_account_drawer_widget.dart';
import '../notifications/providers/notifications_provider.dart';
import '../notifications/screens/notification_list_page.dart';
import '../registration/patient/screen/my_reservations.dart';
import '../registration/patient/screen/patient_login.dart';



class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  Map<String, String> _userData = {
    'user_id': '',
    'full_name': '',
    'email': '',
    'phone_number': '',
    'degree': '',
    'specialty': '',
    'address': '',
    'gender': '',
    'jobseeker_id': '',
  };

  final List<String> _appBarTitles = [
    'الرئيسية',
    'حجوزاتي',
    'وظائف',
    'طلباتي للوظائف',
    'مرحباً بك في راجيتة',
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
      'user_id'      : prefs.getString('user_id')      ?? '',
      'jobseeker_id' : prefs.getString('jobseeker_id') ?? '',
      // … other fields …
    };

    // nothing to do if we still don’t know the id
    if (_userData['jobseeker_id']!.isEmpty &&
        _userData['user_id']!.isEmpty) return;

    // ── now we can safely build the tabs ──
    _tabs = [
      const HomeTabPage(),
      MyReservationsPage(),
      const AllJobPostingsPage(),
      MyJobApplicationsPage(
        jobSeekerId: _userData['jobseeker_id']!.isNotEmpty
            ? _userData['jobseeker_id']!
            : _userData['user_id']!,
      ),
      JobSeekerAccount(userData: _userData),
    ];
    // _tabs = [
    //   const HomeTabPage(),
    //   MyReservationsPage(),
    //   const AllJobPostingsPage(),
    //   // ← NEW:
    //   MyApplicationsTab(jobSeekerId: _userData['jobseeker_id']!),
    //   JobSeekerAccount(userData: _userData),
    // ];

    if (mounted) setState(() {});       // show UI only when ready
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Provider.of<TokenProvider>(context, listen: false).updateToken('');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) =>  LoginPatientScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs == null || _tabs!.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tab = _tabs![_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xfff0f4f7),

      appBar: RacheetaAppBar(
            title           : _appBarTitles[_currentIndex],
            showNotification: true,                      // ← always show bell
          showLogout      : true,                      // ← always show logout
        onLogout: _logout,
           ),
      body: tab,
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
    );
  }

}


