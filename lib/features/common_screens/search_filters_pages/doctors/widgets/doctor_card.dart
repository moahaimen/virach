// common_screens/…/doctors/widgets/doctor_card.dart
import 'package:flutter/material.dart';
import 'package:racheeta/features/doctors/models/doctors_model.dart';

import '../../../../../constansts/constants.dart';
import '../../../../../utitlites/buid_stars.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  Widget _buildAvatar() {
    final profileImage = doctor.user?.profileImage;
    if (profileImage != null && profileImage.isNotEmpty) {
      return Image.network(
        profileImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/icons/doctor_icon.png',
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      'assets/icons/doctor_icon.png',
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    /*──────────────── قيم التقييم ────────────────*/
    final double rating  = doctor.reviewsAvg  ?? 3.5;                //  ⭐️
    final int    reviews = doctor.reviewsCount ?? 90;                //  عدد المراجعات

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /*──────── لافتة الإعلان ────────*/
            if (doctor.advertise == true)
              Container(
                width: MediaQuery.of(context).size.width * .30,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.blue,
                child: const Text('إعلان',
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
              ),

            /*──────── بيانات الطبيب ────────*/
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* صورة البروفايل */
                  ClipOval(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: _buildAvatar(),
                    ),
                  ),
                  const SizedBox(width: 16),

                  /* نصوص المعلومات */
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /* الاسم والتخصص */
                        Text(doctor.user?.fullName ?? 'اسم غير متوفر',
                            style: kDoctorCardNameTextStyle),
                        Text(doctor.specialty ?? 'تخصص غير متوفر',
                            style: kDoctorCardSpecialtyTextStyle),
                        const SizedBox(height: 8),

                        /* النجوم + عدد المراجعات */
                        // داخل build() فى DoctorCard … بدل الـ Row الحالى بهذا:
// ⭐⭐⭐⭐★ + عدد المراجعات
                        Row(
                          children: [
                            ...buildStars(rating, size: 18),          // ⭐⭐⭐★☆
                            const SizedBox(width: 4),
                            Text('($reviews)',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),



                        const SizedBox(height: 8),

                        /* العنوان */
                        Row(
                          children: [
                            const Icon(Icons.place, color: Colors.blue, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                doctor.address ?? 'لا يوجد عنوان',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        /* نبذة مختصرة */
                        if (doctor.bio?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(doctor.bio!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                const TextStyle(fontSize: 13, color: Colors.grey)),
                          ),

                        const SizedBox(height: 8),

                        /* وقت التوفر */
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              doctor.availabilityTime ?? 'غير متوفر',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /*──────── زر الحجز ────────*/
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(112, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    ),
                    child: const Text('احجز الآن',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const Spacer(),
                  /* السعر إن أردت عرضه
                  Text('${doctor.price ?? '-'} الف د.',
                       style: const TextStyle(fontWeight: FontWeight.bold)), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
