import 'package:flutter/material.dart';
import '../../../../constansts/constants.dart';
import '../../../../utitlites/buid_stars.dart'; // Make sure this exists and is imported

class HSPCard extends StatelessWidget {
  final Map<String, dynamic> hsp;
  final VoidCallback onTap;

  const HSPCard({super.key, required this.hsp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double averageRating =
        (hsp['rating'] as num?)?.toDouble() ??
        (hsp['reviewsAvg'] as num?)?.toDouble() ??
        0.0;
    final int numReviews =
        (hsp['reviews'] as int?) ??
        (hsp['reviewsCount'] as int?) ??
        (hsp['numReviews'] as int?) ??
        0;

    final String name = (hsp['name'] ?? hsp['user']?['fullName'] ?? 'اسم غير معروف').toString();
    final String specialty = (hsp['specialty'] ?? 'تخصص غير معروف').toString();
    final String bio = (hsp['bio'] ?? hsp['description'] ?? 'لا يوجد وصف').toString();
    final String address = (hsp['address'] ?? 'عنوان غير معروف').toString();
    final String profileImage =
        (hsp['profileImage'] ?? hsp['user']?['profileImage'] ?? '').toString();
    final String availabilityTime =
        (hsp['availabilityTime'] ?? 'غير متوفر').toString();
    final bool isAdvertised = hsp['advertise'] == true;
    final ImageProvider avatarImage = profileImage.startsWith('http')
        ? NetworkImage(profileImage)
        : profileImage.startsWith('assets/')
            ? AssetImage(profileImage) as ImageProvider
            : const AssetImage('assets/images/default_avatar.png');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isAdvertised)
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                alignment: Alignment.centerRight,
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.blue,
                child: const Text(
                  'إعلان',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: avatarImage,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: kDoctorCardNameTextStyle),
                        if (specialty.isNotEmpty)
                          Text(specialty,
                              style: kDoctorCardSpecialtyTextStyle),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place, color: Colors.blue),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                address,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...buildStars(averageRating, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '($numReviews)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (bio.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              availabilityTime,
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
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: onTap,
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
            ),
          ],
        ),
      ),
    );
  }
}
