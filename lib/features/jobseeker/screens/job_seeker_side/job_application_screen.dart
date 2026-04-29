import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../constansts/constants.dart';

class JobApplicationScreen extends StatefulWidget {
  final int jobId; // The ID of the job being applied for
  final String jobTitle; // Title of the job

  JobApplicationScreen({required this.jobId, required this.jobTitle});

  @override
  _JobApplicationScreenState createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();

  String? _cvFileName; // To store the name of the uploaded CV file
  File? _cvFile; // To store the CV file

  // Function to pick a file (PDF or DOC)
  Future<void> _pickCVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'], // Allowed file types
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvFileName = result.files.single.name;
        _cvFile = File(result.files.single.path!);
      });
    }
  }

  // Function to submit the job application with the job seeker's profile and optional CV
  Future<void> _submitApplication() async {
    // Prepare job seeker data
    Map<String, dynamic> applicationData = {
      'job_id': widget.jobId,
      'job_seeker_name': _nameController.text,
      'job_seeker_phone': _phoneController.text,
      'cover_letter': _coverLetterController.text,
      // Add other profile info if needed
    };

    // If a CV is uploaded, include it
    if (_cvFile != null) {
      applicationData['cv_file'] =
          _cvFile!.path; // For example, you could upload the file path
    }

    // Simulate API call to submit the job application
    var response = await http.post(
      Uri.parse('https://your-api-url.com/applications/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(applicationData),
    );

    if (response.statusCode == 201) {
      // Application submitted successfully
      print('Application submitted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلبك بنجاح!')),
      );
    } else {
      // Error submitting application
      print('Failed to submit application');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إرسال الطلب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apply for ${widget.jobTitle}',
          style: kAppBarTextStyle,
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Fill in your details to apply for the job. You can optionally upload your CV in PDF or DOC format and write a cover letter.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Name Input
              TextField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),

              // Phone Input
              TextField(
                controller: _phoneController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'رقم التليفون',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Cover Letter Input
              TextField(
                controller: _coverLetterController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'خطاب التغطية',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),

              // CV File Upload Button (Optional)
              ElevatedButton.icon(
                onPressed: _pickCVFile, // Trigger file picker for CV
                icon: const Icon(Icons.upload),
                label: const Text('ارفع السيرة الذاتية (PDF أو DOC)'),
                style:
                    kRedElevatedButtonStyle, // Using defined style from constants
              ),

              // Display file name if the user uploads a CV
              if (_cvFileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'تم رفع الملف: $_cvFileName',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitApplication, // Call submission logic
                style:
                    kRedElevatedButtonStyle, // Using defined style from constants
                child: const Text(
                  'تأكيد',
                  style:
                      kButtonTextStyle, // Using defined text style from constants
                ),
              ),
              const SizedBox(height: 20),

              // Note Section
              const Text(
                'ملاحظة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.right,
              ),
              const Text(
                'تطبيقنا يعمل كوسيط بين المريض ومقدم الخدمات الطبية. نحن لا نتحمل المسؤولية عن اللقاء المباشر بين الأطراف.',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Footer
              const Center(
                child: Text(
                  'جميع الحقوق محفوظة ٢٠٢٤',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
