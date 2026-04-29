import 'package:flutter/material.dart';
import 'hsp_profile_reservation_screen.dart';

class HSPCardScreen extends StatelessWidget {
  final Map<String, dynamic> hsp; // The HSP data from backend
  final Function onTap;

  HSPCardScreen({required this.hsp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    print("Building HSPCardScreen with HSP data: $hsp");

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensures the card doesn't take infinite height
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hsp['advertise'] == true)
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.blue,
                child: const Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text(
                    'إعلان',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: hsp['profileImage'] != null
                        ? NetworkImage(
                            hsp['profileImage']) // Load image from backend
                        : AssetImage('assets/images/default.png')
                            as ImageProvider, // Fallback image
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hsp['name'] ??
                              hsp['hospitalName'] ??
                              hsp['pharmacyName'] ??
                              'Unknown Name',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          hsp['specialty'] ?? 'Unknown Specialty',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < (hsp['rating'] ?? 0).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 16,
                            );
                          }),
                        ),
                        Text(
                          'التقييم العام من ${hsp['reviews'] ?? 0} زائر',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hsp['bio'] ?? 'No description available',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.place, color: Colors.blue),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                hsp['address'] ?? 'No address available',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.monetization_on,
                                color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '${hsp['price'] ?? hsp['advertisePrice'] ?? 0} دينار',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.access_time, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              hsp['availabilityTime'] ?? 'No availability time',
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
            ElevatedButton(
              onPressed: () {
                print('HSP Card tapped: $hsp');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HSPProfileReservationPage(
                      hsp: hsp, // Pass the HSP data to the profile page
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              ),
              child: const Text(
                'احجز الآن',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
