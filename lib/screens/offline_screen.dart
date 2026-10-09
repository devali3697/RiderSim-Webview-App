import 'package:flutter/material.dart';
import 'package:ridersim_webview_app/widgets/retry_view.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({
    super.key,
    required this.onRetry,
    this.isRetrying = false,
  });

  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return RetryView(
      title: 'No Internet Connection',
      description:
      'Check your Wi-Fi or mobile data connection and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      isRetrying: isRetrying,
    );
  }
}