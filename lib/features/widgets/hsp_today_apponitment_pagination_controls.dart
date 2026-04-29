import 'package:flutter/material.dart';

class HspToadyAppointmentPaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  const HspToadyAppointmentPaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onNextPage,
    required this.onPreviousPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1 ? onPreviousPage : null,
          child: Text('السابق'),
        ),
        Text('صفحة $currentPage'),
        ElevatedButton(
          onPressed:
              currentPage * itemsPerPage < totalItems ? onNextPage : null,
          child: Text('التالي'),
        ),
      ],
    );
  }
}
