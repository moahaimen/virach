// import 'package:flutter/material.dart';
//
// class FCMListener extends StatefulWidget {
//   @override
//   _FCMListenerState createState() => _FCMListenerState();
// }
//
// class _FCMListenerState extends State<FCMListener> {
//   @override
//   void initState() {
//     super.initState();
//     FirebaseMessaging.instance.requestPermission();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text(message.notification?.title ?? 'Notification'),
//           content: Text(message.notification?.body ?? 'You have a new notification'),
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.shrink();
//   }
// }
