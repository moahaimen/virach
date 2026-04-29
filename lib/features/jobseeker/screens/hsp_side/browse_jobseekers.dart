import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constansts/constants.dart';
import '../../../doctors/providers/doctors_provider.dart';
import '../../models/jobseeker_model.dart';
import '../../providers/jobseeker_provider.dart';
import '../../widgets/jobseeker_card_widget.dart';
import '../../widgets/jobseeker_filter_buttons.dart';
import 'job_seeker_profile_screen.dart';

class BrowseJobSeekerListScreen extends StatefulWidget {
  @override
  _BrowseJobSeekerListScreenState createState() =>
      _BrowseJobSeekerListScreenState();
}

class _BrowseJobSeekerListScreenState extends State<BrowseJobSeekerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<JobSeekerModel> _filteredJobSeekers = [];
  List<JobSeekerModel> _allJobSeekers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchJobSeekers();
  }

  /// Fetch Job Seekers from Backend
  void _fetchJobSeekers() async {
    setState(() {
      isLoading = true;
    });
    final provider =
        Provider.of<JobSeekerRetroDisplayGetProvider>(context, listen: false);
    try {
      // Fetch job seekers from the provider
      await provider.fetchJobSeekers();

      // Access the job seekers list from the provider
      setState(() {
        _allJobSeekers =
            provider.jobSeekers; // Get the updated list from the provider
        _filteredJobSeekers = provider.jobSeekers;
      });
    } catch (e) {
      print("Error fetching job seekers: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Filter Job Seekers
  void _filterJobSeekers(String query) {
    setState(() {
      _filteredJobSeekers = _allJobSeekers.where((jobSeeker) {
        final nameLower = jobSeeker.user?.fullName?.toLowerCase() ?? '';
        final specialtyLower = jobSeeker.specialty?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower) ||
            specialtyLower.contains(searchLower);
      }).toList();
    });
  }

  /// Sort Job Seekers
  void _sortJobSeekers() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'الترتيب',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // ListTile(
                //   title: const Text('الأعلى تقييما'),
                //   onTap: () {
                //     setState(() {
                //       _filteredJobSeekers.sort((a, b) {
                //         final ratingA = double.tryParse(a.rating ?? '0') ?? 0.0;
                //         final ratingB = double.tryParse(b.rating ?? '0') ?? 0.0;
                //         return ratingB.compareTo(ratingA);
                //       });
                //     });
                //     Navigator.pop(context);
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Filter Button Logic
  void _applyFilters() {
    // Example: Add your filter logic here
    setState(() {
      _filteredJobSeekers = _filteredJobSeekers.where((jobSeeker) {
        return jobSeeker.specialty?.contains('example filter') ?? true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'البحث عن موظفين',
          style: kAppBarDoctorsTextStyle,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن اسم معين',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _filterJobSeekers,
                ),
                const SizedBox(height: 10),
                JobSeekerFilterSortButtons(
                  onFilter: _applyFilters,
                  onSort: _sortJobSeekers,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredJobSeekers.isEmpty
                          ? const Center(
                              child: Text(
                                'لا يوجد موظفين متاحين',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredJobSeekers.length,
                              itemBuilder: (context, index) {
                                final jobSeeker = _filteredJobSeekers[index];
                                return JobseekerCard(
                                  jobSeeker: jobSeeker,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JobSeekerProfilePage(
                                                jobSeeker: jobSeeker),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
