// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
//
//
// class DoctorForm extends StatefulWidget {
//   @override
//   _DoctorFormState createState() => _DoctorFormState();
// }
//
// class _DoctorFormState extends State<DoctorForm> {
//   Future<List<DoctorAPI>>? _doctorList;
//   String _selectedSpecialty = "Neurology"; // Default specialty
//
//   // List of specialties for the dropdown
//   final List<String> _specialties = [
//     "Neurology",
//     "woman and birth",
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctors();
//   }
//
//   // Fetch the list of doctors based on the selected specialty
//   void _fetchDoctors() {
//     setState(() {
//       print("Selected specialty: $_selectedSpecialty"); // Debugging line
//       _doctorList = Provider.of<DoctorRetroProvider>(context, listen: false)
//           .getDoctorsBySpecialty(
//               _selectedSpecialty); // Pass the selected specialty
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Doctor List'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: DropdownButton<String>(
//               value: _selectedSpecialty,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedSpecialty = newValue!;
//                   _fetchDoctors(); // Fetch doctors based on the new specialty
//                 });
//               },
//               items: _specialties.map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           ),
//           Expanded(
//             child: FutureBuilder<List<DoctorAPI>>(
//               future: _doctorList,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Failed to fetch doctors.'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No doctors found.'));
//                 } else {
//                   List<DoctorAPI> doctors = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: doctors.length,
//                     itemBuilder: (context, index) {
//                       final doctor = doctors[index];
//                       return ListTile(
//                         title: Text(doctor.specialty ?? 'No Specialty'),
//                         subtitle: Text(
//                             'User: ${doctor.user}, Country: ${doctor.country}'),
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
