import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../constansts/constants.dart';

class MedicalRegistrationApp extends StatefulWidget {
  @override
  _MedicalRegistrationAppState createState() => _MedicalRegistrationAppState();
}

class _MedicalRegistrationAppState extends State<MedicalRegistrationApp>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> clinics = [];
  final ImagePicker _picker = ImagePicker();
  String? _selectedWorkOption = 'Yes'; // Default value

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'أختر نوع التسجيل',
          style: kAppBarDoctorsTextStyle,
        ),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: kTablabelStyleTextStyle,
          unselectedLabelStyle: kTablabelStyleTextStyle,
          labelColor: Colors.white, // Color of the text when selected
          unselectedLabelColor:
              Colors.white60, // Color of the text when not selected
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'عيادة طبيب'),
            Tab(text: 'مركز طبي'),
            Tab(text: 'مستشفى'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildClinicForm(),
          buildMedicalCenterForm(),
          buildHospitalForm(),
        ],
      ),
    );
  }

  Widget buildClinicForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: GlobalKey<FormState>(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTextField(
              initialValue: '',
              label: 'الاسم الكامل',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                return null;
              },
              onSaved: (value) {
                // Save name
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'العنوان',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال العنوان';
                }
                return null;
              },
              onSaved: (value) {
                // Save address
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'الموقع على الخريطة',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الموقع';
                }
                return null;
              },
              onSaved: (value) {
                // Save location
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'رقم الهاتف',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
              onSaved: (value) {
                // Save phone number
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'تخصص',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال التخصص';
                }
                return null;
              },
              onSaved: (value) {
                // Save specialty
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'الخبرة',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الخبرة';
                }
                return null;
              },
              onSaved: (value) {
                // Save experience
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'الشهادات',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الشهادات';
                }
                return null;
              },
              onSaved: (value) {
                // Save certifications
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'Bio البايو',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البايو';
                }
                return null;
              },
              onSaved: (value) {
                // Save bio
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'وقت دوام العيادة',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال وقت الدوام';
                }
                return null;
              },
              onSaved: (value) {
                // Save working hours
              },
            ),
            SizedBox(height: 20),
            const Text(
              'هل ترغب بالبحث عن عمل في مركز طبي او مستشفى؟',
              style: kDoctorDescrpitionTextStyle,
            ),
            ListTile(
              title: Text('نعم'),
              leading: Radio<String>(
                value: 'Yes',
                groupValue: _selectedWorkOption,
                onChanged: (String? value) {
                  setState(() {
                    _selectedWorkOption = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('لا'),
              leading: Radio<String>(
                value: 'No',
                groupValue: _selectedWorkOption,
                onChanged: (String? value) {
                  setState(() {
                    _selectedWorkOption = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: kRedElevatedButtonStyle,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddClinicsPage()));
                },
                child: const Text(
                  'اضافة المعلومات ',
                  style: kButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?)? validator,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        textAlign: TextAlign.right,
        initialValue: initialValue,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget buildMedicalCenterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: GlobalKey<FormState>(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTextField(
              initialValue: '',
              label: 'أسم المركز',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال أسم المركز';
                }
                return null;
              },
              onSaved: (value) {
                // Save center name
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'موقع المركز',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال موقع المركز';
                }
                return null;
              },
              onSaved: (value) {
                // Save center location
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'مدير المركز',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال أسم مدير المركز';
                }
                return null;
              },
              onSaved: (value) {
                // Save manager name
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'رقم الهاتف',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
              onSaved: (value) {
                // Save phone number
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: kRedElevatedButtonStyle,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddClinicsPage()));
                },
                child: const Text(
                  'اضافة عيادة للمركز ',
                  style: kButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHospitalForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: GlobalKey<
            FormState>(), // Separate form key for independent form management
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTextField(
              initialValue: '',
              label: 'أسم المستشفى',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال أسم المستشفى';
                }
                return null;
              },
              onSaved: (value) {
                // Save hospital name
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'العنوان',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال العنوان';
                }
                return null;
              },
              onSaved: (value) {
                // Save address
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'موقع المستشفى على الخريطة',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال موقع المستشفى على الخريطة';
                }
                return null;
              },
              onSaved: (value) {
                // Save location
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'الادارة',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال تفاصيل الادارة';
                }
                return null;
              },
              onSaved: (value) {
                // Save management details
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'رقم الهاتف',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
              onSaved: (value) {
                // Save phone number
              },
            ),
            _buildTextField(
              initialValue: '',
              label: 'تخصص المستشفى',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال تخصص المستشفى';
                }
                return null;
              },
              onSaved: (value) {
                // Save hospital specialty
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: kRedElevatedButtonStyle,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddDoctorsPage()));
                },
                child: const Text(
                  'اضف الطبيب',
                  style: kButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildClinicEntry(Map<String, dynamic> clinic) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'أسم العيادة'),
          onChanged: (value) => clinic['clinicName'] = value,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'أسم الطبيب'),
          onChanged: (value) => clinic['doctorName'] = value,
        ),
        // Additional fields for doctor's photo, specialty, etc.
      ],
    );
  }

  Future<void> pickImage(void Function(File?) onImagePicked) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }
}

class Doctor {
  String name;
  String specialty;
  File? photo;
  String availability;

  Doctor(
      {required this.name,
      required this.specialty,
      this.photo,
      required this.availability});
}

class MedicalCenterForm extends StatefulWidget {
  @override
  _MedicalCenterFormState createState() => _MedicalCenterFormState();
}

class _MedicalCenterFormState extends State<MedicalCenterForm> {
  List<Doctor> doctors = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> pickDoctorImage(Doctor doctor) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        doctor.photo = File(pickedFile.path);
      });
    }
  }

  Widget buildDoctorCard(Doctor doctor) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (doctor.photo != null)
            Image.file(doctor.photo!, height: 100, width: 100),
          TextButton(
            onPressed: () => pickDoctorImage(doctor),
            child: Text(
                doctor.photo == null ? 'قم بتحميل الصورة' : 'قم بتغيير الصورة'),
          ),
          TextFormField(
            initialValue: doctor.name,
            decoration: InputDecoration(labelText: 'أسم الطبيب'),
            onChanged: (value) => doctor.name = value,
          ),
          TextFormField(
            initialValue: doctor.specialty,
            decoration: InputDecoration(labelText: 'التخصص'),
            onChanged: (value) => doctor.specialty = value,
          ),
          TextFormField(
            initialValue: doctor.availability,
            decoration: InputDecoration(labelText: 'وقت دوام العيادة'),
            onChanged: (value) => doctor.availability = value,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => setState(() => doctors.remove(doctor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Medical Center")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...doctors.map(buildDoctorCard).toList(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  doctors
                      .add(Doctor(name: '', specialty: '', availability: ''));
                });
              },
              child: Text('Add Doctor'),
            ),
            ElevatedButton(
              onPressed: () {
                // Submit form logic
                print(
                    'Submitting Medical Center with ${doctors.length} doctors.');
              },
              child: Text('Submit Medical Center'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddClinicsPage extends StatefulWidget {
  @override
  _AddClinicsPageState createState() => _AddClinicsPageState();
}

class _AddClinicsPageState extends State<AddClinicsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _doctorImage;
  String _clinicName = '';
  String _doctorName = '';
  String _availability = '';
  String _price = '';

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _doctorImage = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black26,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "قم باضافة تفاصيل العيادة",
          style: kAppBarDoctorsTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'اسم العيادة'),
              onChanged: (value) => _clinicName = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'أسم الطبيب'),
              onChanged: (value) => _doctorName = value,
            ),
            if (_doctorImage != null)
              Image.file(_doctorImage!, height: 100, width: 100),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: kRedElevatedButtonStyle,
                onPressed: pickImage,
                child: Text(
                  _doctorImage == null
                      ? 'قم برفع صورة للطبيب'
                      : 'قم بتغيير الصورة',
                  style: kButtonTextStyle,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'ساعات الدوام '),
              onChanged: (value) => _availability = value,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'سعر العيادة'),
              onChanged: (value) => _price = value,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: kRedElevatedButtonStyle,
                onPressed: () {
                  // Logic to save clinic details
                  Navigator.pop(context);
                },
                child: Text(
                  'قم بحفظ المعلومات',
                  style: kButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddDoctorsPage extends StatefulWidget {
  @override
  _AddDoctorsPageState createState() => _AddDoctorsPageState();
}

class _AddDoctorsPageState extends State<AddDoctorsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _doctorImage;
  String _doctorName = '';
  String _specialty = '';
  String _availability = '';

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _doctorImage = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "اضافة معلومات الطبيب",
          style: kAppBarDoctorsTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'اسم الطبيب'),
              onChanged: (value) => _doctorName = value,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'تخصص الطبيب او العيادة'),
              onChanged: (value) => _specialty = value,
            ),
            if (_doctorImage != null)
              Image.file(_doctorImage!, height: 100, width: 100),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: kRedElevatedButtonStyle,
                onPressed: pickImage,
                child: Text(
                  _doctorImage == null
                      ? 'قم بتحميل صورةالطبيب'
                      : 'قم بتغيير الصورة',
                  style: kButtonTextStyle,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'وقت دوام  العيادة'),
              onChanged: (value) => _availability = value,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: kRedElevatedButtonStyle,
                onPressed: () {
                  // Logic to save doctor details
                  Navigator.pop(context);
                },
                child: Text(
                  'احفظ المعلومات',
                  style: kButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
