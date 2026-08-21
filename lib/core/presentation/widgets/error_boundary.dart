import 'package:flutter/material.dart';

/// يلتقط أخطاء البناء داخل شجرة الويدجت ويعرض شاشة خطأ ودية بدلاً من الشاشة الحمراء.
/// يستبدل [ErrorWidget.builder] مؤقتاً أثناء عمره ويستعيده عند التخلص.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final WidgetBuilder? errorBuilder;

  const ErrorBoundary({required this.child, super.key, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  late final ErrorWidgetBuilder _defaultErrorBuilder;

  @override
  void initState() {
    super.initState();
    _defaultErrorBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (details) {
      FlutterError.reportError(details);
      return widget.errorBuilder?.call(context) ?? const _FriendlyErrorScreen();
    };
  }

  @override
  void dispose() {
    ErrorWidget.builder = _defaultErrorBuilder;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FriendlyErrorScreen extends StatelessWidget {
  const _FriendlyErrorScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'An unexpected error occurred. Please try again.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
