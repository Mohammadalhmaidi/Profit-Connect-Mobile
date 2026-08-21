import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/theme_colors.dart';

/// A sweeping-gradient shimmer used to build loading skeletons.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const Shimmer({
    required this.child,
    this.baseColor,
    this.highlightColor,
    super.key,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bright = Theme.of(context).brightness == Brightness.dark;
    final base =
        widget.baseColor ??
        (bright ? const Color(0xFF2A2A33) : const Color(0xFFE7E7F0));
    final highlight =
        widget.highlightColor ??
        (bright ? const Color(0xFF3A3A46) : const Color(0xFFF5F5FB));
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.3, 0.5, 0.7],
          transform: _SlideGradientTransform(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double percent;
  const _SlideGradientTransform(this.percent);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (2 * percent - 1), 0, 0);
}

/// A rounded placeholder box used inside skeletons.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color? color;

  const ShimmerBox({
    required this.height,
    this.width,
    this.radius = 8,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color ?? context.colors.inputBorder,
      borderRadius: BorderRadius.circular(radius.r),
    ),
  );
}

/// A skeleton row for lists (avatar + two text lines), used on load.
class ListTileSkeleton extends StatelessWidget {
  final double avatarRadius;
  final double lineHeight;

  const ListTileSkeleton({
    this.avatarRadius = 22,
    this.lineHeight = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    child: Row(
      children: [
        ShimmerBox(
          width: avatarRadius * 2,
          height: avatarRadius * 2,
          radius: avatarRadius,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: lineHeight, width: double.infinity),
              SizedBox(height: 8.h),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: ShimmerBox(height: lineHeight),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// A few shuffled list skeletons that can fill a loading screen.
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder? itemBuilder;

  const ListSkeleton({this.itemCount = 7, this.itemBuilder, super.key});

  @override
  Widget build(BuildContext context) => Shimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 6.h),
      itemBuilder:
          itemBuilder ??
          (context, index) => ListTileSkeleton(
            avatarRadius: [22, 26, 18, 24, 20][index % 5].toDouble(),
          ),
    ),
  );
}
