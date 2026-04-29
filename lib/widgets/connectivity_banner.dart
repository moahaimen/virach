import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_check_service.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ConnectivityService>();

    return StreamBuilder<bool>(
      stream: service.connectionStatusStream,
      initialData: true,
      builder: (_, snap) {
        final online = snap.data ?? true;

        // AnimatedSwitcher → smooth fade / slide
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: online
              ? const SizedBox.shrink()
              : MaterialBanner(
            backgroundColor: const Color(0xFFF44336),
            elevation: 4,
            leading: Lottie.asset(
              'assets/lottie/wifi_off.json',
              width: 40,
              repeat: true,
            ),
            content: const Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            actions: const [SizedBox.shrink()], // no buttons
          ),
        );
      },
    );
  }
}
