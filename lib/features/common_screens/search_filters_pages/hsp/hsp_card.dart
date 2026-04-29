import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../constansts/constants.dart';
import '../../../../utitlites/buid_stars.dart'; // Make sure this exists and is imported

class HSPCard extends StatelessWidget {
  final Map<String, dynamic> hsp;
  final VoidCallback onTap;

  HSPCard({required this.hsp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double averageRating = (hsp['rating'] as double?) ?? 0.0;
    final double rating = hsp['rating'] ?? 3.5;
    final int numReviews = hsp['reviews'] ??
        hsp['reviewsCount'] ??
        hsp['numReviews'] ??
        0; // ✅ unified fallback

    // Determine the type of HSP dynamically
    final bool isDoctor = hsp.containsKey('user') && hsp['user'] is Map;
    final bool isHospital = hsp.containsKey('hospitalName');
    final bool isPharmacy = hsp.containsKey('pharmacyName');
    final bool isTherapist = hsp.containsKey('therapistName');
    final bool isNurse = hsp.containsKey('nurseName');
    final bool isMedicalCenter = hsp.containsKey('centerName');
    final bool isBeautyCenter = hsp.containsKey('beautyCenterName');
    final bool isLab = hsp.containsKey('laboratoryName');

    final String name = isDoctor
        ? hsp['user']['fullName'] ?? 'اسم غير معروف'
        : isHospital
        ? hsp['hospitalName'] ?? 'اسم غير معروف'
        : isPharmacy
        ? hsp['pharmacyName'] ?? 'اسم غير معروف'
        : isBeautyCenter
        ? hsp['beautyCenterName'] ?? 'اسم غير معروف'
        : isTherapist
        ? hsp['therapistName'] ?? 'اسم غير معروف'
        : isNurse
        ? hsp['nurseName'] ?? 'اسم غير معروف'
        : isMedicalCenter || isBeautyCenter
        ? hsp['centerName'] ?? 'اسم غير معروف'
        : isLab
        ? hsp['laboratoryName'] ?? 'اسم غير معروف'
        : 'اسم غير معروف';

    final String specialty = hsp['specialty'] ?? 'تخصص غير معروف';
    final String bio = hsp['bio'] ?? 'لا يوجد وصف';
    final String address = hsp['address'] ?? 'عنوان غير معروف';
    final String profileImage = hsp['profileImage'] ??
        (isDoctor &&
            hsp['user'] != null &&
            hsp['user']['profileImage'] != null
            ? hsp['user']['profileImage']
            : 'assets/icons/default.png');
    final String availabilityTime = hsp['availabilityTime'] ?? 'غير متوفر';
    final bool isAdvertised = hsp['advertise'] ?? false;
    final String reviewsCountStr = numReviews.toString(); // ✅ use the one you just unified

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
                    backgroundImage: profileImage.startsWith('http')
                        ? NetworkImage(profileImage)
                        : AssetImage(profileImage) as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: kDoctorCardNameTextStyle),
                        if (isDoctor || specialty.isNotEmpty)
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
                              '($reviewsCountStr)',
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
