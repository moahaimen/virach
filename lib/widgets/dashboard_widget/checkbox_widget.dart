// import'package:flutter/material.dart';
//
// Widget _buildCheckboxRow({
//   required String title,
//   required List<String> options,
//   required List<String> filterKeys,
// }) {
//   return Column(
//     children: [
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(options.length, (index) {
//             return Row(
//               children: [
//                 Text(options[index]),
//                 Checkbox(
//                   value: filters[filterKeys[index]] ?? false,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       filters[filterKeys[index]] = value;
//                     });
//                   },
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//       const Divider(),
//     ],
//   );
// }
