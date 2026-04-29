import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final bool hasNextPage;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  PaginationControls({
    required this.currentPage,
    required this.hasNextPage,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1 ? onPrevious : null,
          child: Text('السابق'),
        ),
        Text('Page $currentPage'),
        ElevatedButton(
          onPressed: hasNextPage ? onNext : null,
          child: Text('التالي'),
        ),
      ],
    );
  }
}
