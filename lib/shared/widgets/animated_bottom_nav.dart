import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';

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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.outline, width: 0.5),
          ),
        ),
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final isSelected = index == widget.currentIndex;
              return Expanded(
                child: _NavBarItem(
                  item: _navItems[index],
                  isSelected: isSelected,
                  onTap: () => widget.onTap(index),
                ),
              );
            }),
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
        height: 58,
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: 22,
              height: 22,
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
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
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
          ],
        ),
      ),
    );
  }
}
