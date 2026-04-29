import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/home_screen.dart';

class SignupWithEmail extends StatefulWidget {
  @override
  _SignupWithEmailState createState() => _SignupWithEmailState();
}

class _SignupWithEmailState extends State<SignupWithEmail> {
  final _formKey = GlobalKey<FormState>();
  bool isMale = true; // Default to male
  String email = '';
  String fullName = '';
  String phoneNumber = '';
  String password = '';
  String birthDate = '';
  bool hasMedicalInsurance = false;
  bool _isRegistered = false;

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('fullName', fullName);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('password', password);
    await prefs.setString('birthDate', birthDate);
    await prefs.setBool('isMale', isMale);
    await prefs.setBool('hasMedicalInsurance', hasMedicalInsurance);
    await prefs.setBool('isRegistered', true);

    setState(() {
      _isRegistered = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                textAlign: TextAlign.right,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'ادخل الايميل',
                  hintText: 'ادخل الايميل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الايميل';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value ?? '';
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                textAlign: TextAlign.right,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  hintText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم الكامل';
                  }
                  return null;
                },
                onSaved: (value) {
                  fullName = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: 'رقم الهاتف',
                  border: const OutlineInputBorder(),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/iraq_flag.png', width: 24),
                      const SizedBox(width: 8),
                      const Text('+964'),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                textAlign: TextAlign.right,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  hintText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.visibility),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value ?? '';
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                textAlign: TextAlign.right,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'تاريخ الميلاد',
                  hintText: 'تاريخ الميلاد',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال تاريخ الميلاد';
                  }
                  return null;
                },
                onSaved: (value) {
                  birthDate = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              const Text('النوع'),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMale = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isMale ? Colors.white : Colors.black,
                        backgroundColor:
                            isMale ? Colors.blue : Colors.grey[200],
                      ),
                      child: const Text('ذكر'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMale = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isMale ? Colors.black : Colors.white,
                        backgroundColor:
                            isMale ? Colors.grey[200] : Colors.blue,
                      ),
                      child: Text('أنثى'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              const Text(
                'عند اكتمال التسجيل فانت توافق على شروط تطبيق راجيتة',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _saveUserData();
                    }
                  },
                  child: const Text('انشئ حساب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
