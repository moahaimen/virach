import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jobposting_model.dart';
import '../provider/jobposting_provider.dart';

class AddJobPostingPage extends StatefulWidget {
  final String userId;
  final String userType;

  const AddJobPostingPage({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  State<AddJobPostingPage> createState() => _AddJobPostingPageState();
}

class _AddJobPostingPageState extends State<AddJobPostingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _qualCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    final jobProvider =
        Provider.of<JobPostingRetroDisplayGetProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء وظيفة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Job Title
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'عنوان الوظيفة'),
                validator: (val) => val == null || val.isEmpty
                    ? 'الرجاء إدخال عنوان الوظيفة'
                    : null,
              ),
              const SizedBox(height: 12),

              // Job Description
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'وصف الوظيفة'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Qualifications
              TextFormField(
                controller: _qualCtrl,
                decoration: const InputDecoration(labelText: 'المؤهلات'),
              ),
              const SizedBox(height: 12),

              // Salary
              TextFormField(
                controller: _salaryCtrl,
                decoration: const InputDecoration(labelText: 'الراتب'),
              ),
              const SizedBox(height: 12),

              // Job Location
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'موقع العمل'),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isPosting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await _createJob(jobProvider);
                        }
                      },
                child: _isPosting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إنشاء الوظيفة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createJob(JobPostingRetroDisplayGetProvider jobProvider) async {
    setState(() => _isPosting = true);

    final newJob = JobPostingModel(
      serviceProvider: widget.userId, // The nurse/doctor/hospital ID
      serviceProviderType: widget.userType,
      jobTitle: _titleCtrl.text,
      jobDescription: _descCtrl.text,
      qualifications: _qualCtrl.text,
      salary: _salaryCtrl.text,
      jobLocation: _locationCtrl.text,
      jobStatus: 'open', // or 'active' or however you handle new jobs
      isArchived: false,
    );

    final created = await jobProvider.createJobPosting(newJob);

    setState(() => _isPosting = false);

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الوظيفة بنجاح!')),
      );
      Navigator.pop(context); // Return to the previous page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إنشاء الوظيفة')),
      );
    }
  }
}
