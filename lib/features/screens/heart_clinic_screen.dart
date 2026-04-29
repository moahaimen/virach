import 'package:flutter/material.dart';


class HeartClinicDoctors extends StatelessWidget {
  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'دكتور محمود الزيدي',
      'specialty': 'القلب',
      // 'specialty': 'استشاري جراحة العظام و المفاصل و العمود الفقري',
      'rating': 4.5,
      'reviews': 715,
      'description':
          'عظام متخصص في تغيير المفاصل اصابات ملاعب ومناظير المفاصل.',
      'address': 'شارع السعدون - بداية شارع المشجر',
      'price': 50,
      'waitingTime': '24 دقيقة',
      'availability': 'تفتح العيادة في ٥:٠٠ م',
      'advertisement': true,
      'image': 'assets/banner1.jpg',
      // 'lang':
      // 'lat':
    },
    {
      'name': 'دكتور أحمد خسين',
      'specialty': 'اخصائي جراحة العظام ',
      'rating': 4.0,
      'reviews': 343,
      'description': 'طبيب مفاصل متخصص في عظام بالعين عظام القدم والكاحل.',
      'address': 'الكاظمية شارع 60',
      'price': 25,
      'waitingTime': '20 دقيقة',
      'availability': 'تفتح العيادة في ٤:٠٠ م',
      'advertisement': true,
      'image': 'assets/banner2.jpg',
    },
    // Add more doctor entries here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث بإسم الدكتور أو المستشفى',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('الخريطة'),
                    onPressed: () {},
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.filter_alt),
                    label: const Text('التصفية'),
                    onPressed: () {},
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.sort),
                    label: const Text('الترتيب'),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (doctor['advertisement'])
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                color: Colors.blue,
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 30.0),
                                  child: Text('إعلان',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        AssetImage(doctor['image']),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          doctor['name'],
                                          style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          doctor['specialty'],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children:
                                              List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex <
                                                      doctor['rating'].floor()
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.orange,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                        Text(
                                          'التقييم العام من ${doctor['reviews']} زائر',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          doctor['description'],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Icon(Icons.place,
                                                color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                doctor['address'],
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.monetization_on,
                                                color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${doctor['price']} الف دينار',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.access_time,
                                                color: Colors.green),
                                            SizedBox(width: 8),
                                            Text(
                                              doctor['waitingTime'],
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'التقييم العام من ${doctor['reviews']} زائر',
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 8),
                                    ),
                                    child: const Text(
                                      'احجز الآن',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      doctor['availability'],
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
