import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/hsp_custom_textfields_widget.dart';
import '../../widgets/hsp_image_picker_widget.dart';

class DoctorProfilePage extends StatefulWidget {
  // final String name;
  // final String specialty;
  // final String phoneNumber;
  // final String email;
  // final String address;
  // final String review;
  // final String experience;
  // final String qualifications;
  // final XFile? profileImage;
  //
  // DoctorProfilePage({
  //   required this.name,
  //   required this.specialty,
  //   required this.phoneNumber,
  //   required this.email,
  //   required this.address,
  //   required this.review,
  //   required this.experience,
  //   required this.qualifications,
  //   this.profileImage,
  // });

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController specialtyController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController reviewController;
  late TextEditingController experienceController;
  late TextEditingController qualificationsController;
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // _profileImage = widget.profileImage;
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    specialtyController = TextEditingController();
    phoneNumberController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();
    reviewController = TextEditingController();
    experienceController = TextEditingController();
    qualificationsController = TextEditingController();
  }

  // This is the method that you were missing
  void _onImagePicked(XFile? image) {
    setState(() {
      _profileImage = image;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ProfileImagePicker now works as expected
              HspProfileImagePicker(
                imageFile: _profileImage,
                onImagePicked: _onImagePicked,
              ),
              HspCustomTextField(
                  controller: nameController, label: 'الاسم الكامل'),
              HspCustomTextField(
                  controller: specialtyController, label: 'الاختصاص'),
              HspCustomTextField(
                  controller: phoneNumberController,
                  label: 'رقم الهاتف',
                  keyboardType: TextInputType.phone),
              HspCustomTextField(
                  controller: emailController,
                  label: 'البريد الالكتروني',
                  keyboardType: TextInputType.emailAddress),
              HspCustomTextField(
                  controller: addressController, label: 'العنوان'),
              HspCustomTextField(
                  controller: reviewController, label: 'التقييمات'),
              HspCustomTextField(
                  controller: experienceController, label: 'الخبرة'),
              HspCustomTextField(
                  controller: qualificationsController, label: 'المؤهلات'),
            ],
          ),
        ),
      ),
    );
  }
}
