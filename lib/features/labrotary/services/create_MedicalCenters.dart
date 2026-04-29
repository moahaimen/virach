// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/labs_provider.dart';
//
// class CreateLabrotaryPage extends StatefulWidget {
//   @override
//   _CreateLabrotaryPageState createState() => _CreateLabrotaryPageState();
// }
//
// class _CreateLabrotaryPageState extends State<CreateLabrotaryPage> {
//   bool isCreating = false;
//
//   @override
//   initState() {
//     super.initState();
//
//     Provider.of<LabsRetroDisplayGetProvider>(context, listen: false)
//         .createLaboratory(
//         userModel: 'createdUser',
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
