import 'package:flutter/material.dart';
import 'package:racheeta/features/registration/patient/screen/patient_signup_screen.dart';

import '../../../../constansts/constants.dart';
import '../widget/toogle_buttons_widget.dart';
import 'medical_welcome_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = -1;

  void _onToggleSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onContinuePressed() {
    switch (_selectedIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OldPatientsSignupScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MedicaWelcomeScreen()),
        );
        break;
      // case 2:
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => JobSeekerSignUpScreen()),
      //   );
      //   break;

      default:
        // No valid selection, do nothing
        break;
    }
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 90),
              const Text(
                'اختر نوع التسجيل :',
                style: kHeaderTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              GridView.count(
                crossAxisCount: 2, // Keep the same number of columns
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
                children: [
                  ToggleButtonItem(
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onToggleSelected(0),
                    iconPath: 'assets/icons/patient1.png',
                    label: 'سجل كمريض',
                  ),

                  ToggleButtonItem(
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onToggleSelected(1),
                    iconPath: 'assets/icons/healthserviceprovider.png',
                    label: 'سجل كمقدم خدمات طبية',
                  ),
                  // Here we use a Row widget to center the third button across two columns
                  // ToggleButtonItem(
                  //   isSelected: _selectedIndex ==
                  //       2, // Updated the selected index for job seeker
                  //   onTap: () => _onToggleSelected(2),
                  //   iconPath: 'assets/splash/splashjoobseeker.png',
                  //   label: 'سجل كباحث عن وظيفة',
                  // ),
                ],
              ),
              const SizedBox(height: 50),
              // RichText(
              //   textAlign: TextAlign.center,
              //   text: TextSpan(
              //     text: 'اذا كنت مسجلا اذهب الى ',
              //     style: const TextStyle(
              //         color: Colors.black, fontSize: 16), // Default style
              //     children: [
              //       TextSpan(
              //         text: 'تسجيل الدخول',
              //         style: const TextStyle(
              //           color: Colors.blue, // Blue color for the specific text
              //           decoration:
              //               TextDecoration.underline, // Underline the text
              //         ),
              //         recognizer: TapGestureRecognizer()
              //           ..onTap = () {
              //             print(
              //                 "Navigate to login"); // Add your navigation logic here
              //           },
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 50),
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
            ],
          ),
        ),
      ),
    );
  }
}
