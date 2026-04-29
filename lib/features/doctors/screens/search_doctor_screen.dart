import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/features/doctors/screens/specialty_doctors_screen.dart';
import '../../../constansts/constants.dart';
import '../../../providers/specialty_provider.dart';
import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart';
import '../../../widgets/home_screen_widgets/bottom_navbar_widgets/my_account.dart';
import '../../screens/home_screen.dart';

class SearchDoctorPage extends StatefulWidget {
  @override
  _SearchDoctorPageState createState() => _SearchDoctorPageState();
}

class _SearchDoctorPageState extends State<SearchDoctorPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSpecialties = [];
  int _currentIndex = 0;
  Map<String, String> _userData = {}; // Add this to your class if not defined.

  // Screens for BottomNavigationBar
  final List<Widget> _screens = [
    HomeScreen(),
    const Center(child: Text('حجوزاتي قيد الإنشاء')), // Placeholder
    HesabiScreen(),
  ];

  final List<Map<String, dynamic>> specialties = [
    {'icon': Icons.book, 'label': 'اشعة وسونار'},
    {'icon': Icons.healing, 'label': 'باطنية'},
    {'icon': Icons.book, 'label': 'cardio'},
    {'icon': Icons.book, 'label': 'bones'},
    {'icon': Icons.book, 'label': 'sycho'},
    {'icon': Icons.book, 'label': 'breasts'},
    {'icon': Icons.local_hospital, 'label': 'امراض دم'},
    {'icon': Icons.brightness_7, 'label': 'اورام'},
    {'icon': Icons.brightness_7, 'label': 'انف واذن وحنجرة'},
    {'icon': Icons.fastfood, 'label': 'النسائية والتوليد'},
    {'icon': Icons.fastfood, 'label': 'تغذية'},
    {'icon': Icons.fastfood, 'label': 'جلدية'},
    {'icon': Icons.fastfood, 'label': 'المجاري البولية'},
    {'icon': Icons.fastfood, 'label': 'تجميل'},
    {'icon': Icons.fastfood, 'label': 'اسنان'},
    {'icon': Icons.fastfood, 'label': 'عيون'},
    {'icon': Icons.fastfood, 'label': 'عقم'},
    {'icon': Icons.fastfood, 'label': 'نسائية'},
    {'icon': Icons.fastfood, 'label': 'جراحة عامة'},
    {'icon': Icons.fastfood, 'label': 'أمراض الدم'},
    {'icon': Icons.fastfood, 'label': 'الطب الرياضي'},
    {'icon': Icons.fastfood, 'label': 'العلاج الطبيعي'},
    {'icon': Icons.fastfood, 'label': 'أطفال'},
    {'icon': Icons.fastfood, 'label': 'أمراض الكلى'},
    {'icon': Icons.fastfood, 'label': 'الغدد الصماء'},
    {'icon': Icons.brightness_5, 'label': 'أورام'},
    {'icon': Icons.bloodtype, 'label': 'مفاصل'},
    {'icon': Icons.balcony, 'label': 'قلبية'},
    {'icon': Icons.healing, 'label': 'مخ واعصاب'},
    {'icon': Icons.healing, 'label': 'طب نفسي'},
    {'icon': Icons.healing, 'label': 'بيطري'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredSpecialties = specialties;
    _searchController.addListener(_filterSpecialties);
  }

  void _filterSpecialties() {
    setState(() {
      String searchQuery = _searchController.text.toLowerCase();
      _filteredSpecialties = specialties.where((specialty) {
        String specialtyLabel = specialty['label'].toLowerCase();
        return specialtyLabel.contains(searchQuery);
      }).toList();
    });
  }

  void _navigateToPage(int index) {
    if (index == 0) {
      // Navigate to HomeScreen when "الرئيسية" is selected
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'أختر التخصص المطلوب',
          style: kAppBarDoctorsTextStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن التخصص',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filteredSpecialties.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            _filteredSpecialties[index]['icon'],
                            size: 30,
                            color: Colors.blue,
                          ),
                          title: Text(
                            _filteredSpecialties[index]['label'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            Provider.of<SpecialtyProvider>(context,
                                    listen: false)
                                .setSpecialty(
                                    _filteredSpecialties[index]['label']);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  body: SpecialtyDoctorsPage(
                                    specialty: _filteredSpecialties[index]
                                        ['label'],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : _screens[_currentIndex], // Show other screens based on the index
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        userData: _userData.isNotEmpty
            ? _userData
            : {
                'user_id': '',
                'full_name': 'مستخدم مجهول',
                'email': 'غير معروف',
                'phone_number': 'غير معروف',
                'degree': 'غير محدد',
                'specialty': 'غير محدد',
                'address': 'غير متوفر',
                'gender': 'غير معروف',
              },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
