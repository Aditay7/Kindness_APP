import 'package:flutter/material.dart';

class AnimationUtils {
  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide up animation
  static Widget slideUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
    double beginOffset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beginOffset, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from right animation
  static Widget slideInRight({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
    double beginOffset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beginOffset, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale animation
  static Widget scale({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutBack,
    double beginScale = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beginScale, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Combined fade and slide animation
  static Widget fadeSlideUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
    double beginOffset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, beginOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Staggered animation for list items
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration itemDuration = const Duration(milliseconds: 300),
    Duration staggerDuration = const Duration(milliseconds: 100),
    Curve curve = Curves.easeOutCubic,
    double beginOffset = 50.0,
  }) {
    return List.generate(
      children.length,
      (index) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: itemDuration,
        curve: curve,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, beginOffset * (1 - value)),
              child: child,
            ),
          );
        },
        child: children[index],
      ),
    );
  }

  // Hero animation with custom transition
  static PageRouteBuilder heroRoute({
    required Widget page,
    String? tag,
  }) {
    return PageRouteBuilder(
      settings: RouteSettings(name: tag),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  // Custom page transition
  static PageRouteBuilder customPageRoute({
    required Widget page,
    RouteTransitionType type = RouteTransitionType.fade,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case RouteTransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case RouteTransitionType.slideUp:
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          case RouteTransitionType.slideRight:
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          case RouteTransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: child,
            );
        }
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

enum RouteTransitionType {
  fade,
  slideUp,
  slideRight,
  scale,
}
