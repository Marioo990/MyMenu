import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ErrorWidget extends StatelessWidget {
  final String? message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool showDetails;

  const ErrorWidget({
    super.key,
    this.message,
    this.details,
    this.onRetry,
    this.icon,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 48,
                color: AppTheme.errorColor,
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Error Message
            Text(
              message ?? 'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            // Error Details
            if (details != null && showDetails) ...[
              const SizedBox(height: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Text(
                  details!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Network Error Widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      icon: Icons.wifi_off,
      message: 'No Internet Connection',
      details: 'Please check your network settings and try again.',
      onRetry: onRetry,
      showDetails: true,
    );
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: Icon(
                icon ?? Icons.inbox,
                size: 56,
                color: AppTheme.textLight,
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Title
            Text(
              title ?? 'No Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action
            if (action != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// Permission Denied Widget
class PermissionDeniedWidget extends StatelessWidget {
  final String? permission;
  final VoidCallback? onRequestPermission;

  const PermissionDeniedWidget({
    super.key,
    this.permission,
    this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 48,
                color: AppTheme.warningColor,
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Title
            Text(
              'Permission Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Message
            Text(
              permission != null
                  ? 'This app needs $permission permission to continue.'
                  : 'This app needs additional permissions to continue.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Action Button
            if (onRequestPermission != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              ElevatedButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.settings),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom Error Page
class ErrorPage extends StatelessWidget {
  final String? title;
  final String? message;
  final String? errorCode;
  final VoidCallback? onGoHome;
  final VoidCallback? onRetry;

  const ErrorPage({
    super.key,
    this.title,
    this.message,
    this.errorCode,
    this.onGoHome,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      errorCode ?? '!',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor.withOpacity(0.3),
                      ),
                    ),
                    const Icon(
                      Icons.sentiment_dissatisfied,
                      size: 80,
                      color: AppTheme.errorColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Title
              Text(
                title ?? 'Oops!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                ),
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Message
              Text(
                message ?? 'Something unexpected happened.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spacingXXL),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onGoHome != null) ...[
                    OutlinedButton.icon(
                      onPressed: onGoHome,
                      icon: const Icon(Icons.home),
                      label: const Text('Go Home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingL,
                          vertical: AppTheme.spacingM,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                  ],
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingL,
                          vertical: AppTheme.spacingM,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Inline Error Message
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 20,
              ),
              onPressed: onDismiss,
              color: AppTheme.errorColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

// Error Boundary Widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _errorDetails = details;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_errorDetails!);
      }

      return ErrorPage(
        title: 'Application Error',
        message: _errorDetails!.exception.toString(),
        onRetry: () {
          setState(() {
            _errorDetails = null;
          });
        },
      );
    }

    return widget.child;
  }
}