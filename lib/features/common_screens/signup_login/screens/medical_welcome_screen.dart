import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../constansts/constants.dart';
import '../../../registration/hsps/screen/hsp_login_screen.dart';
import '../health_service_registration/medical_signup.dart';
import '../widget/toogle_buttons_widget.dart';

class MedicaWelcomeScreen extends StatefulWidget {
  @override
  _MedicaWelcomeScreenState createState() => _MedicaWelcomeScreenState();
}

class _MedicaWelcomeScreenState extends State<MedicaWelcomeScreen> {
  int _selectedIndex = -1;

  void _onToggleSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onContinuePressed() {
    String selectedRole = '';

    switch (_selectedIndex) {
      case 1:
        selectedRole = 'doctor';
        break;
      case 2:
        selectedRole = 'pharmacist';
        break;
      case 3:
        selectedRole = 'physical-therapist';
        break;
      case 4:
        selectedRole = 'nurse';
        break;
      case 5:
        selectedRole = 'mdeidcal_center';
        break;
      case 6:
        selectedRole = 'hospital';
        break;
      case 7:
        selectedRole = 'labrotary';
        break;
      case 8:
        selectedRole = 'beauty_center';
        break;
      default:
        print('No role selected');
        return;
    }

    print('Selected role: $selectedRole'); // Debug print

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalSignupScreen(role: selectedRole),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'مرحبا بكم',
          style: kAppBarDoctorsTextStyle,
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر نوع التسجيل:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 3, // 3 columns for more compact layout
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8, // Adjusted to make buttons smaller
                children: [
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onToggleSelected(1),
                    iconPath: 'assets/icons/doctor.png',
                    label: 'طبيب',
                  ),
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 2,
                    onTap: () => _onToggleSelected(2),
                    iconPath: 'assets/icons/pharmacist.png',
                    label: 'صيدلي',
                  ),
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 3,
                    onTap: () => _onToggleSelected(3),
                    iconPath: 'assets/icons/phusicaltherapist.png',
                    label: 'معالج طبيعي',
                  ),
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 4,
                    onTap: () => _onToggleSelected(4),
                    iconPath: 'assets/icons/nurse.png',
                    label: 'ممرض',
                  ),
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 5,
                    onTap: () => _onToggleSelected(5),
                    iconPath: 'assets/icons/medical_centre.png',
                    label: 'مركز طبي',
                  ),
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 6,
                    onTap: () => _onToggleSelected(6),
                    iconPath: 'assets/icons/hospital1.png',
                    label: 'مستشفى',
                  ),
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 7,
                    onTap: () => _onToggleSelected(7),
                    iconPath: 'assets/icons/hospital1.png',
                    label: 'مختبر',
                  ),
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 8,
                    onTap: () => _onToggleSelected(8),
                    iconPath: 'assets/icons/beuty.png',
                    label: 'تجميل',
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (_selectedIndex != -1)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onContinuePressed,
                    style: kRedElevatedButtonStyle,
                    child: const Text(
                      'اكمل التسجيل',
                      style: kButtonTextStyle,
                    ),
                  ),
                ),
              const SizedBox(height: 50),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'اذا كنت مسجلا بالتطبيق سابقاً اذهب الى ',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold), // Default style
                  children: [
                    TextSpan(
                      text: 'تسجيل الدخول',
                      style: const TextStyle(
                        color: Colors.blue, fontSize: 16,
                        fontWeight:
                            FontWeight.bold, // Blue color for the specific text
                        decoration:
                            TextDecoration.underline, // Underline the text
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HSPLoginPage(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
