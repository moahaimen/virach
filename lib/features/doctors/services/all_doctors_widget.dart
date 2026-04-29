// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../../doctor_user_profile_screen.dart';
// // import '../models/jobseeker_model.dart';
// // import '../providers/hospital_display_provider.dart';
// //
// // class AllDoctorsPage extends StatefulWidget {
// //   @override
// //   _AllDoctorsPageState createState() => _AllDoctorsPageState();
// // }
// //
// // class _AllDoctorsPageState extends State<AllDoctorsPage> {
// //   Future<List<DoctorsAPI>>? _doctorsList;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchAllDoctors();
// //   }
// //
// //   void _fetchAllDoctors() {
// //     setState(() {
// //       _doctorsList =
// //           Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false)
// //               .getAllDoctors();
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('All Doctors'),
// //       ),
// //       body: FutureBuilder<List<DoctorsAPI>>(
// //         future: _doctorsList,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           } else if (snapshot.hasError) {
// //             return Center(child: Text('Failed to fetch doctors.'));
// //           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //             return Center(child: Text('No doctors found.'));
// //           } else {
// //             List<DoctorsAPI> doctors = snapshot.data!;
// //             return ListView.builder(
// //               itemCount: doctors.length,
// //               itemBuilder: (context, index) {
// //                 final doctor = doctors[index];
// //                 return ListTile(
// //                   title: Text(doctor.user ?? 'No Name'),
// //                   subtitle: Text(doctor.specialty ?? 'No Specialty'),
// //                   onTap: () {
// //                     // Navigate to the doctor profile page with doctor details
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) => DoctorProfilePage(
// //                           doctor: {
// //                             'user': doctor.user,
// //                             'specialty': doctor.specialty,
// //                             'degrees': doctor.degrees,
// //                             'bio': doctor.bio,
// //                             'address': doctor.address,
// //                             'availability_time': doctor.availabilityTime,
// //                             'advertise_price': doctor.advertisePrice,
// //                             'is_international': doctor.isInternational,
// //                             'country': doctor.country,
// //                           },
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 );
// //               },
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../doctor_user_profile_screen.dart';
// import '../../doctor_profile_screen.dart';
// import '../models/jobseeker_model.dart';
// import '../providers/hospital_display_provider.dart';
//
// class NeurologyDoctorsPage extends StatefulWidget {
//   @override
//   _NeurologyDoctorsPageState createState() => _NeurologyDoctorsPageState();
// }
//
// class _NeurologyDoctorsPageState extends State<NeurologyDoctorsPage> {
//   Future<List<DoctorsAPI>>? _neurologyDoctorsList;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchNeurologyDoctors();
//   }
//
//   void _fetchNeurologyDoctors() {
//     setState(() {
//       _neurologyDoctorsList = Provider.of<DoctorRetroDisplayGetProvider>(
//         context,
//         listen: false,
//       ).getDoctorsBySpecialty("Neurology"); // Fetch only Neurology doctors
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Neurology Doctors'),
//       ),
//       body: FutureBuilder<List<DoctorsAPI>>(
//         future: _neurologyDoctorsList,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Failed to fetch doctors.'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No Neurology doctors found.'));
//           } else {
//             List<DoctorsAPI> doctors = snapshot.data!;
//             return ListView.builder(
//               itemCount: doctors.length,
//               itemBuilder: (context, index) {
//                 final doctor = doctors[index];
//                 return ListTile(
//                   title: Text(doctor.user ?? 'No Name'),
//                   subtitle: Text(doctor.specialty ?? 'No Specialty'),
//                   onTap: () {
//                     // Navigate to the doctor profile page with doctor details
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DoctorProfilePage(
//                             // doctor: {
//                             //   'user': doctor.user,
//                             //   'specialty': doctor.specialty,
//                             //   'degrees': doctor.degrees,
//                             //   'bio': doctor.bio,
//                             //   'address': doctor.address,
//                             //   'availability_time': doctor.availabilityTime,
//                             //   'advertise_price': doctor.advertisePrice,
//                             //   'is_international': doctor.isInternational,
//                             //   'country': doctor.country,
//                             // },
//                             ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
