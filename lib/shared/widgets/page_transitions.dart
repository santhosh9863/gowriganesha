import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class PageTransition {
  static NoTransitionPage fadeSlide(Widget page) {
    return NoTransitionPage(
      child: page,
    );
  }
}
