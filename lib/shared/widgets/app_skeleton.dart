import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';

class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.surfaceContainerHighest.withAlpha(100),
                colorScheme.surfaceContainerHighest.withAlpha(200),
                colorScheme.surfaceContainerHighest.withAlpha(100),
              ],
              stops: [
                max(0.0, _ctrl.value - 0.3),
                _ctrl.value,
                min(1.0, _ctrl.value + 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppSkeletonCard extends StatelessWidget {
  final int lines;

  const AppSkeletonCard({super.key, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: const Color(0x1F000000)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppSkeleton(width: 80, height: 12),
                const Spacer(),
                const AppSkeleton(width: 24, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppSkeleton(width: 160, height: 20),
            const SizedBox(height: AppSpacing.xs),
            ...List.generate(lines, (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppSkeleton(
                width: i == lines - 1 ? 120 : double.infinity,
                height: 12,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class AppSkeletonList extends StatelessWidget {
  final int itemCount;

  const AppSkeletonList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const AppSkeletonCard(),
    );
  }
}
