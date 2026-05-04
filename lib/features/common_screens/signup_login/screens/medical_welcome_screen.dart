import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import '../../../registration/hsps/screen/hsp_login_screen.dart';
import '../health_service_registration/medical_signup.dart';
import '../widget/toogle_buttons_widget.dart';

class MedicaWelcomeScreen extends StatefulWidget {
  const MedicaWelcomeScreen({super.key});

  @override
  State<MedicaWelcomeScreen> createState() => _MedicaWelcomeScreenState();
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
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalSignupScreen(role: selectedRole),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(
          title: const Text('انضم كـ مقدم خدمة'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر الفئة التي تنتمي إليها:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'سنقوم بتخصيص تجربتك بناءً على نوع الخدمة التي تقدمها.',
                style: TextStyle(fontSize: 14, color: RacheetaColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _toggleItem(1, 'assets/icons/doctor.png', 'طبيب'),
                  _toggleItem(2, 'assets/icons/pharmacist.png', 'صيدلي'),
                  _toggleItem(3, 'assets/icons/phusicaltherapist.png', 'معالج طبيعي'),
                  _toggleItem(4, 'assets/icons/nurse.png', 'ممرض'),
                  _toggleItem(5, 'assets/icons/medical_centre.png', 'مركز طبي'),
                  _toggleItem(6, 'assets/icons/hospital1.png', 'مستشفى'),
                  _toggleItem(7, 'assets/icons/hospital1.png', 'مختبر'),
                  _toggleItem(8, 'assets/icons/beuty.png', 'تجميل'),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _selectedIndex != -1 ? _onContinuePressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RacheetaColors.primary,
                  disabledBackgroundColor: RacheetaColors.border,
                ),
                child: const Text('متابعة التسجيل'),
              ),
              const SizedBox(height: 32),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'لديك حساب بالفعل؟ ',
                  style: const TextStyle(color: RacheetaColors.textSecondary, fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'تسجيل الدخول',
                      style: const TextStyle(
                        color: RacheetaColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HSPLoginPage(),
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

  Widget _toggleItem(int index, String iconPath, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onToggleSelected(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? RacheetaColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? RacheetaColors.primary : RacheetaColors.border),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: RacheetaColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
            else
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 36,
              height: 36,
              color: isSelected ? Colors.white : null,
              errorBuilder: (_, __, ___) => Icon(Icons.medical_services, color: isSelected ? Colors.white : RacheetaColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : RacheetaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
