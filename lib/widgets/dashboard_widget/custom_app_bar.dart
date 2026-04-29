import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userType;

  CustomAppBar({required this.userType});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title:
          Text(_getAppBarTitle(userType)), // Dynamic title based on user type
      actions: [
        IconButton(
          icon: const Icon(Icons.message),
          onPressed: () {
            Navigator.pushNamed(context, '/messages');
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // Implement log out logic
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  // Function to dynamically return the correct AppBar title
  String _getAppBarTitle(String userType) {
    switch (userType) {
      case 'doctor':
        return 'Doctor Dashboard';
      case 'nurse':
        return 'Nurse Dashboard';
      case 'pharmacist':
        return 'Pharmacist Dashboard';
      default:
        return 'Service Provider Dashboard';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
