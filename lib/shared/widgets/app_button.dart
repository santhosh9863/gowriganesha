import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';

class AppButton {
  AppButton._();

  static const Duration _pressDuration = Duration(milliseconds: 100);
  static const double _pressScale = 0.97;

  static Widget filled({
    required VoidCallback? onPressed,
    required Widget child,
    Key? key,
  }) {
    return _PressScale(
      onPressed: onPressed,
      child: FilledButton(
        key: key,
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
        ),
        child: child,
      ),
    );
  }

  static Widget outlined({
    required VoidCallback? onPressed,
    required Widget child,
    Key? key,
  }) {
    return _PressScale(
      onPressed: onPressed,
      child: OutlinedButton(
        key: key,
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
        ),
        child: child,
      ),
    );
  }

  static Widget text({
    required VoidCallback? onPressed,
    required Widget child,
    Key? key,
  }) {
    return _PressScale(
      onPressed: onPressed,
      child: TextButton(
        key: key,
        onPressed: onPressed,
        child: child,
      ),
    );
  }

  static Widget filledIcon({
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    Key? key,
  }) {
    return _PressScale(
      onPressed: onPressed,
      child: FilledButton.icon(
        key: key,
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
        ),
      ),
    );
  }

  static Widget tonalIcon({
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    Key? key,
  }) {
    return _PressScale(
      onPressed: onPressed,
      child: FilledButton.tonalIcon(
        key: key,
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _PressScale({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppButton._pressDuration,
    );
    _scale = Tween<double>(begin: 1.0, end: AppButton._pressScale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.stop();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (widget.onPressed != null) _ctrl.forward();
      },
      onPointerUp: (_) {
        if (widget.onPressed != null) _ctrl.reverse();
      },
      onPointerCancel: (_) {
        if (widget.onPressed != null) _ctrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
