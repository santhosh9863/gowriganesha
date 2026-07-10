import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/shared/widgets/sankalpa_glass.dart';

class InAppBannerData {
  final String title;
  final String body;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onTap;

  const InAppBannerData({
    required this.title,
    required this.body,
    required this.accentColor,
    required this.icon,
    this.onTap,
  });
}

class InAppBannerNotifier extends StateNotifier<InAppBannerData?> {
  InAppBannerNotifier() : super(null);

  void show(InAppBannerData banner) {
    _timer?.cancel();
    if (state == null) {
      state = banner;
      _startTimer();
    } else {
      _queue.add(banner);
    }
  }

  void dismiss() {
    _timer?.cancel();
    state = null;
    _showNext();
  }

  final List<InAppBannerData> _queue = [];
  Timer? _timer;

  void _showNext() {
    if (_queue.isNotEmpty) {
      state = _queue.removeAt(0);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      if (state != null) dismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final inAppBannerProvider =
    StateNotifierProvider<InAppBannerNotifier, InAppBannerData?>((ref) {
  return InAppBannerNotifier();
});

class AppNotificationBanner extends ConsumerStatefulWidget {
  const AppNotificationBanner({super.key});

  @override
  ConsumerState<AppNotificationBanner> createState() =>
      _AppNotificationBannerState();
}

class _AppNotificationBannerState extends ConsumerState<AppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _slideCtrl.stop();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = ref.watch(inAppBannerProvider);

    if (banner == null) {
      _slideCtrl.reverse();
      return const SizedBox.shrink();
    }

    if (!_slideCtrl.isAnimating && _slideCtrl.value == 0) {
      _slideCtrl.forward();
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _BannerContent(
          data: banner,
          onDismiss: () =>
              ref.read(inAppBannerProvider.notifier).dismiss(),
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final InAppBannerData data;
  final VoidCallback onDismiss;

  const _BannerContent({
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: GestureDetector(
        onTap: data.onTap,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity!.abs() > 200) {
            onDismiss();
          }
        },
        child: SankalpaGlass(
          opacity: 0.88,
          borderRadius: AppRadius.largeBorder,
          borderColor: AppColors.outline,
          tintColor: AppColors.card,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 72,
                  decoration: BoxDecoration(
                    color: data.accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.large),
                      bottomLeft: Radius.circular(AppRadius.large),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: data.accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: Icon(data.icon, size: 18, color: data.accentColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        data.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warmGray600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.warmGray400,
                  ),
                  onPressed: onDismiss,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  splashRadius: 18,
                  tooltip: 'Dismiss',
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
