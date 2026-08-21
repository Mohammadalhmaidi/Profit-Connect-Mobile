import 'dart:async';
import 'package:flutter/material.dart';

/// Fades and slides an item in from the bottom with a slight delay,
/// giving lists a staggered entrance. Key the ancestor with the item id
/// so the animation only plays once per item.
class StaggerEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final double offset;
  final Duration duration;
  final Duration staggerDelay;

  const StaggerEntrance({
    required this.child,
    required this.index,
    this.offset = 22,
    this.duration = const Duration(milliseconds: 420),
    this.staggerDelay = const Duration(milliseconds: 45),
    super.key,
  });

  @override
  State<StaggerEntrance> createState() => _StaggerEntranceState();
}

class _StaggerEntranceState extends State<StaggerEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0, end: 1));
    _offset = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: Offset(0, widget.offset / 100), end: Offset.zero));
    _timer = Timer(
      widget.staggerDelay * widget.index,
      () => _controller.forward(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _offset, child: widget.child),
  );
}
