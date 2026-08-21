import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_colors.dart';

class CustomNumPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const CustomNumPad({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: context.colors.surfaceMuted,
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 20.h),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        SizedBox(height: 12.h),
        _buildRow(context, ['4', '5', '6']),
        SizedBox(height: 12.h),
        _buildRow(context, ['7', '8', '9']),
        SizedBox(height: 12.h),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            _buildDigitButton(context, '0'),
            Expanded(
              child: IconButton(
                onPressed: onBackspacePressed,
                icon: Icon(
                  Icons.backspace_outlined,
                  size: 24.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().bottomBarHeight),
      ],
    ),
  );

  Widget _buildRow(BuildContext context, List<String> digits) =>
      Row(children: digits.map((d) => _buildDigitButton(context, d)).toList());

  Widget _buildDigitButton(BuildContext context, String digit) {
    var subtext = '';
    if (digit == '2') subtext = 'A B C';
    if (digit == '3') subtext = 'D E F';
    if (digit == '4') subtext = 'G H I';
    if (digit == '5') subtext = 'J K L';
    if (digit == '6') subtext = 'M N O';
    if (digit == '7') subtext = 'P Q R S';
    if (digit == '8') subtext = 'T U V';
    if (digit == '9') subtext = 'W X Y Z';

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: InkWell(
          onTap: () => onDigitPressed(digit),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  digit,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (subtext.isNotEmpty)
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
