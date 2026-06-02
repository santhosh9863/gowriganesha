import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';

class SplashPage extends StatefulWidget {
  final bool isFirstLaunch;
  final VoidCallback onComplete;

  const SplashPage({
    super.key,
    required this.isFirstLaunch,
    required this.onComplete,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _titleOpacity = 0.0;
  double _secondLineOpacity = 0.0;
  String _displayedText = '';
  Timer? _typeTimer;

  @override
  void initState() {
    super.initState();

    if (widget.isFirstLaunch) {
      _scheduleFirstLaunch();
    } else {
      _scheduleQuickLaunch();
    }
  }

  void _scheduleFirstLaunch() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      setState(() => _titleOpacity = 1.0);
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _startTypewriter();
    });

    Future.delayed(const Duration(seconds: 3), () {
      widget.onComplete();
    });
  }

  void _scheduleQuickLaunch() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      setState(() => _titleOpacity = 1.0);
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onComplete();
    });
  }

  void _startTypewriter() {
    const text = 'A mission that will be completed.';
    _typeTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_displayedText.length < text.length) {
        setState(() {
          _displayedText = text.substring(0, _displayedText.length + 1);
        });
      } else {
        timer.cancel();
        setState(() => _secondLineOpacity = 1.0);
      }
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: _titleOpacity,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'SANKALPA',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.isFirstLaunch) ...[
                const SizedBox(height: AppSpacing.xl),
                AnimatedOpacity(
                  opacity: _titleOpacity,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _displayedText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.warmGray600,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedOpacity(
                  opacity: _secondLineOpacity,
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'No matter what.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
