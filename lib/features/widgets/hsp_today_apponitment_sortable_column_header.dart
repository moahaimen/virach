import 'package:flutter/material.dart';

class SortableColumnHeader extends StatelessWidget {
  final String title;
  final String column;
  final String sortedBy;
  final bool ascending;
  final Function(String) onSortColumn;

  SortableColumnHeader({
    required this.title,
    required this.column,
    required this.sortedBy,
    required this.ascending,
    required this.onSortColumn,
  });

  @override
  Widget build(BuildContext context) {
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
