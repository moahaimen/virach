import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/medical_centers_providers.dart';

class CreateMedicalCentersPage extends StatefulWidget {
  @override
  _CreateMedicalCentersPageState createState() =>
      _CreateMedicalCentersPageState();
}

class _CreateMedicalCentersPageState extends State<CreateMedicalCentersPage> {
  bool isCreating = false;

  @override
  initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create MedicalCenters"),
      ),
      body: Center(
        child: isCreating
            ? CircularProgressIndicator() // Show loading while creating
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Create User and Doctor'),
                  ),
                ],
              ),
      ),
    );
  }
}
