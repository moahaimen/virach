import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jobposting_model.dart';
import '../provider/jobposting_provider.dart';
import 'add_job_posting_screen.dart';
import 'edit_jobposting_screen.dart';
import 'job_applicants_screen.dart';

class MyJobPostingsPage extends StatefulWidget {
  final String
      userId; // The current user's ID that matches jobPosting.serviceProvider
  final String userType; // e.g. 'nurse', 'doctor', etc.

  const MyJobPostingsPage({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  State<MyJobPostingsPage> createState() => _MyJobPostingsPageState();
}

class _MyJobPostingsPageState extends State<MyJobPostingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  late JobPostingRetroDisplayGetProvider _jobPostingProvider;

  @override
  void initState() {
    super.initState();
    // Two tabs: current jobs, old jobs
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize provider if needed
    _jobPostingProvider = Provider.of<JobPostingRetroDisplayGetProvider>(
      context,
      listen: false,
    );

    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    // Fetch only the current user's job postings
    await _jobPostingProvider.fetchJobPostingsForUser(widget.userId);
    setState(() => _isLoading = false);
  }

  /// We consider a job "old" if it's either archived OR has job_status = "closed"
  bool _isOld(JobPostingModel job) {
    final archived = job.isArchived ?? false;
    final closed = (job.jobStatus?.toLowerCase() == 'closed');
    return archived || closed;
  }

  Future<void> _deleteJobPosting(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد بالتأكيد حذف هذه الوظيفة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) {
      await _jobPostingProvider.deleteJobPosting(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الوظيفة بنجاح')),
      );
    }
  }

  void _editJobPosting(JobPostingModel jobPosting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditJobPostingPage(
          jobPosting: jobPosting,
        ),
      ),
    ).then((_) {
      // Once we return from the edit page, re-fetch only *this* user's jobs
      _fetchData(); // calls _jobPostingProvider.fetchJobPostingsForUser(widget.userId)
    });
  }
  void _viewApplicants(JobPostingModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobApplicantsPage(
          jobId: job.id!,
          jobTitle: job.jobTitle ?? '',
        ),
      ),
    );
  }

  /// Toggle from open -> closed or closed -> open
  Future<void> _toggleJobStatus(JobPostingModel job) async {
    final isOpen = job.jobStatus?.toLowerCase() == 'open';
    final newStatus = isOpen ? 'closed' : 'open';

    final updatedJob = JobPostingModel(
      id: job.id,
      serviceProvider: job.serviceProvider,
      serviceProviderType: job.serviceProviderType,
      jobTitle: job.jobTitle,
      jobDescription: job.jobDescription,
      qualifications: job.qualifications,
      salary: job.salary,
      jobLocation: job.jobLocation,
      jobStatus: newStatus,
      isArchived: job.isArchived,
    );

    try {
      // Update that one job
      await _jobPostingProvider.updateJobPosting(updatedJob);

      // Re-fetch *only* this user's postings to keep the list restricted
      await _jobPostingProvider.fetchJobPostingsForUser(widget.userId);

      // Optionally call setState() if you want immediate rebuild
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تغيير حالة الوظيفة إلى $newStatus')),
      );
    } catch (e) {
      debugPrint("Error toggling job status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ عند تغيير الحالة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وظائفي المنشورة'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الوظائف الحالية'),
            Tab(text: 'الوظائف المنتهية'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<JobPostingRetroDisplayGetProvider>(
        builder: (context, jobProvider, child) {
          final allJobs = jobProvider.jobPostings;
          final currentJobs = allJobs.where((job) => !_isOld(job)).toList();
          final oldJobs = allJobs.where((job) => _isOld(job)).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildJobList(currentJobs, isOld: false),
              _buildJobList(oldJobs, isOld: true),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewJob,
        child: const Icon(Icons.add),
      ),
    );
  }


  Widget _buildJobList(List<JobPostingModel> jobs, {bool isOld = false}) {
    if (jobs.isEmpty) {
      return const Center(child: Text('لا توجد وظائف للعرض'));
    }

    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];

        return GestureDetector(
          onTap: () => _viewApplicants(job),
          child: Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Job Title
                  Text(
                    job.jobTitle ?? 'عنوان الوظيفة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// Description
                  Text(job.jobDescription ?? 'وصف الوظيفة'),
                  const SizedBox(height: 8),

                  /// Additional Info
                  if (job.qualifications != null &&
                      job.qualifications!.isNotEmpty)
                    Text('المؤهلات: ${job.qualifications}'),
                  if (job.salary != null && job.salary!.isNotEmpty)
                    Text('الراتب: ${job.salary}'),
                  if (job.jobLocation != null && job.jobLocation!.isNotEmpty)
                    Text('موقع العمل: ${job.jobLocation}'),

                  const SizedBox(height: 6),

                  /// عدد المتقدمين
                  Text('عدد المتقدمين: ${job.applicantsCount ?? 0}'),

                  const SizedBox(height: 8),

                  /// Status Row
                  _buildStatusRow(job, isOld),

                  const SizedBox(height: 8),

                  /// Edit / Delete buttons
                  Row(
                    children: [
                      if (!isOld) ...[
                        ElevatedButton.icon(
                          onPressed: () => _editJobPosting(job),
                          icon: const Icon(Icons.edit),
                          label: const Text('تعديل'),
                        ),
                        const SizedBox(width: 16),
                      ],
                      ElevatedButton.icon(
                        onPressed: () => _deleteJobPosting(job.id!),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white60,
                        ),
                        label: const Text(
                          'حذف',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  /// A row showing "حالة الوظيفة: <open/closed>" plus a small color-coded toggle
  Widget _buildStatusRow(JobPostingModel job, bool isOld) {
    final isOpen = job.jobStatus?.toLowerCase() == 'open';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Display text about status
        Text(
          'حالة الوظيفة: ${job.jobStatus ?? 'غير معروف'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // If the job is old, we can either show no toggle or show a red button that re-opens it.
        // Let's show a two-way toggle if you want that behavior:
        GestureDetector(
          onTap: () {
            // Toggle between open <-> closed
            _toggleJobStatus(job);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _createNewJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddJobPostingPage(
          userId: widget.userId,
          userType: widget.userType,
        ),
      ),
    );
  }
}