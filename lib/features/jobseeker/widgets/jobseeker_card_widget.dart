import 'package:flutter/material.dart';

import '../models/jobseeker_model.dart';

class JobseekerCard extends StatelessWidget {
  final JobSeekerModel jobSeeker;
  final VoidCallback onTap;
  bool isAdvertised = true;

  JobseekerCard({required this.jobSeeker, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            // Advertisement Banner
            if (isAdvertised == true)
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.blue,
                child: const Text(
                  'إعلان',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Job Seeker Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Seeker Profile Image
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('assets/icons/jobseeker_icon.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Seeker Name
                        Text(
                          jobSeeker.user?.fullName ?? 'اسم غير متوفر',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Job Seeker Specialty
                        Text(
                          jobSeeker.specialty ?? 'تخصص غير متوفر',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Job Seeker Star Rating (Placeholder)
                        // Row(
                        //   children: List.generate(5, (index) {
                        //     double averageRating = double.tryParse(
                        //         jobSeeker.rating?.toString() ?? '0') ??
                        //         0;
                        //     return Icon(
                        //       index < averageRating.floor()
                        //           ? Icons.star
                        //           : Icons.star_border,
                        //       color: Colors.orange,
                        //       size: 16,
                        //     );
                        //   }),
                        // ),
                        const SizedBox(height: 8),
                        // Job Seeker Address
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.place, color: Colors.blue),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                jobSeeker.address ?? 'لا يوجد عنوان',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        // Job Seeker Description/Bio
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.info, color: Colors.blue),
                            const SizedBox(width: 8),
                            // Flexible(
                            //   child: Text(
                            //     jobSeeker.bio ?? 'لا يوجد وصف',
                            //     style: const TextStyle(fontSize: 14),
                            //   ),
                            // ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                jobSeeker.degree ?? 'لا يوجد شهادة',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Job Seeker Availability Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.access_time, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              jobSeeker.specialty ?? 'غير متوفر',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Booking Button
                  ElevatedButton(
                    onPressed: () {
                      print("Booking Button Pressed for: $jobSeeker");
                      onTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 8),
                    ),
                    child: const Text(
                      'احجز الآن',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  // Availability Time
                  Flexible(
                    child: Text(
                      jobSeeker.address ?? 'العنوان غير متوفر ',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
