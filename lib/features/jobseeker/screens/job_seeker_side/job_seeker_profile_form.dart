import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../constansts/constants.dart';
import '../../generiled_widget/general_dropwdown_widget.dart';
import '../../generiled_widget/general_image_picker_widget.dart';
import '../../generiled_widget/generilized_custom_input_fields.dart';

class JobSeekerForm extends StatefulWidget {
  @override
  _JobSeekerFormState createState() => _JobSeekerFormState();
}

class _JobSeekerFormState extends State<JobSeekerForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedSpecialty;
  String? selectedDegree;

  // Image variables
  File? _profileImage;
  File? _degreeImage;

  // Dropdown items
  final List<String> specialties = [
    'ممرض',
    'معالج طبيعي',
    'طبيب',
    'مهندس',
    'مبرمج حاسبات',
    'اخرى',
    'Other'
  ];
  final List<String> degrees = [
    'اخرى',
    'اعدادية',
    'دبلوم',
    'بكلرويوس',
    'ماستر ',
    'دكتوراة'
  ];

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      // Simulate profile submission
      print("Profile Submitted!");

      // // After successful submission, navigate to the job postings list
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => JobSeekerProfilePage()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التسجيل الخاص بالبحث عن وظيفة',
          style: kAppBarDashboardTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'أدخل معلوماتك وسوف نتواصل معك قريبا اوستأتيك اشعارات عند توفير وظيفة ضمن تخصصك:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Profile Image Circle Avatar
                CustomImagePicker(
                  isProfile: true, // or false for other images
                  label: 'Upload Profile Picture',
                  onImageSelected: (File image) {
                    // Handle the selected image in the parent widget
                    print("Image selected: ${image.path}");
                  },
                ),

                const SizedBox(height: 20),

                // Full Name

                GeneralCustomTextFields(
                  labelText: 'الاسم الثلاثي',
                  controller: fullNameController,
                  hintText: 'الاسم',
                  validatorText: 'يرجى ادخال الاسم الكامل',
                  isPhone: true,
                  suffixIcon: Icon(Icons.location_on, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Phone Number
                GeneralCustomTextFields(
                  labelText: 'رقم الهاتف',
                  controller: phoneNumberController,
                  hintText: 'رقم الهاتف',
                  validatorText: 'يرجى ادخال رقم الهاتف',
                  isPhone: true,
                  suffixIcon: Icon(Icons.location_on, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Email
                GeneralCustomTextFields(
                  labelText: 'الايميل',
                  controller: emailController,
                  hintText: 'الايميل',
                  validatorText: 'يرجى ادخال الايميل',
                  isPhone: true,
                  suffixIcon: Icon(Icons.location_on, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Specialty Dropdown
                BuildDropdownField(
                  label: 'التخصص',
                  value: selectedSpecialty,
                  items: specialties,
                  onChanged: (value) => setState(() {
                    selectedSpecialty = value;
                  }),
                  validatorMessage: 'يرجى اختيار التخصص',
                ),
                const SizedBox(height: 20),

                // Degree Dropdown
                BuildDropdownField(
                  label: 'الشهادة',
                  value: selectedDegree,
                  items: degrees,
                  onChanged: (value) => setState(() {
                    selectedDegree = value;
                  }),
                  validatorMessage: 'يرجى اختيار الشهادة',
                ),
                const SizedBox(height: 20),

                // Address
                GeneralCustomTextFields(
                  labelText: 'العنوان',
                  controller: addressController,
                  hintText: 'العنوان',
                  validatorText: 'يرجى ادخال العنوان',
                  suffixIcon: Icon(Icons.location_on, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Degree Image Uploader
                CustomImagePicker(
                  isProfile: true, // or false for other images
                  label: 'Upload Profile Picture',
                  onImageSelected: (File image) {
                    // Handle the selected image in the parent widget
                    print("Image selected: ${image.path}");
                  },
                ),

                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitProfile,
                  style: kRedElevatedButtonStyle,
                  child: const Text(
                    'ارسل المعلومات',
                    style: kButtonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
