// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/nurse_provider.dart';
//
// class CreateNursePage extends StatefulWidget {
//   @override
//   _CreateNursePageState createState() => _CreateNursePageState();
// }
//
// class _CreateNursePageState extends State<CreateNursePage> {
//   bool isCreating = false;
//
//   @override
//   initState() {
//     super.initState();
//
//     Provider.of<NurseRetroDisplayGetProvider>(context, listen: false)
//         .createNurse(
//             isArchived: false,
//             laboratoryName: 'حسان',
//             availableTests:
//                 'كل التحاليل الخاصة بالدم وكل تحاليل النمو والسمنة,',
//             bio: 'Great labs',
//             availabilityTime: '3pm - 9pm',
//             advertise: false,
//             phoneNumber: '12345678911');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create MedicalCenters"),
//       ),
//       body: Center(
//         child: isCreating
//             ? CircularProgressIndicator() // Show loading while creating
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {},
//                     child: Text('Create User and Doctor'),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
