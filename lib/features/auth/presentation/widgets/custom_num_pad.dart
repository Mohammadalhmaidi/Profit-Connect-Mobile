import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class CustomNumPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const CustomNumPad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD2D4D9).withValues(alpha: 0.5), // iOS style keyboard background
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          SizedBox(height: 12.h),
          _buildRow(['4', '5', '6']),
          SizedBox(height: 12.h),
          _buildRow(['7', '8', '9']),
          SizedBox(height: 12.h),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              _buildDigitButton('0'),
              Expanded(
                child: IconButton(
                  onPressed: onBackspacePressed,
                  icon: Icon(Icons.backspace_outlined, size: 24.sp, color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().bottomBarHeight),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits.map((digit) => _buildDigitButton(digit)).toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    String subtext = '';
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
              color: Colors.white,
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
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w400, color: Colors.black),
                ),
                if (subtext.isNotEmpty)
                  Text(
                    subtext,
                    style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
