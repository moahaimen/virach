import 'package:flutter/material.dart';

class TopDoctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Top Doctors',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const ListTile(
            leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/icons/doctor1.png')), // Custom icons
            title: Text('Dr. Shahid Rahman'),
            subtitle: Text('Dental Specialist\n5.0 (95+ reviews)'),
            trailing: Icon(Icons.arrow_forward, color: Colors.blue),
          ),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const ListTile(
            leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/icons/doctor2.png')), // Custom icons
            title: Text('Dr. Akram Chowdhury'),
            subtitle: Text('Ophthalmology Department\n5.0 (90+ reviews)'),
            trailing: Icon(Icons.arrow_forward, color: Colors.blue),
          ),
        ),
      ]),
    );
  }
}
