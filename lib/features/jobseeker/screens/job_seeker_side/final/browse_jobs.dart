// import 'package:flutter/material.dart';
//
// class BrowseJobSeekerListScreen extends StatefulWidget {
//   @override
//   _BrowseJobSeekerListScreenState createState() =>
//       _BrowseJobSeekerListScreenState();
// }
//
// class _BrowseJobSeekerListScreenState extends State<BrowseJobSeekerListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _filteredJobSeekers = [];
//   List<Map<String, dynamic>> _allJobSeekers = [
//     {
//       'name': 'Ahmed Hassan',
//       'specialty': 'طبيب',
//       'degree': 'ماستر',
//       'address': 'بغداد',
//       'profileImage': 'https://via.placeholder.com/150',
//     },
//     {
//       'name': 'Sara Ali',
//       'specialty': 'معالج طبيعي',
//       'degree': 'بكلوريوس',
//       'address': 'البصرة',
//       'profileImage': 'https://via.placeholder.com/150',
//     },
//     {
//       'name': 'Mohammed Ahmed',
//       'specialty': 'طبيب',
//       'degree': 'ماستر',
//       'address': 'بغداد',
//       'profileImage': 'https://via.placeholder.com/150',
//     },
//   ];
//
//   String? _selectedSpecialty;
//   String? _selectedDegree;
//   String? _selectedAddress;
//
//   // List of options for filtering
//   final List<String> specialties = ['طبيب', 'معالج طبيعي', 'ممرض', 'مهندس'];
//   final List<String> degrees = ['بكلوريوس', 'ماستر', 'دكتوراه'];
//   final List<String> addresses = ['بغداد', 'البصرة', 'النجف', 'كربلاء'];
//
//   @override
//   void initState() {
//     super.initState();
//     _filteredJobSeekers = _allJobSeekers;
//   }
//
//   void _filterJobSeekers() {
//     String searchQuery = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredJobSeekers = _allJobSeekers.where((jobSeeker) {
//         bool matchesSearchQuery =
//             jobSeeker['name'].toLowerCase().contains(searchQuery) ||
//                 jobSeeker['specialty'].toLowerCase().contains(searchQuery) ||
//                 jobSeeker['address'].toLowerCase().contains(searchQuery);
//
//         bool matchesSpecialty = _selectedSpecialty == null ||
//             jobSeeker['specialty'] == _selectedSpecialty;
//
//         bool matchesDegree =
//             _selectedDegree == null || jobSeeker['degree'] == _selectedDegree;
//
//         bool matchesAddress = _selectedAddress == null ||
//             jobSeeker['address'] == _selectedAddress;
//
//         return matchesSearchQuery &&
//             matchesSpecialty &&
//             matchesDegree &&
//             matchesAddress;
//       }).toList();
//     });
//   }
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         String? _dialogSelectedSpecialty = _selectedSpecialty;
//         String? _dialogSelectedDegree = _selectedDegree;
//         String? _dialogSelectedAddress = _selectedAddress;
//
//         return AlertDialog(
//           title: const Text('التصفية'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'التخصص',
//                   icon: Icon(Icons.add),
//                 ),
//                 value: _dialogSelectedSpecialty,
//                 items: specialties.map((specialty) {
//                   return DropdownMenuItem(
//                     value: specialty,
//                     child: Text(specialty),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _dialogSelectedSpecialty = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'الشهادة',
//                   icon: Icon(Icons.school),
//                 ),
//                 value: _dialogSelectedDegree,
//                 items: degrees.map((degree) {
//                   return DropdownMenuItem(
//                     value: degree,
//                     child: Text(degree),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _dialogSelectedDegree = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'العنوان',
//                   icon: Icon(Icons.location_on),
//                 ),
//                 value: _dialogSelectedAddress,
//                 items: addresses.map((address) {
//                   return DropdownMenuItem(
//                     value: address,
//                     child: Text(address),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _dialogSelectedAddress = value;
//                   });
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close without applying
//               },
//               child: const Text(
//                 'إلغاء',
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _dialogSelectedSpecialty = null;
//                   _dialogSelectedDegree = null;
//                   _dialogSelectedAddress = null;
//                 });
//               },
//               child: const Text(
//                 'مسح',
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedSpecialty = _dialogSelectedSpecialty;
//                   _selectedDegree = _dialogSelectedDegree;
//                   _selectedAddress = _dialogSelectedAddress;
//                 });
//                 _filterJobSeekers();
//                 Navigator.of(context).pop(); // Close after applying
//               },
//               child: const Text(
//                 'تطبيق',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         centerTitle: true,
//         title: DropdownButton<String>(
//           value: 'بغداد',
//           items: ['بغداد'].map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             // Handle location change if necessary
//           },
//           underline: SizedBox(),
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Search Bar
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'ابحث بالتخصص, اسم أو العنوان',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onChanged: (value) {
//                 _filterJobSeekers(); // Apply filter as the user types
//               },
//             ),
//             const SizedBox(height: 10),
//             // Filter and Sort Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _showFilterDialog,
//                   icon: Icon(Icons.filter_list),
//                   label: Text(
//                     'التصفية',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     textStyle: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _showSortOptions,
//                   icon: Icon(Icons.sort),
//                   label: Text(
//                     'الترتيب',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     textStyle: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             // Job Seeker List
//             Expanded(
//               child: _filteredJobSeekers.isEmpty
//                   ? const Center(
//                       child: Text(
//                         'لا يوجد باحثين عن عمل',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: _filteredJobSeekers.length,
//                       itemBuilder: (context, index) {
//                         final jobSeeker = _filteredJobSeekers[index];
//                         return Card(
//                           margin: EdgeInsets.only(bottom: 10),
//                           elevation: 5,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 CircleAvatar(
//                                   radius: 40,
//                                   backgroundImage:
//                                       NetworkImage(jobSeeker['profileImage']),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         jobSeeker['name'],
//                                         style: TextStyle(
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text('التخصص: ${jobSeeker['specialty']}'),
//                                       Text('الشهادة: ${jobSeeker['degree']}'),
//                                       Text('العنوان: ${jobSeeker['address']}'),
//                                     ],
//                                   ),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     // Apply action
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   child: Text('تقديم',
//                                       style: TextStyle(color: Colors.white)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showSortOptions() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled:
//           true, // This makes sure it doesn't restrict the content size
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           height: MediaQuery.of(context).size.height *
//               0.5, // Adjust height as needed
//           child: ListView(
//             children: [
//               const Center(
//                 child: Text(
//                   'الترتيب',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const Divider(),
//               ListTile(
//                 title: const Text('ترتيب أبجدي أ الى ي'),
//                 onTap: () {
//                   _sortList('name_asc');
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('ترتيب أبجدي ي الى أ'),
//                 onTap: () {
//                   _sortList('name_desc');
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('التخصص'),
//                 onTap: () {
//                   _sortList('specialty');
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('الشهادة'),
//                 onTap: () {
//                   _sortList('degree');
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('العنوان'),
//                 onTap: () {
//                   _sortList('address');
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _sortList(String criterion) {
//     setState(() {
//       if (criterion == 'name_asc') {
//         _filteredJobSeekers.sort((a, b) => a['name'].compareTo(b['name']));
//       } else if (criterion == 'name_desc') {
//         _filteredJobSeekers.sort((a, b) => b['name'].compareTo(a['name']));
//       } else if (criterion == 'specialty') {
//         _filteredJobSeekers
//             .sort((a, b) => a['specialty'].compareTo(b['specialty']));
//       } else if (criterion == 'degree') {
//         _filteredJobSeekers.sort((a, b) => a['degree'].compareTo(b['degree']));
//       } else if (criterion == 'address') {
//         _filteredJobSeekers
//             .sort((a, b) => a['address'].compareTo(b['address']));
//       }
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:racheeta/constansts/constants.dart';
import 'package:racheeta/features/jobseeker/generiled_widget/general_fliter_dialoge.dart';
import 'package:racheeta/features/jobseeker/generiled_widget/general_sort_bottom_sheet.dart';
import '../../../generiled_widget/general_card_widget.dart';
import '../../../generiled_widget/generilized_filter_manager.dart';
import 'hsp_job_owner_profile.dart';

class BrowseJobOffersScreen extends StatefulWidget {
  @override
  _BrowseJobOffersScreenState createState() => _BrowseJobOffersScreenState();
}

class _BrowseJobOffersScreenState extends State<BrowseJobOffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredJobOffers = [];
  final List<String> specialties = [
    'Doctor',
    'Physiotherapist',
    'Nurse',
    'Engineer'
  ];
  final List<String> degrees = ['Bachelor', 'Master', 'PhD'];
  final List<String> addresses = ['بغداد', 'Basra', 'Najaf', 'Karbala'];
  List<Map<String, dynamic>> _allJobOffers = [
    {
      'name': 'Ahmed Hassan',
      'specialty': 'Doctor',
      'degree': 'Master',
      'address': 'Baghdad',
      'profileImage': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Sara Ali',
      'specialty': 'Physiotherapist',
      'degree': 'Bachelor',
      'address': 'Basra',
      'profileImage': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Mohammed Ahmed',
      'specialty': 'Doctor',
      'degree': 'Master',
      'address': 'Baghdad',
      'profileImage': 'https://via.placeholder.com/150',
    },
  ];

  final FilterManager filterManager = FilterManager();

  @override
  void initState() {
    super.initState();
    _filteredJobOffers = _allJobOffers;
  }

  void _filterJobOffers() {
    setState(() {
      _filteredJobOffers = filterManager.filterData(
        _allJobOffers,
        _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: DropdownButton<String>(
          value: 'Baghdad',
          items: ['Baghdad'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // Handle location change if necessary
          },
          underline: const SizedBox(),
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showFilterDialog(context),
                  icon: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'التصفية',
                    style: kButtonTextStyle,
                  ),
                  style: kBlueButtonStyle,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showSortOptions(context),
                  icon: const Icon(
                    Icons.sort,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'الترتيب',
                    style: kButtonTextStyle,
                  ),
                  style: kBlueButtonStyle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredJobOffers.isEmpty
                  ? const Center(
                      child: Text('لاتوجد عروض عمل'),
                    )
                  : ListView.builder(
                      itemCount: _filteredJobOffers.length,
                      itemBuilder: (context, index) {
                        final jobOffer = _filteredJobOffers[index];
                        return GeneralCardWidget(
                          data: jobOffer,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobOwnerProfilePage(
                                  jobSeeker: jobOffer,
                                ),
                              ),
                            );
                          },
                          buttonText: 'المزيد...',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => GeneralFilterDialog(
        specialties: specialties,
        degrees: degrees,
        addresses: addresses,
        filterTitle: 'تصفية عروض العمل',
        onApplyFilter: (specialty, degree, address) {
          setState(() {
            filterManager.selectedSpecialty = specialty;
            filterManager.selectedDegree = degree;
            filterManager.selectedAddress = address;
            _filterJobOffers();
          });
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => GeneralSortBottomSheet(
        onSort: (criterion) {
          setState(() {
            filterManager.sortData(
              _filteredJobOffers,
              criterion,
            );
          });
        },
        sortTitle: 'رتب عروض العمل',
      ),
    );
  }
}
