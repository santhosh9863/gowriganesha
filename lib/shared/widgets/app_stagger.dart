import 'package:flutter/material.dart';

class AppStagger extends StatelessWidget {
  final int index;
  final Widget child;
  final AnimationController controller;

  const AppStagger({
    super.key,
    required this.index,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 50;
    final start = delay / 300;
    final appear = (50 / 300).clamp(0.0, 1.0);

    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        (start + appear).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}
