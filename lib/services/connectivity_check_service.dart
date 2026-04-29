import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _controller.stream;

  ConnectivityService() {
    // react to network-type changes
    Connectivity().onConnectivityChanged.listen((_) => _verify());

    // poll periodically (handles “wifi without internet”)
    Timer.periodic(const Duration(seconds: 10), (_) => _verify());

    _verify(); // initial state
  }

  Future<void> _verify() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    _controller.add(hasInternet); // true = online, false = offline
  }

  void dispose() => _controller.close();
}
