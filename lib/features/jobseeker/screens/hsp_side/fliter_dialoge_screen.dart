// import 'package:flutter/material.dart';
//
// class FilterDialog extends StatefulWidget {
//   final Map<String, dynamic> currentFilters;
//   final Function(Map<String, dynamic>) onApplyFilters;
//   final Function() onClearFilters;
//
//   FilterDialog({
//     required this.currentFilters,
//     required this.onApplyFilters,
//     required this.onClearFilters,
//   });
//
//   @override
//   _FilterDialogState createState() => _FilterDialogState();
// }
//
// class _FilterDialogState extends State<FilterDialog> {
//   late Map<String, dynamic> filters;
//
//   @override
//   void initState() {
//     super.initState();
//     filters = Map.from(widget.currentFilters);
//   }
//
//   void _applyFilters() {
//     widget.onApplyFilters(filters);
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       title: Center(
//         child: Text('التصفية',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildDropdownRow(
//             label: 'التخصص',
//             icon: Icons.medical_services,
//             value: filters['specialty'],
//             items: ['طبيب', 'ممرض', 'معالج', 'اخرى'],
//             onChanged: (value) {
//               setState(() {
//                 filters['specialty'] = value;
//               });
//             },
//           ),
//           const SizedBox(height: 20),
//           _buildDropdownRow(
//             label: 'الشهادة',
//             icon: Icons.school,
//             value: filters['degree'],
//             items: ['بكلوريوس', 'ماستر', 'دكتوراه'],
//             onChanged: (value) {
//               setState(() {
//                 filters['degree'] = value;
//               });
//             },
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: _applyFilters,
//           child: Text('تطبيق', style: TextStyle(color: Colors.blue)),
//         ),
//         TextButton(
//           onPressed: widget.onClearFilters, // Clears filters
//           child: Text('مسح الكل', style: TextStyle(color: Colors.red)),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDropdownRow({
//     required String label,
//     required IconData icon,
//     required String? value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.blue),
//         const SizedBox(width: 10),
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: value,
//             items: items.map((item) {
//               return DropdownMenuItem(
//                 value: item,
//                 child: Text(item),
//               );
//             }).toList(),
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               labelText: label,
//               border: OutlineInputBorder(),
//               contentPadding:
//                   EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
