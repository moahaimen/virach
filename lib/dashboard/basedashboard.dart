import 'package:flutter/material.dart';
import '../widgets/dashboard_widget/drawer_widget.dart';

class BaseDashboardScreen extends StatelessWidget {
  final String userType;
  final String userId;

  BaseDashboardScreen({required this.userType, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userType Dashboard'), // Title changes based on userType
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.pushNamed(context, '/messages');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
        ],
      ),
      drawer: DrawerWidget(
        userType: userType,
        userId: userId,
      ), // Use DrawerWidget here
      body: Center(
        child: Text(' مرحباً بك في  $userType لوحة تحكم!'),
      ),
    );
  }
}
