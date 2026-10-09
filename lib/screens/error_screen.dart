import 'package:flutter/material.dart';
import 'package:ridersim_webview_app/widgets/retry_view.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.title,
    required this.description,
    required this.onRetry,
    required this.onHome,
    this.isRetrying = false,
  });

  final String title;
  final String description;

  final VoidCallback onRetry;
  final VoidCallback onHome;

  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return RetryView(
      title: title,
      description: description,
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
      isRetrying: isRetrying,
      secondaryLabel:
      'Back to Home',
      onSecondaryAction:
      onHome,
    );
  }
}