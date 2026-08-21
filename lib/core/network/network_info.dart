import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection? connectionChecker;

  const NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    if (kIsWeb) return true; // Fallback for Web
    // hasInternetAccess is the standard check for this package
    return await connectionChecker?.hasInternetAccess ?? false;
  }
}
