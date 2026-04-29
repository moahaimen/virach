// lib/widgets/racheeta_app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/notifications/providers/notifications_provider.dart';
import '../../features/notifications/screens/notification_list_page.dart';
import '../../features/registration/patient/screen/patient_login.dart';
import '../../token_provider.dart';

class RacheetaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final VoidCallback? onNotificationTap;   // ← new
  final bool showLogout;
  final VoidCallback? onLogout;

  const RacheetaAppBar({
    Key? key,
    required this.title,
    this.showNotification = false,
    this.onNotificationTap,                // ← new
    this.showLogout = false,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (showNotification)
          Consumer<NotificationsRetroDisplayGetProvider>(
            builder: (_, notifProv, __) {
              final unread = notifProv.unreadNotificationsCount;
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: onNotificationTap ??
                            () async {
                          // default behavior: grab user_id and push list
                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString('user_id') ?? '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificationListPage(userId: userId),
                            ),
                          );
                        },
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          unread.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout ??
                    () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPatientScreen()),
                  );
                },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
