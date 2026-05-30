import 'package:flutter/material.dart';

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
];

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              return Expanded(
                child: _NavBarItem(
                  item: _navItems[index],
                  isSelected: index == currentIndex,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _pillOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pillOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Opacity(
                      opacity: _pillOpacity.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _scale.value,
                      child: Icon(
                        widget.item.icon,
                        size: 24,
                        color: widget.isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 11,
        fontWeight:
                                widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: widget.isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
