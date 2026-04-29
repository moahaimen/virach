import 'package:flutter/material.dart';

class ServiceItem extends StatefulWidget {
  @override
  _ServiceItemState createState() => _ServiceItemState();
}

class _ServiceItemState extends State<ServiceItem> {
  final List<Map<String, String>> services = [
    {
      'image': 'assets/banner2.jpg', // Placeholder for actual image path
      'title': 'زيارة منزلية',
      'description': 'اختر التخصص، والدكتور هيجييلك البيت.',
      'buttonText': 'احجز زيارة',
    },
    {
      'image': 'assets/banner3.jpg', // Placeholder for actual image path
      'title': 'مكالمة دكتور',
      'description': 'للمتابعة عبر مكالمة صوتية أو مكالمة فيديو.',
      'buttonText': 'احجز الآن',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: services.map((service) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ServiceDetailScreen(serviceDetail: service),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.asset(
                      service['image']!,
                      height: 140,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            service['title']!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            service['description']!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ServiceDetailScreen(
                                        serviceDetail: service),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                              child: Text(
                                service['buttonText']!,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, String> serviceDetail;

  ServiceDetailScreen({required this.serviceDetail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceDetail['title']!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(serviceDetail['image']!)),
              SizedBox(height: 8.0),
              Text(
                serviceDetail['title']!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                serviceDetail['description']!,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
