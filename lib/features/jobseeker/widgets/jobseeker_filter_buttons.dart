import 'package:flutter/material.dart';

class JobSeekerFilterSortButtons extends StatelessWidget {
  final Function onFilter;
  final Function onSort;

  JobSeekerFilterSortButtons({
    required this.onFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.filter_alt),
            label: const Text('التصفية'),
            onPressed: () => onFilter(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.sort),
            label: const Text('الترتيب'),
            onPressed: () => onSort(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
