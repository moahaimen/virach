// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:racheeta/features/doctors/models/doctors_model.dart';
// import 'package:racheeta/features/doctors/providers/doctors_provider.dart';
//
// class DoctorProfilePage extends StatefulWidget {
//   final String doctorId;
//   final String userId;
//   final String name;
//   final String specialty;
//   final String phoneNumber;
//   final String email;
//   final String address;
//   final String review;
//   final String experience;
//   final String qualifications;
//   final String? imageUrl; // Ensure this is nullable
//   const DoctorProfilePage({
//     Key? key,
//     required this.doctorId,
//     required this.userId,
//     required this.name,
//     required this.specialty,
//     required this.phoneNumber,
//     required this.email,
//     required this.address,
//     required this.review,
//     required this.experience,
//     required this.qualifications,
//     this.imageUrl,
//   }) : super(key: key);
//
//   @override
//   State<DoctorProfilePage> createState() => _DoctorProfilePageState();
// }
//
// class _DoctorProfilePageState extends State<DoctorProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _experienceController = TextEditingController();
//   final _qualificationsController = TextEditingController();
//   bool _isEditing = false;
//   bool _isLoading = false;
//   String _gender = 'm';
//
//   XFile? _pickedXFile; // from ImagePicker
//   DoctorModel? _doctor; // store the fetched doctor
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAndLoad();
//   }
//
//   Future<void> _fetchAndLoad() async {
//     setState(() => _isLoading = true);
//     try {
//       final provider = context.read<DoctorRetroDisplayGetProvider>();
//       final doc = await provider.fetchDoctorById(widget.doctorId);
//       if (doc != null) {
//         _doctor = doc;
//         _populateFields(doc);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to load doctor data')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _populateFields(DoctorModel doc) {
//     _nameController.text = doc.user?.fullName ?? '';
//     _phoneController.text = doc.user?.phoneNumber ?? '';
//     _emailController.text = doc.user?.email ?? '';
//     _addressController.text = doc.address ?? '';
//     _experienceController.text = doc.degrees ?? '';
//     _qualificationsController.text = doc.bio ?? '';
//     _gender = doc.user?.gender ?? 'm';
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     final xfile = await ImagePicker().pickImage(source: source);
//     if (xfile != null) {
//       setState(() => _pickedXFile = xfile);
//     }
//   }
//
//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);
//
//     final provider = context.read<DoctorRetroDisplayGetProvider>();
//
//     // Build the data map
//     final data = {
//       "full_name": _nameController.text.trim(),
//       "phone_number": _phoneController.text.trim(),
//       "email": _emailController.text.trim(),
//       "address": _addressController.text.trim(),
//       "degrees": _experienceController.text.trim(),
//       "bio": _qualificationsController.text.trim(),
//       "gender": _gender,
//       // etc. If your server also allows `specialty`, add it here
//     };
//
//     final updated = await provider.updateDoctorProfile(
//       doctorId: widget.doctorId,
//       data: data,
//       image: _pickedXFile != null ? File(_pickedXFile!.path) : null,
//     );
//
//     if (updated) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );
//       setState(() {
//         _isEditing = false;
//       });
//       // Reload fresh data from server
//       await _fetchAndLoad();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update profile')),
//       );
//     }
//
//     setState(() => _isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEditing = _isEditing;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الملف الشخصي'),
//         actions: [
//           IconButton(
//             icon: Icon(isEditing ? Icons.save : Icons.edit),
//             onPressed: () {
//               if (isEditing) {
//                 _saveProfile();
//               } else {
//                 setState(() => _isEditing = true);
//               }
//             },
//           )
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Form(
//                 key: _formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       _buildProfileImageSection(),
//                       const SizedBox(height: 24),
//                       _buildEditableField("الاسم", _nameController, isEditing),
//                       _buildEditableField(
//                           "رقم الهاتف", _phoneController, isEditing),
//                       _buildEditableField(
//                           "الإيميل", _emailController, isEditing),
//                       _buildEditableField(
//                           "العنوان", _addressController, isEditing),
//                       _buildEditableField(
//                           "الشهادة", _experienceController, isEditing),
//                       _buildEditableField(
//                           "Bio", _qualificationsController, isEditing),
//                       _buildGenderDropdown(isEditing),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
//
//   Widget _buildProfileImageSection() {
//     // If user picked a new one
//     if (_pickedXFile != null) {
//       return CircleAvatar(
//         radius: 80,
//         backgroundImage: FileImage(File(_pickedXFile!.path)),
//       );
//     }
//
//     // If we already fetched the doctor and have a profileImage
//     final imageUrl = _doctor?.user?.profileImage; // e.g. "/media/avatars/..."
//     final fullUrl =
//         imageUrl != null ? 'https://racheeta.pythonanywhere.com$imageUrl' : null;
//
//     return Stack(
//       alignment: Alignment.bottomCenter,
//       children: [
//         CircleAvatar(
//           radius: 80,
//           backgroundImage: (fullUrl != null)
//               ? NetworkImage(fullUrl)
//               : const AssetImage('assets/icons/doctor_icon.png')
//                   as ImageProvider,
//         ),
//         if (_isEditing)
//           Positioned(
//             bottom: 0,
//             child: Row(
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("كاميرا"),
//                   onPressed: () => _pickImage(ImageSource.camera),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.photo_library),
//                   label: const Text("المعرض"),
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildEditableField(
//       String label, TextEditingController controller, bool enabled) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         enabled: enabled,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//         validator: (value) =>
//             (value == null || value.isEmpty) ? 'يجب تعبئة الحقل' : null,
//       ),
//     );
//   }
//
//   Widget _buildGenderDropdown(bool enabled) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: DropdownButtonFormField<String>(
//         value: _gender,
//         items: const [
//           DropdownMenuItem(value: 'm', child: Text("ذكر")),
//           DropdownMenuItem(value: 'f', child: Text("انثى")),
//         ],
//         onChanged:
//             enabled ? (value) => setState(() => _gender = value ?? 'm') : null,
//         decoration: const InputDecoration(
//           labelText: 'الجنس',
//           border: OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/features/doctors/models/doctors_model.dart';
import 'package:racheeta/features/doctors/providers/doctors_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;
  final String userId;

  const DoctorProfilePage({
    Key? key,
    required this.doctorId,
    required this.userId,
  }) : super(key: key);

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationsController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  String _gender = 'm';

  XFile? _pickedXFile; // from ImagePicker
  DoctorModel? _doctor; // store the fetched doctor
  String? _profileImageUrl; // Store the profile image URL
  late String doctorId = '';

  @override
  void initState() {
    super.initState();
    _fetchAndLoad();
  }

  Future<void> _fetchAndLoad() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<DoctorRetroDisplayGetProvider>();
      final doc = await provider.fetchDoctorById(widget.doctorId);
      if (doc != null) {
        _doctor = doc;
        _populateFields(doc);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل بيانات الطبيب')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(DoctorModel doc) {
    _nameController.text = doc.user?.fullName ?? '';
    _phoneController.text = doc.user?.phoneNumber ?? '';
    _emailController.text = doc.user?.email ?? '';
    _addressController.text = doc.address ?? '';
    _experienceController.text = doc.degrees ?? '';
    _qualificationsController.text = doc.bio ?? '';
    _gender = doc.user?.gender ?? 'm';
    _profileImageUrl = doc.user?.profileImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await ImagePicker().pickImage(source: source);
    if (xfile != null) {
      setState(() => _pickedXFile = xfile);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getString("doctor_id") ?? '';

    if (doctorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Doctor ID not found')),
      );
      setState(() => _isLoading = false);
      return;
    }
    final accessToken = prefs.getString("Login_access_token");
    print("The accessToken  from UpdateProfile=====>  $accessToken");
    final provider = context.read<DoctorRetroDisplayGetProvider>();

    // In DoctorProfilePage's _saveProfile method:
    final data = {
      "full_name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "gender": _gender,
      // Include other required fields (e.g., email)
      //"email": _doctor?.user?.email ?? "",

      "bio": _qualificationsController.text.trim(),
      "degrees": _experienceController.text.trim(),
      "address": _addressController.text.trim(),
    };

    // final updated = await provider.updateDoctorProfile(
    //   doctorId: doctorId,
    //   data: data,
    //   image: _pickedXFile != null ? File(_pickedXFile!.path) : null,
    // );

    // if (updated) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Profile updated successfully')),
    //   );
    //
    //   // ✅ Force fetch the latest data from the server
    //   final refreshedProfile = await provider.fetchDoctorById(doctorId);
    //   print(
    //       ">>> [DoctorProfilePage] Updated Profile Data: ${refreshedProfile?.toJson()}");
    //
    //   if (refreshedProfile != null) {
    //     _populateFields(refreshedProfile);
    //   }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Failed to update profile')),
    //   );
    // }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _isEditing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileImageSection(),
                      const SizedBox(height: 24),
                      _buildEditableField("الاسم", _nameController, isEditing),
                      _buildEditableField(
                          "رقم الهاتف", _phoneController, isEditing),
                      _buildEditableField(
                          "الإيميل", _emailController, _isEditing,
                          isReadOnly: true),
                      _buildEditableField(
                          "العنوان", _addressController, isEditing),
                      _buildEditableField(
                          "الشهادة", _experienceController, isEditing),
                      _buildEditableField(
                          "Bio", _qualificationsController, isEditing),
                      _buildGenderDropdown(isEditing),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImageSection() {
    final imageUrl = _profileImageUrl;
    final fullUrl =
        imageUrl != null ? 'https://racheeta.pythonanywhere.com$imageUrl' : null;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundImage: _pickedXFile != null
              ? FileImage(File(_pickedXFile!.path))
              : (fullUrl != null
                      ? NetworkImage(fullUrl)
                      : const AssetImage('assets/icons/doctor_icon.png'))
                  as ImageProvider,
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("كاميرا"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text("المعرض"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, bool enabled,
      {bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled && !isReadOnly, // Disable input for read-only fields
        readOnly: isReadOnly,
        style: isReadOnly
            ? const TextStyle(color: Colors.grey) // Grey out read-only fields
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: isReadOnly,
          fillColor: Colors.grey[200], // Light grey background for read-only
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'يجب تعبئة الحقل' : null,
      ),
    );
  }

  Widget _buildGenderDropdown(bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _gender,
        items: const [
          DropdownMenuItem(value: 'm', child: Text("ذكر")),
          DropdownMenuItem(value: 'f', child: Text("أنثى")),
        ],
        onChanged:
            enabled ? (value) => setState(() => _gender = value ?? 'm') : null,
        decoration: const InputDecoration(
          labelText: 'الجنس',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
