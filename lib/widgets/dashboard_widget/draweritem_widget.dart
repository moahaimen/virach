import "package:flutter/material.dart";

// A reusable ListTile widget for the drawer
Widget buildDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required Widget destination,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    },
  );
}
