import 'package:flutter/material.dart';

// class DoctorProfilePage extends StatelessWidget {
//   final Map<String, dynamic> doctor;
//
//   DoctorProfilePage({required this.doctor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(doctor['user'] ?? 'Doctor Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: doctor['profile_image'] != null
//                   ? NetworkImage(
//                       doctor['profile_image']) // if image URL is provided
//                   : AssetImage('assets/images/default_profile.png'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               doctor['user'] ?? 'Unknown',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(doctor['bio'] ?? 'No bio available'),
//             SizedBox(height: 20),
//             Text('التخصص: ${doctor['specialty'] ?? 'N/A'}'),
//             SizedBox(height: 10),
//             Text('الشهادات: ${doctor['degrees'] ?? 'N/A'}'),
//             SizedBox(height: 10),
//             Text('الانتظار: ${doctor['availability_time'] ?? 'N/A'}'),
//             SizedBox(height: 10),
//             Text('السعر: ${doctor['advertise_price'] ?? 'N/A'}'),
//             SizedBox(height: 10),
//             Text('العنوان: ${doctor['address'] ?? 'N/A'}'),
//             SizedBox(height: 10),
//             Text('رقم الهاتف: ${doctor['phone_number'] ?? 'N/A'}'),
//             SizedBox(height: 10),
//             Text(
//                 'زيارات منزلية: ${doctor['home_visit'] == true ? 'Yes' : 'No'}'),
//             SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }
