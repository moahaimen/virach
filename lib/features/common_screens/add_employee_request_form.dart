import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../jobposting/models/jobposting_model.dart';
import '../jobposting/provider/jobposting_provider.dart';

class AddEmployeeRequestForm extends StatefulWidget {
  final String userType; // e.g. "doctor"
  final String? userId; // user PK for job postings
  final String? doctorId; // if you want it, or can omit

  AddEmployeeRequestForm({required this.userType, this.userId, this.doctorId});

  @override
  _AddEmployeeRequestFormState createState() => _AddEmployeeRequestFormState();
}

class _AddEmployeeRequestFormState extends State<AddEmployeeRequestForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Fields
  String? selectedJobTitle;
  String? selectedDistrict;
  String? selectedJobStatus = 'open';

  // Sample titles
  final List<String> jobTitles = [
    'سكرتير',
    'ممرض',
    'طبيب',
    'معالج طبيعي',
    'صيدلي',
    'محلل مختبر',
    'أخرى'
  ];

  // Districts
  final List<String> districts = [
    'الرصافة',
    'الكرخ',
    'الاعظمية',
    'الكرادة',
    'الشعب',
    'مدينة الصدر',
    'البياع',
    'الدورة',
    'الغزالية',
    'حي العدل',
    'الحرية',
    'زيونة',
    'اليرموك',
    'المنصور',
    'حي العامل',
    'الصليخ',
    'الحارثية',
    'القادسية',
    'حي الجامعة',
    'شارع فلسطين',
    'المشتل',
    'حي الرسالة',
    'حي الجهاد',
    'حي المعلمين',
    'حي الاسكان'
  ];

  final List<String> jobStatus = ['open', 'closed'];

  final TextEditingController jobDescriptionController =
      TextEditingController();
  final TextEditingController qualificationsController =
      TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة إعلان وظيفة (${widget.userType})'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'يرجى إدخال تفاصيل الوظيفة:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Job Title
                      _buildDropdownField(
                        'عنوان الوظيفة',
                        jobTitles,
                        selectedJobTitle,
                        (value) {
                          setState(() => selectedJobTitle = value);
                        },
                      ),
                      const SizedBox(height: 20),

                      // District
                      _buildDropdownField(
                        'المنطقة',
                        districts,
                        selectedDistrict,
                        (value) {
                          setState(() => selectedDistrict = value);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Job status (optional)
                      _buildDropdownField(
                        'حالة الوظيفة',
                        jobStatus,
                        selectedJobStatus,
                        (value) {
                          setState(() => selectedJobStatus = value);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _buildTextField('وصف الوظيفة', jobDescriptionController,
                          maxLines: 3),
                      const SizedBox(height: 20),

                      // Qualifications
                      _buildTextField(
                          'المؤهلات المطلوبة', qualificationsController),
                      const SizedBox(height: 20),

                      // Salary
                      _buildTextField('الراتب', salaryController),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'إرسال الطلب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار $label';
        }
        return null;
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Make sure widget.userId is a valid ID in the backend
      final jobPosting = JobPostingModel(
        serviceProvider: widget.userId, // The ID that actually exists
        serviceProviderType: widget.userType, // e.g. "doctor"
        jobTitle: selectedJobTitle,
        jobLocation: selectedDistrict,
        jobDescription: jobDescriptionController.text,
        qualifications: qualificationsController.text,
        jobStatus: selectedJobStatus,
        // Salary is optional. If your backend supports it:
        salary: salaryController.text.isNotEmpty ? salaryController.text : null,
      );

      print("Submitting Payload: ${jobPosting.toJson()}");

      final provider = context.read<JobPostingRetroDisplayGetProvider>();
      provider.createJobPosting(jobPosting).then((response) {
        setState(() => _isLoading = false);
        if (response != null) {
          print("Job created successfully: ${response.toJson()}");
          _clearFields();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم إرسال الطلب بنجاح!'),
          ));
          Navigator.pop(context); // Go back or anywhere else
        } else {
          print("Failed to create job.");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('فشل إنشاء الطلب'),
          ));
        }
      }).catchError((error) {
        setState(() => _isLoading = false);
        print("Error submitting job posting: $error");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('حدث خطأ أثناء إرسال الطلب'),
        ));
      });
    } catch (e) {
      print("Error building job posting: $e");
      setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    jobDescriptionController.clear();
    qualificationsController.clear();
    salaryController.clear();
    setState(() {
      selectedJobTitle = null;
      selectedDistrict = null;
      selectedJobStatus = 'open';
    });
  }
}
