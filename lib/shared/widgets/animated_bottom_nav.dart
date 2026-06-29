import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/shared/widgets/sankalpa_glass.dart';

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
  _NavItem(icon: Icons.handshake_rounded, label: 'Sponsors'),
  _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Daily'),
  _NavItem(icon: Icons.receipt_long_rounded, label: 'Expenses'),
  _NavItem(icon: Icons.follow_the_signs_rounded, label: 'Pending Visits'),
];

const _navDuration = Duration(milliseconds: 280);

class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav> {
  final List<GlobalKey> _itemKeys = List.generate(
    _navItems.length,
    (_) => GlobalKey(),
  );
  final GlobalKey _navKey = GlobalKey();

  double _indicatorLeft = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void didUpdateWidget(AnimatedBottomNav old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
    }
  }

  void _updateIndicator() {
    final itemKey = _itemKeys[widget.currentIndex];
    final itemRenderBox =
        itemKey.currentContext?.findRenderObject() as RenderBox?;
    if (itemRenderBox == null || !itemRenderBox.hasSize) return;

    final navRenderBox =
        _navKey.currentContext?.findRenderObject() as RenderBox?;
    if (navRenderBox == null || !navRenderBox.hasSize) return;

    final itemCenter =
        itemRenderBox.localToGlobal(itemRenderBox.size.center(Offset.zero));
    final localCenter = navRenderBox.globalToLocal(itemCenter);

    final newLeft = localCenter.dx - 11.0;

    if (!_initialized || _indicatorLeft != newLeft) {
      setState(() {
        _indicatorLeft = newLeft;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: SankalpaGlass(
          sigma: 14,
          opacity: 0.78,
          borderRadius: BorderRadius.circular(37),
          borderColor: const Color(0x08000000),
          tintColor: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0x0D000000),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.sm,
          ),
          child: SizedBox(
            key: _navKey,
            height: 68,
            child: Stack(
              children: [
                if (_initialized)
                  AnimatedPositioned(
                    duration: _navDuration,
                    curve: Curves.easeOutCubic,
                    left: _indicatorLeft,
                    top: 6,
                    width: 22,
                    height: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                Row(
                  children: List.generate(_navItems.length, (index) {
                    final isSelected = index == widget.currentIndex;
                    return Expanded(
                      child: _NavBarItem(
                        key: _itemKeys[index],
                        item: _navItems[index],
                        isSelected: isSelected,
                        onTap: () => widget.onTap(index),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 68,
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: _navDuration,
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  AnimatedSlide(
                    offset: isSelected
                        ? Offset.zero
                        : const Offset(0, 0.18),
                    duration: _navDuration,
                    curve: Curves.easeOutCubic,
                    child: AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: _navDuration,
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.warmGray500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 24,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedDefaultTextStyle(
                  duration: _navDuration,
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.warmGray500,
                    height: 1.2,
                  ),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
