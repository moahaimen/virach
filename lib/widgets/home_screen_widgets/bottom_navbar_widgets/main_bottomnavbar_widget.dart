// lib/widgets/home_screen_widgets/bottom_navbar_widgets/main_bottomnavbar_widget.dart
import 'package:flutter/material.dart';
import '../../../features/screens/home_screen.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    Key? key,
    required this.currentIndex,
    this.userData,
    this.onTabSelected,
    this.useNavigation = true,
  }) : super(key: key);

  final int  currentIndex;
  final Map<String, String>? userData;

  /// Inside HomeScreen we call this to just switch tabs
  final void Function(int)? onTabSelected;

  /// When false we’re already in HomeScreen (IndexedStack mode)
  final bool useNavigation;

  /* ── navigation handler ───────────────────────────────── */
  void _onItemTapped(BuildContext ctx, int index) {
    if (index == currentIndex) return;

    // ▲ Tab-switch when we are *already* in HomeScreen
    if (!useNavigation && onTabSelected != null) {
      onTabSelected!(index);
      return;
    }

    // ▼ We’re on some stand-alone page: jump back to HomeScreen
    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(builder: (_) => HomeScreen(initialTab: index)),
    );
  }

  /* ── build ────────────────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    final theme          = Theme.of(context).bottomNavigationBarTheme;
    final background     = theme.backgroundColor ?? Theme.of(context).primaryColor;
    final selectedColor  = theme.selectedItemColor ?? Theme.of(context).colorScheme.onPrimary;
    final unselected     = theme.unselectedItemColor ?? selectedColor.withOpacity(0.6);

    return BottomNavigationBar(
      backgroundColor : background,
      selectedItemColor   : selectedColor,
      unselectedItemColor : unselected,
      currentIndex   : currentIndex,
      type           : BottomNavigationBarType.fixed,
      onTap          : (i) => _onItemTapped(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home     ), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt ), label: 'حجوزاتي'),
        BottomNavigationBarItem(icon: Icon(Icons.search   ), label: 'البحث عن وظائف'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt ), label: 'طلباتي'),
        BottomNavigationBarItem(icon: Icon(Icons.person   ), label: 'حسابي'),
      ],
    );
  }
}
