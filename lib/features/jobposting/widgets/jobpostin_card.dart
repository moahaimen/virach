import 'package:flutter/material.dart';
import '../models/jobposting_model.dart';
import '../screens/job_detail_screen.dart';

class JobPostingCard extends StatelessWidget {
  final JobPostingModel job;
  final VoidCallback onTap;

  const JobPostingCard({
    Key? key,
    required this.job,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show banner if job is "urgent"
    final bool isUrgent = (job.jobStatus?.toLowerCase() == 'urgent');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Top banner
            if (isUrgent)
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.red,
                child: const Text(
                  'Urgent',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Main info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon or something like an image
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade200,
                    child: const Icon(
                      Icons.work,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Job details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          job.jobTitle ?? 'عنوان غير متوفر',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          job.jobDescription ?? 'وصف غير متوفر',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // Qualifications
                        if (job.qualifications != null)
                          Text(
                            'المؤهلات: ${job.qualifications}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        const SizedBox(height: 8),
                        // Specialty
                        if (job.jobTitle != null)
                          Text(
                            'التخصص: ${job.jobTitle}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        const SizedBox(height: 8),
                        // Gender Requirement
                        //  if (job.genderRequirement != null)
                        const Row(
                          children: [
                            Icon(Icons.people, color: Colors.purple),
                            SizedBox(width: 8),
                            Text(
                              //  job.genderRequirement ??
                              'Any',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              job.jobLocation ?? 'لا يوجد موقع',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Salary
                        Row(
                          children: [
                            const Icon(Icons.monetization_on,
                                color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              job.salary ?? 'غير محدد',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Action row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Apply button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsPage(
                            job: job, // the selected job
                            userData: const {
                              // pass the applicant's info
                              "user_id": '6982057f-267f-415f-a163-80e02e46c2fa',
                              "full_name": 'tafh',
                              // ... etc
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 8),
                    ),
                    child: const Text(
                      'قدّم الآن',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  // Job status text
                  Text(
                    job.jobStatus ?? 'غير محدد',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
