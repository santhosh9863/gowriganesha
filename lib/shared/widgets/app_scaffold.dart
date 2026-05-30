import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/shared/widgets/animated_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/collections')) return 1;
    if (location.startsWith('/daily-collections')) return 2;
    if (location.startsWith('/expenses')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/collections');
      case 2:
        context.go('/daily-collections');
      case 3:
        context.go('/expenses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex(context),
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}
