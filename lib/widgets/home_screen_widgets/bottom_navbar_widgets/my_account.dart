import 'package:flutter/material.dart';

class HesabiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('حسابي'),
            trailing: Icon(Icons.arrow_back_ios),
            onTap: () {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => UserProfilePage()),
              // );
            },
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('بطاقات الإئتمان'),
            trailing: Icon(Icons.arrow_back_ios),
            onTap: () {
              // Add navigation or action
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('مساعدة'),
            trailing: Icon(Icons.arrow_back_ios),
            onTap: () {
              // Add navigation or action
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('إعدادات'),
            trailing: Icon(Icons.arrow_back_ios),
            onTap: () {
              // Add navigation or action
            },
          ),
          ListTile(
            leading: Icon(Icons.star_border),
            title: Text('تقييم الأبليكشن'),
            trailing: Icon(Icons.arrow_back_ios),
            onTap: () {
              // Add navigation or action
            },
          ),
        ],
      ),
    );
  }
}
