import 'package:flutter/material.dart';

class HspTodayAppointmentHeaderRow extends StatelessWidget {
  final String sortedBy;
  final bool ascending;
  final Function(String) onSortColumn;

  const HspTodayAppointmentHeaderRow({
    Key? key,
    required this.sortedBy,
    required this.ascending,
    required this.onSortColumn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 30,
        ),
        Expanded(
          flex: 2,
          child: _buildSortableColumnHeader('الاسم', 'patientName'),
        ),
        // Expanded(
        //   flex: 2,
        //   child: _buildSortableColumnHeader('التاريخ', 'date'),
        // ),
        const SizedBox(
          width: 30,
        ),
        Expanded(
          flex: 2,
          child: _buildSortableColumnHeader('الحالة', 'status'),
        ),
        const Expanded(
          flex: 2,
          child: Text(
            'موعد المراجعة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSortableColumnHeader(String title, String column) {
    return InkWell(
      onTap: () => onSortColumn(column),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (sortedBy == column)
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
        ],
      ),
    );
  }
}
