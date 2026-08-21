import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrandLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const BrandLogo({super.key, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/images/logo.svg',
    width: width ?? 120.w,
    height: height ?? 120.w,
    colorFilter: color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null,
    placeholderBuilder: (BuildContext context) => SizedBox(
      width: width ?? 120.w,
      height: height ?? 120.w,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );
}
