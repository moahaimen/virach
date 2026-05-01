import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<dynamic>? _connectivitySubscription;
  Timer? _pollingTimer;
  bool? _lastStatus;
  bool _disposed = false;

  Stream<bool> get connectionStatusStream => _controller.stream;

  ConnectivityService() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((_) => _verify());

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _verify(),
    );

    _verify();
  }

  Future<void> _verify() async {
    if (_disposed) return;

    final hasInternet = await InternetConnection().hasInternetAccess;
    if (_disposed || hasInternet == _lastStatus) return;

    _lastStatus = hasInternet;
    _controller.add(hasInternet);
  }

  void dispose() {
    _disposed = true;
    _connectivitySubscription?.cancel();
    _pollingTimer?.cancel();
    _controller.close();
  }
}
