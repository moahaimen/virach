import 'package:flutter/material.dart';

import '../../../features/screens/home_screen.dart';
import '../../applicants/screens/current_jobseeker_applicants_screen.dart';
import '../../jobposting/screens/alljob_postings_screen.dart';
import 'myaccount_widgets/my_account_drawer_widget.dart';

class JobseekerBottomNavbar extends StatelessWidget {
  // تم تصحيح اسم الكلاس
  final int currentIndex;
  final Map<String, String> userData;

  const JobseekerBottomNavbar({
    required this.currentIndex,
    required this.userData,
    Key? key,
  }) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AllJobPostingsPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JobSeekerApplicationsPage(
              jobSeekerId: userData['user_id'] ??
                  '', // تأكد من وجود 'user_id' في userData
            ),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => JobSeekerAccount(
                    userData: {},
                  )),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue, // تأكد من تعيين اللون هنا
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      type: BottomNavigationBarType
          .fixed, // إضافة هذا السطر إذا كان اللون لا يظهر
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        // تم تغيير العناصر لتجنب التكرار
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search), // أيقونة البحث بدلاً من الرئيسية
          label: 'حجوزاتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search), // أيقونة البحث بدلاً من الرئيسية
          label: 'البحث عن وظائف',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'طلباتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }
}
