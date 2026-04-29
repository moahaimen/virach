import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_check_service.dart';

/// Listens to [ConnectivityService] and shows / hides a SnackBar globally.
/// Build returns nothing; it only manages the ScaffoldMessenger.
class ConnectivitySnackBar extends StatefulWidget {
  const ConnectivitySnackBar({super.key});

  @override
  State<ConnectivitySnackBar> createState() => _ConnectivitySnackBarState();
}

class _ConnectivitySnackBarState extends State<ConnectivitySnackBar> {
  late final StreamSubscription<bool> _sub;

  @override
  void initState() {
    super.initState();
    final svc = context.read<ConnectivityService>();

    _sub = svc.connectionStatusStream.distinct().listen((online) {
      final messenger = ScaffoldMessenger.of(context);

      if (!online) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
              'لا يوجد اتصال بالإنترنت',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(days: 365), // stay up until dismissed manually
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
          ),
        );
      } else {
        messenger.hideCurrentSnackBar();
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
