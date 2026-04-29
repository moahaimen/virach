import 'package:flutter/material.dart';
import '../features/screens/home_screen.dart';
import 'home_screen_widgets/bottom_navbar_widgets/my_account.dart';

class CustomBottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBarWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'معاملاتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }
}

class CustomBottomNavBar extends StatefulWidget {
  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Home Screen
    const Center(
      child: Text(
        'معاملاتي',
        style: TextStyle(fontSize: 24),
      ),
    ), // Transactions Screen Placeholder
    HesabiScreen(), // حسابي Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        CustomBottomNavBarWidget(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index; // Update current index
            });
          },
        ),
      ],
    );
  }
}
