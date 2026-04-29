import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../screens/hsp_profile_reservation_screen.dart';

class HspsMapCard extends StatelessWidget {
  final Map<String, dynamic> hsp;
  const HspsMapCard({Key? key, required this.hsp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = hsp['name'] ?? 'اسم غير متوفر';
    final String bio = hsp['bio'] ?? '';
    final String phone = hsp['phone'] ?? 'غير متوفر';
    final String addr = hsp['address'] ?? '';
    final double rating = (hsp['reviewsAvg'] ?? (Random().nextDouble() * 1.25 + 3.0)).toDouble();

    final String img = hsp['profileImage'] ?? '';
    final ImageProvider avatar = img.startsWith('http')
        ? NetworkImage(img)
        : const AssetImage('assets/images/default_avatar.png');

    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.5; // Responsive width
    final double avatarRadius = cardWidth * 0.15;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HSPProfileReservationPage(hsp: hsp),
        ),
      ),
      child: SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: avatarRadius, backgroundImage: avatar),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      bio,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '📞 $phone',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (addr.isNotEmpty)
                  Text(
                    addr,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => Icon(
                    i < rating.floor() ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.orange,
                  )),
                ),
                Text(
                  '⭐ ${rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
