import 'package:flutter/material.dart';

/// Smoothly fades & scales the whole app subtree whenever the theme
/// switches between light and dark (or locale-driven rebuilds occur).
class AnimatedThemeSwitcher extends StatelessWidget {
  final Widget child;

  const AnimatedThemeSwitcher({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(brightness), child: child),
    );
  }
}
