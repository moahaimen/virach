import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constansts/constants.dart';
import '../../../token_provider.dart';
import '../../common_screens/signup_login/health_service_registration/city_district_selection_page.dart';
import '../../common_screens/signup_login/screens/welcome_page.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../models/jobposting_model.dart';
import '../provider/jobposting_provider.dart';
import '../widgets/jobpostin_card.dart';
import 'job_detail_screen.dart';

class AllJobPostingsPage extends StatefulWidget {
  final Map<String, String>? userData;
  final bool   standAlone;
  const AllJobPostingsPage({super.key, this.userData,  this.standAlone=false});

  @override
  State<AllJobPostingsPage> createState() => _AllJobPostingsPageState();
}

class _AllJobPostingsPageState extends State<AllJobPostingsPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();
  List<JobPostingModel> _allJobs = [];
  List<JobPostingModel> _filteredJobs = [];
  bool _isLoading = false;
  Map<String, String> _userData = {};

  // Filters
  String _selectedGender = 'any';
  String _selectedLocation = 'all';
  String _selectedSpecialty = 'all';
  String _sortCriterion = 'none';
  int _currentIndex = 0;
  String _selectedJobLocation = 'all';
  String _selectedJobTitle = 'all';
  String _selectedProviderType = 'all';
  double? _minSalary;
  double? _maxSalary;
  String _selectedCity = 'بغداد';
  String _selectedDistrict = 'all';
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchJobPostings();
    _searchController.addListener(_applyAllFilters);
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        "user_id": prefs.getString("user_id") ?? "",
        "full_name": prefs.getString("full_name") ?? "مستخدم مجهول",
        "email": prefs.getString("email") ?? "غير معروف",
        "phone_number": prefs.getString("phone_number") ?? "غير معروف",
        "degree": prefs.getString("degree") ?? "غير محدد",
        "specialty": prefs.getString("specialty") ?? "غير محدد",
        "address": prefs.getString("gps_location") ?? "غير متوفر",
        "gender": prefs.getString("gender") ?? "غير معروف",
      };
    });
  }

  Future<void> _fetchJobPostings() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<JobPostingRetroDisplayGetProvider>(context,
          listen: false);
      await provider.fetchAllJobPostings();

      setState(() {
        _allJobs = provider.jobPostings;
        _filteredJobs = List<JobPostingModel>.from(_allJobs);
      });

      _applyAllFilters();
    } catch (e) {
      debugPrint("Error fetching job postings: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    tokenProvider.updateToken("");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  void _onTapJob(JobPostingModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsPage(
          job: job,
          userData: _userData,
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _fetchJobPostings();
  }

// Reset filters function
  void _resetFilters() {
    setState(() {
      _selectedJobLocation = 'all';
      _selectedJobTitle = 'all';
      _selectedProviderType = 'all';
      _minSalary = null;
      _maxSalary = null;
      _selectedCity = 'بغداد';
      _selectedDistrict = 'all';
      _searchController.clear();
      _applyAllFilters();
    });
  }

  /// Sorting
  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "الفرز",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("بدون فرز"),
                    onTap: () {
                      setModalState(() => _sortCriterion = 'none');
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                  ),
                  ListTile(
                    title: const Text("الراتب: من الأقل إلى الأعلى"),
                    onTap: () {
                      setModalState(() => _sortCriterion = 'salary_asc');
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                  ),
                  ListTile(
                    title: const Text("الراتب: من الأعلى إلى الأقل"),
                    onTap: () {
                      setModalState(() => _sortCriterion = 'salary_desc');
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                  ),
                  ListTile(
                    title: const Text("التاريخ: الأحدث أولاً"),
                    onTap: () {
                      setModalState(() => _sortCriterion = 'date_desc');
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                  ),
                  ListTile(
                    title: const Text("التاريخ: الأقدم أولاً"),
                    onTap: () {
                      setModalState(() => _sortCriterion = 'date_asc');
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                  ),
                  ListTile(
                    title: const Text("الترتيب الأبجدي (أ-ي)"),
                    onTap: () {
                      setModalState(() => _sortCriterion = 'alphabetical_asc');
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                  ),
                  ListTile(
                    title: const Text("الترتيب الأبجدي (ي-أ)"),
                    onTap: () {
                      setModalState(() => _sortCriterion = 'alphabetical_desc');
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Example top row with filter/sort buttons
  Widget _buildFilterSortRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _openFilterSheet,
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
            const SizedBox(
              width: 5,
            ),
            Center(
              child: ElevatedButton(
                onPressed: _resetFilters,
                child: const Text('الغاء البحث'),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openSortSheet,
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
      ],
    );
  }

// Updated _applyAllFilters function
  void _applyAllFilters() {
    List<JobPostingModel> temp = List.from(_allJobs);
    final query = _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      temp = temp.where((job) {
        final title = job.jobTitle?.toLowerCase() ?? '';
        final desc = job.jobDescription?.toLowerCase() ?? '';
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

    if (_selectedDistrict != 'all') {
      temp = temp.where((job) {
        final loc = job.jobLocation?.toLowerCase() ?? '';
        return loc.contains(_selectedDistrict.toLowerCase());
      }).toList();
    }

    if (_selectedJobTitle != 'all') {
      temp = temp.where((job) {
        final title = job.jobTitle?.toLowerCase() ?? '';
        return title.contains(_selectedJobTitle.toLowerCase());
      }).toList();
    }

    if (_selectedProviderType != 'all') {
      temp = temp.where((job) {
        final providerType = job.serviceProviderType?.toLowerCase() ?? '';
        return providerType.contains(_selectedProviderType.toLowerCase());
      }).toList();
    }

    if (_minSalary != null) {
      temp = temp.where((job) {
        final salary = double.tryParse(job.salary ?? '') ?? 0.0;
        return salary >= _minSalary!;
      }).toList();
    }

    if (_maxSalary != null) {
      temp = temp.where((job) {
        final salary = double.tryParse(job.salary ?? '') ?? 0.0;
        return salary <= _maxSalary!;
      }).toList();
    }

    setState(() {
      _filteredJobs = temp;
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to resize when the keyboard appears
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.8, // Set max height to 80% of screen
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use min to fit content height
              children: [
                const Text(
                  "التصفية",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // CityDistrictSelection widget
                const Text(
                  'عنوان العمل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                CityDistrictSelection(
                  selectedCity: _selectedCity,
                  selectedDistrict: _selectedDistrict,
                  onCityChanged: (city) => setState(() => _selectedCity = city),
                  onDistrictChanged: (district) =>
                      setState(() => _selectedDistrict = district),
                ),
                // Job Title Dropdown
                const Text("المسمى الوظيفي"),
                DropdownButton<String>(
                  value: _selectedJobTitle,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('الكل')),
                    DropdownMenuItem(value: 'طبيب', child: Text('طبيب')),
                    DropdownMenuItem(value: 'ممرض', child: Text('ممرض')),
                  ],
                  onChanged: (val) => setState(() => _selectedJobTitle = val!),
                ),
                // Provider Type Dropdown
                const Text("نوع مقدم الخدمة"),
                DropdownButton<String>(
                  value: _selectedProviderType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('الكل')),
                    DropdownMenuItem(value: 'doctor', child: Text('طبيب')),
                    DropdownMenuItem(value: 'nurse', child: Text('ممرض')),
                    DropdownMenuItem(value: 'pharmacist', child: Text('صيدلي')),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedProviderType = val!),
                ),
                // Salary Inputs
                const Text("نطاق الراتب"),
                TextField(
                  controller: _minSalaryController,
                  decoration: const InputDecoration(labelText: 'الحد الأدنى'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _minSalary = double.tryParse(value),
                ),
                TextField(
                  controller: _maxSalaryController,
                  decoration: const InputDecoration(labelText: 'الحد الأقصى'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _maxSalary = double.tryParse(value),
                ),
                const SizedBox(height: 20),
                // Reset Filters Button

                const SizedBox(height: 10),
                // Apply Filters Button
                Center(
                  child: ElevatedButton(
                    style: kRedButtonStyle,
                    onPressed: () {
                      Navigator.pop(context);
                      _applyAllFilters();
                    },
                    child: const Text("تطبيق التصفية", style: kButtonTextStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationsRetroDisplayGetProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Prevents overflow when the keyboard appears


      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // ✅ Add this wrapper
              child: Column(
                children: [
                  // 🔍 Search bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _applyAllFilters(); // Apply filters whenever the user types
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث عن الوظيفة...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // 🔍 Filter & Sort Buttons

                  _buildFilterSortRow(),

                  // 🔍 Job Listings or Empty List
                  _filteredJobs.isEmpty
                      ? ListView(
                          shrinkWrap: true, // ✅ Prevent overflow inside scroll
                          physics:
                              NeverScrollableScrollPhysics(), // ✅ Disable ListView scroll
                          children: const [
                            SizedBox(height: 150),
                            Center(child: Text("لا توجد وظائف متاحة")),
                          ],
                        )
                      : ListView.builder(
                          shrinkWrap: true, // ✅ Prevent overflow
                          physics:
                              NeverScrollableScrollPhysics(), // ✅ Disable ListView scroll
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            return JobPostingCard(
                              job: job,
                              onTap: () => _onTapJob(job),
                            );
                          },
                        ),
                ],
              ),
            ),


    );
  }
}
