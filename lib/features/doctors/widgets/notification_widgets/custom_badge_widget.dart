import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final int count;

  const CustomBadge({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: count > 0
          ? Container(
              key: ValueKey(count),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          : SizedBox(),
    );
  }
}
