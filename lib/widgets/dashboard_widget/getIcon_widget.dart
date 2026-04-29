import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget getStatusIcon(String status) {
  switch (status) {
    case 'Confirmed':
      return Icon(Icons.check_circle, color: Colors.green);
    case 'Pending':
      return Icon(Icons.hourglass_empty, color: Colors.orange);
    case 'Cancelled':
      return Icon(Icons.cancel, color: Colors.red);
    default:
      return Icon(Icons.info);
  }
}
