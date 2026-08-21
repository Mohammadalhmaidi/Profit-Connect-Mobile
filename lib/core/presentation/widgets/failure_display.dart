import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../error/failures.dart';

void showFailureSnackBar(BuildContext context, Failure failure) {
  final isValidation = failure is ValidationFailure;
  final message = isValidation && failure.errors != null
      ? failure.errors!.entries.map((e) => '${e.key}: ${e.value}').join('\n')
      : failure.message;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
        backgroundColor: failure.statusCode == 401
            ? AppColors.logoutRed
            : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
}

class FailureDialog extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const FailureDialog({required this.failure, super.key, this.onRetry});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Error'),
    content: Text(failure.message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      if (onRetry != null)
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onRetry!();
          },
          child: const Text('Retry'),
        ),
    ],
  );
}
