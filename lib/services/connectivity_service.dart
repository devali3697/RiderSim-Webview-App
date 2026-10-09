import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final InternetConnection _connection =
  InternetConnection.createInstance();

  /// Returns true only when actual internet access is available.
  static Future<bool> hasInternet() async {
    try {
      return await _connection.hasInternetAccess;
    } catch (_) {
      return false;
    }
  }

  /// Listen for internet status changes.
  static Stream<InternetStatus> get onStatusChange {
    return _connection.onStatusChange;
  }

  /// Helper so UI/services don't need to compare enum manually.
  static bool isConnectedStatus(
      InternetStatus status,
      ) {
    return status == InternetStatus.connected;
  }

  /// Convert status stream into a simpler bool stream.
  static Stream<bool> get connectionStream {
    return _connection.onStatusChange.map(
          (status) => status == InternetStatus.connected,
    );
  }
}