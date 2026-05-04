import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import '../../common_screens/signup_login/health_service_registration/city_district_selection_page.dart';
import '../models/jobposting_model.dart';
import '../provider/jobposting_provider.dart';
import '../widgets/jobpostin_card.dart';
import 'job_detail_screen.dart';

class AllJobPostingsPage extends StatefulWidget {
  final Map<String, String>? userData;
  const AllJobPostingsPage({super.key, this.userData});

  @override
  State<AllJobPostingsPage> createState() => _AllJobPostingsPageState();
}

class _AllJobPostingsPageState extends State<AllJobPostingsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<JobPostingModel> _allJobs = [];
  List<JobPostingModel> _filteredJobs = [];
  bool _isLoading = false;
  Map<String, String> _userData = {};

  String _selectedJobTitle = 'all';
  String _selectedProviderType = 'all';
  String _selectedCity = 'بغداد';
  String _selectedDistrict = 'all';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchJobPostings();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        "user_id": prefs.getString("user_id") ?? "",
        "full_name": prefs.getString("full_name") ?? "مستخدم مجهول",
      };
    });
  }

  Future<void> _fetchJobPostings() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<JobPostingRetroDisplayGetProvider>(context, listen: false);
      await provider.fetchAllJobPostings();
      setState(() {
        _allJobs = provider.jobPostings;
        _applyFilters();
      });
    } catch (e) {
      debugPrint("Error fetching job postings: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final matchesQuery = query.isEmpty ||
            (job.jobTitle?.toLowerCase().contains(query) ?? false) ||
            (job.jobDescription?.toLowerCase().contains(query) ?? false);
        
        final matchesDistrict = _selectedDistrict == 'all' || 
            (job.jobLocation?.toLowerCase().contains(_selectedDistrict.toLowerCase()) ?? false);
            
        final matchesTitle = _selectedJobTitle == 'all' || 
            (job.jobTitle?.toLowerCase().contains(_selectedJobTitle.toLowerCase()) ?? false);

        return matchesQuery && matchesDistrict && matchesTitle;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(
          title: const Text('وظائف القطاع الصحي'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchJobPostings,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search & Filter Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن وظيفة، تخصص، أو مدينة...',
                      prefixIcon: const Icon(Icons.search, color: RacheetaColors.primary),
                      fillColor: RacheetaColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _filterChip(
                          label: _selectedDistrict == 'all' ? 'كل المناطق' : _selectedDistrict,
                          onPressed: _showLocationFilter,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _filterChip(
                          label: _selectedJobTitle == 'all' ? 'كل التخصصات' : _selectedJobTitle,
                          onPressed: _showJobTitleFilter,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
                  : _filteredJobs.isEmpty
                      ? const RacheetaEmptyState(
                          icon: Icons.work_off_outlined,
                          title: "لا توجد وظائف حالياً",
                          subtitle: "جرب تغيير معايير البحث أو التصفية.",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            return JobPostingCard(
                              job: job,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobDetailsPage(job: job, userData: _userData),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RacheetaColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RacheetaColors.textPrimary)),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر المنطقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            CityDistrictSelection(
              selectedCity: _selectedCity,
              selectedDistrict: _selectedDistrict,
              onCityChanged: (v) => setState(() => _selectedCity = v),
              onDistrictChanged: (v) {
                setState(() => _selectedDistrict = v);
                _applyFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showJobTitleFilter() {
    final titles = ['all', 'طبيب', 'ممرض', 'صيدلي', 'مساعد مختبر', 'تجميل'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: titles.map((t) => ListTile(
          title: Text(t == 'all' ? 'الكل' : t),
          onTap: () {
            setState(() => _selectedJobTitle = t);
            _applyFilters();
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }
}
