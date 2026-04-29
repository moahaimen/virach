import 'package:flutter/material.dart';
import '../../../../constansts/constants.dart';
import '../../../screens/hsp_profile_reservation_screen.dart';

class HspMapCard extends StatelessWidget {
  final Map<String, dynamic> hsp;

  HspMapCard({required this.hsp});

  @override
  Widget build(BuildContext context) {
    // Provide default values for missing or null fields
    String imagePath =
        hsp['image'] ?? 'assets/images/default.png'; // Fallback image
    String name = hsp['name'] ?? 'Unknown Name';
    String description = hsp['description'] ?? 'No description available';
    String availability = hsp['availability'] ?? 'No availability info';
    double rating = hsp['rating'] ?? 0.0; // Default rating
    int reviews = hsp['reviews'] ?? 0; // Default reviews

    return GestureDetector(
      onTap: () {
        // Navigate to the HSP profile/reservation page when the card is tapped
        // Make sure you have a valid screen to navigate to.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HSPProfileReservationPage(hsp: hsp),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HSP image (Circle Avatar)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(hsp['image']),
                ),
              ),
              // HSP Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      hsp['name'],
                      style: kDoctorDescrpitionTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      hsp['description'],
                      style: kHspDescriptionTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hsp['availability'],
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Rating & reviews
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < hsp['rating'].floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'التقييم العام من ${hsp['reviews']} زائر',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
