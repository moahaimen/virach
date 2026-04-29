import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jobposting_model.dart';
import '../provider/jobposting_provider.dart';

class EditJobPostingPage extends StatefulWidget {
  final JobPostingModel jobPosting;

  const EditJobPostingPage({Key? key, required this.jobPosting})
      : super(key: key);

  @override
  State<EditJobPostingPage> createState() => _EditJobPostingPageState();
}

class _EditJobPostingPageState extends State<EditJobPostingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController qualController;
  late TextEditingController salaryController;

  String? selectedJobTitle;
  String? selectedDistrict;
  String? selectedJobStatus;

  final List<String> jobTitles = [
    'سكرتير',
    'ممرض',
    'طبيب',
    'معالج طبيعي',
    'صيدلي',
    'محلل مختبر',
    'أخرى'
  ];

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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.jobPosting.jobTitle);
    descController =
        TextEditingController(text: widget.jobPosting.jobDescription);
    qualController =
        TextEditingController(text: widget.jobPosting.qualifications);
    salaryController =
        TextEditingController(text: widget.jobPosting.salary ?? '');

    selectedJobTitle = widget.jobPosting.jobTitle;
    selectedDistrict = widget.jobPosting.jobLocation;
    selectedJobStatus = widget.jobPosting.jobStatus ?? 'open';
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    qualController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedJob = JobPostingModel(
      id: widget.jobPosting.id,
      serviceProvider: widget.jobPosting.serviceProvider,
      serviceProviderType: widget.jobPosting.serviceProviderType,
      jobTitle: selectedJobTitle,
      jobLocation: selectedDistrict,
      jobDescription: descController.text,
      qualifications: qualController.text,
      jobStatus: selectedJobStatus,
      salary: salaryController.text.isNotEmpty ? salaryController.text : null,
      isArchived: widget.jobPosting.isArchived,
    );

    try {
      final provider = context.read<JobPostingRetroDisplayGetProvider>();
      await provider.updateJobPosting(updatedJob);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تعديل الوظيفة بنجاح!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ حدث خطأ عند تحديث الوظيفة')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        hint: Text(label),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى اختيار $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ تعديل الوظيفة'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'يرجى تعديل تفاصيل الوظيفة:',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              _buildDropdownField('عنوان الوظيفة', jobTitles,
                  selectedJobTitle, (val) {
                    setState(() => selectedJobTitle = val);
                  }),

              _buildDropdownField(
                  'المنطقة', districts, selectedDistrict, (val) {
                setState(() => selectedDistrict = val);
              }),

              _buildDropdownField(
                  'حالة الوظيفة', jobStatus, selectedJobStatus, (val) {
                setState(() => selectedJobStatus = val);
              }),

              _buildTextField('وصف الوظيفة', descController, maxLines: 3),
              _buildTextField('المؤهلات المطلوبة', qualController),
              _buildTextField('الراتب', salaryController,
                  keyboardType: TextInputType.number),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    '💾 حفظ التعديلات',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
