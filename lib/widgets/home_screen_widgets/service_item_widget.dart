// import 'package:flutter/material.dart';
//
// class ServiceItem extends StatefulWidget {
//   @override
//   _ServiceItemState createState() => _ServiceItemState();
// }
//
// class _ServiceItemState extends State<ServiceItem> {
//   final List<Map<String, String>> services = [
//     {
//       'image': 'assets/icons/doctor.png', // Placeholder for actual image path
//       'title': 'زيارة منزلية',
//       'description': 'اختر التخصص، والدكتور هيجييلك البيت.',
//       'buttonText': 'احجز زيارة',
//     },
//     {
//       'image': 'assets/icons/doctor.png', // Placeholder for actual image path
//       'title': 'مكالمة دكتور',
//       'description': 'للمتابعة عبر مكالمة صوتية أو مكالمة فيديو.',
//       'buttonText': 'احجز الآن',
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: services.length,
//       itemBuilder: (context, index) {
//         var service = services[index];
//         return GestureDetector(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) =>
//                     ServiceDetailScreen(serviceDetail: service),
//               ),
//             );
//           },
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             elevation: 4,
//             margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Image.asset(service['image']!, height: 120),
//                   const SizedBox(height: 10),
//                   Text(
//                     service['title']!,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     service['description']!,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               ServiceDetailScreen(serviceDetail: service),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       backgroundColor: Colors.lightBlue[100],
//                     ),
//                     child: Text(
//                       service['buttonText']!,
//                       style: const TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//       shrinkWrap: true, // Ensure ListView takes only necessary space
//       physics: const NeverScrollableScrollPhysics(), // Disable scrolling
//     );
//   }
// }
//
// class ServiceDetailScreen extends StatelessWidget {
//   final Map<String, String> serviceDetail;
//
//   ServiceDetailScreen({required this.serviceDetail});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(serviceDetail['title']!),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Image.asset(serviceDetail['image']!),
//               const SizedBox(height: 8.0),
//               Text(
//                 serviceDetail['title']!,
//                 style:
//                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8.0),
//               Text(
//                 serviceDetail['description']!,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../features/doctors/screens/search_doctor_screen.dart';

class ServiceItem extends StatelessWidget {
  ServiceItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String title       = 'تكلم مع طبيب';                 // ← NEW
    const String description = 'اختر التخصص الذي تريد وتكلم مع طبيب'; // ← NEW
    const String imagePath   = 'assets/icons/appointment.png'; // ← NEW

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchDoctorPage()),
      ),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        key: UniqueKey(),                // ← NEW
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SearchDoctorPage()),
                        ),
                        style: ElevatedButton.styleFrom(          // ← NEW style
                          backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(              // inherit == true
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('احجز الآن'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  imagePath,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
            ),          ],
        ),
      ),
    );
  }
}
