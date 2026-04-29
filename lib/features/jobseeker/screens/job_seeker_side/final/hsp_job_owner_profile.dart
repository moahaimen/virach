import 'package:flutter/material.dart';
import 'package:racheeta/features/jobseeker/generiled_widget/contact_information.dart';
import 'package:racheeta/features/jobseeker/generiled_widget/profile_details.dart';
import 'package:racheeta/features/jobseeker/generiled_widget/profile_header.dart';
import 'package:racheeta/features/jobseeker/generiled_widget/rating_section.dart';
import '../../../../../constansts/constants.dart';

class JobOwnerProfilePage extends StatelessWidget {
  final Map<String, dynamic> jobSeeker;

  JobOwnerProfilePage({required this.jobSeeker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          jobSeeker['name'] ?? 'Job Seeker Profile',
          style: kAppBarDoctorsTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(jobSeeker: jobSeeker),
            const SizedBox(height: 20),
            RatingSection(rating: jobSeeker['rating']),
            const SizedBox(height: 20),
            ProfileDetails(jobSeeker: jobSeeker),
            const SizedBox(height: 24),
            ContactInformation(jobSeeker: jobSeeker),
            const SizedBox(height: 40), // Add some space before the button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _sendJobOffer(context),
          style: kElevatedButtonStyle.copyWith(
            minimumSize: MaterialStateProperty.all(
              const Size(double.infinity, 50),
            ),
          ),
          child: const Text(
            'ارسل عرض عمل',
            style: kButtonTextStyle,
          ),
        ),
      ),
    );
  }

  // Function to send a job offer
  void _sendJobOffer(BuildContext context) {
    // Simulate sending a job offer notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال عرض العمل إلى الباحث عن العمل!'),
        duration: Duration(seconds: 2),
      ),
    );

    // Here you can add logic to trigger the notification
    // For example: Call a backend API to send a notification to the job seeker
    // e.g., ApiService.sendJobOffer(jobSeeker['id']);
  }
}

// The other widgets (ProfileHeader, RatingSection, ProfileDetails, ContactInformation)
// can remain unchanged, refactored as described in the previous message.
