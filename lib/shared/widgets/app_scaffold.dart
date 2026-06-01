import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/shared/widgets/animated_bottom_nav.dart';

class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _transitionController;
  late final CurvedAnimation _transitionAnimation;
  int _currentBranch = 0;

  @override
  void initState() {
    super.initState();
    _currentBranch = widget.navigationShell.currentIndex;
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..value = 1.0;
    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(AppScaffold old) {
    super.didUpdateWidget(old);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex != _currentBranch) {
      _currentBranch = newIndex;
      _transitionController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _transitionAnimation.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _transitionAnimation,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}
