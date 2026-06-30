import 'package:flutter/material.dart';

class PressAnimator extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const PressAnimator({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<PressAnimator> createState() => _PressAnimatorState();
}

class _PressAnimatorState extends State<PressAnimator> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (widget.onTap != null) setState(() => _pressed = true);
      },
      onPointerUp: (_) {
        if (widget.onTap != null) setState(() => _pressed = false);
      },
      onPointerCancel: (_) {
        if (widget.onTap != null) setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}
