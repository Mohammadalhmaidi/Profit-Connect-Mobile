import 'package:flutter/material.dart';

/// Wraps a tappable widget with a subtle press-down scale micro-interaction.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;
  final Curve curve;

  const PressableScale({
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 110),
    this.curve = Curves.easeOut,
    super.key,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _down(_) => setState(() => _pressed = true);
  void _up(_) => setState(() => _pressed = false);
  void _cancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: widget.onTap != null ? _down : null,
    onTapUp: widget.onTap != null ? _up : null,
    onTapCancel: widget.onTap != null ? _cancel : null,
    onTap: widget.onTap,
    behavior: HitTestBehavior.opaque,
    child: AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    ),
  );
}
