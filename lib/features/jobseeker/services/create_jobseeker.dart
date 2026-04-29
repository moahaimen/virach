// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/jobseeker_provider.dart';
//
// class CreateJobSeekerPage extends StatefulWidget {
//   @override
//   _CreateJobSeekerPageState createState() => _CreateJobSeekerPageState();
// }
//
// class _CreateJobSeekerPageState extends State<CreateJobSeekerPage> {
//   bool isCreating = false;
//
//   @override
//   initState() {
//     super.initState();
//     Provider.of<JobSeekerRetroDisplayGetProvider>(context, listen: false)
//         .createUser()
//         .then(
//       (v) async {
//         Provider.of<JobSeekerRetroDisplayGetProvider>(context, listen: false)
//             .createJobSeeker(user: v?.id);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create User and Doctor"),
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
