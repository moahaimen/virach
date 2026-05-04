import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'package:racheeta/features/registration/patient/screen/patient_signup_screen.dart';
import 'medical_welcome_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
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
        Navigator.push(context, MaterialPageRoute(builder: (_) => OldPatientsSignupScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MedicaWelcomeScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const Icon(Icons.medical_services_rounded, size: 80, color: RacheetaColors.primary),
                const SizedBox(height: 24),
                const Text(
                  'أهلاً بك في راجيتة',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'منصتكم المتكاملة للخدمات الصحية والوظائف الطبية',
                  style: TextStyle(fontSize: 16, color: RacheetaColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                const Text(
                  'اختر نوع الانضمام:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RacheetaColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _buildOption(
                  0,
                  'أنا مريض / مستفيد',
                  'ابحث عن أطباء، احجز مواعد، واحصل على عروض صحية.',
                  Icons.person_search_outlined,
                ),
                const SizedBox(height: 12),
                _buildOption(
                  1,
                  'أنا مقدم خدمة طبية',
                  'سجل عيادتك، مركزك، أو مختبرك وأدر حجوزاتك بسهولة.',
                  Icons.local_hospital_outlined,
                ),
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: _selectedIndex != -1 ? _onContinuePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RacheetaColors.primary,
                    disabledBackgroundColor: RacheetaColors.border,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('ابدأ الآن'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, String title, String subtitle, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onToggleSelected(index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? RacheetaColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? RacheetaColors.primary : RacheetaColors.border, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? RacheetaColors.primary : RacheetaColors.mintLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : RacheetaColors.primary, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isSelected ? RacheetaColors.primary : RacheetaColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: RacheetaColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: RacheetaColors.primary),
          ],
        ),
      ),
    );
  }
}
