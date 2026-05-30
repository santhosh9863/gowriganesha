import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class PageTransition {
  static CustomTransitionPage fadeSlide(Widget page) {
    return CustomTransitionPage(
      child: page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.02, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
