import 'dart:async';
import 'package:flutter/material.dart';
import 'package:racheeta/features/splash_screen/splash_content_screen.dart';

import '../../constansts/constants.dart';
import '../common_screens/signup_login/screens/welcome_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();

  static const int _totalPages = 8;
  static const Duration _interval = Duration(seconds: 4);

  int _currentPage = 0;
  Timer? _timer;

  // ──────────────────────────────────────────────────────────────
  // life-cycle
  // ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    /// Wait until the first frame so the [PageController] has clients,
    /// then start the auto-scroll timer.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  // helpers
  // ──────────────────────────────────────────────────────────────
  void _startAutoScroll() {
    if (!mounted || !_pageController.hasClients) return;
    _timer?.cancel();                        // just in case
    _timer = Timer.periodic(_interval, _tick);
  }

  void _tick(Timer timer) {
    if (!mounted || !_pageController.hasClients) return;

    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      setState(() {});                       // rebuild indicators, etc.
    } else {
      timer.cancel();
      _goToWelcome();
    }
  }

  void _goToWelcome() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) =>  WelcomeScreen()),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // build
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // ─── PageView with splash pages ──────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SplashContent(
                      imagePath: 'assets/splash/splash1.png',
                      text: 'احجز لتفحص في عيادة'),
                   SplashContent(
                      imagePath: 'assets/splash/splash2.png',
                      text: 'ابحث عن صيدلية'),
                   SplashContent(
                      imagePath: 'assets/splash/splash3.png',
                      text: 'احجز مكالمة مع دكتور'),
                   SplashContent(
                      imagePath: 'assets/splash/splashmdcenterlenoardo.png',
                      text: 'تبحث عن مركز طبي ؟'),
                   SplashContent(
                      imagePath: 'assets/splash/splashhospital.png',
                      text: 'تبحث عن مستشفى ؟'),
                   SplashContent(
                      imagePath: 'assets/splash/splashbeauty.png',
                      text: 'تبحثين عن مركز تجميل ؟'),
                   SplashContent(
                      imagePath: 'assets/splash/splashjoobseeker.png',
                      text: 'تبحث عن وظيفة ؟'),
                   SplashContent(
                      imagePath: 'assets/splash/hms.png',
                      text: 'كل احتياجاتك الطبية \nفي مكان واحد'),
                ],
              ),
            ),

            // ─── “Login / Skip” button ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _goToWelcome,
                style: kSplashButtonStyle,
                child: const Text('تسجيل الدخول', style: kSplashTextStyle),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
