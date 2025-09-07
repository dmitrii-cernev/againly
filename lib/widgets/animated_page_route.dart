import 'package:flutter/material.dart';

class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;

  AnimatedPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransitionStatic(animation, secondaryAnimation, child, curve);
          },
        );

  static Widget _buildTransitionStatic(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    Curve curve,
  ) {
    // Primary animation (entering)
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    // Secondary animation (exiting)
    final exitScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve,
    ));

    final exitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve,
    ));

    return Stack(
      children: [
        // Exit animation for the previous page
        if (secondaryAnimation.value > 0)
          FadeTransition(
            opacity: exitFadeAnimation,
            child: ScaleTransition(
              scale: exitScaleAnimation,
              child: Container(),
            ),
          ),
        // Enter animation for the new page
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;

  SlideUpPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildSlideUpTransitionStatic(animation, secondaryAnimation, child, curve);
          },
        );

  static Widget _buildSlideUpTransitionStatic(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    Curve curve,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.0, 0.3, curve: curve),
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    // Add a backdrop blur effect
    final blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.0, 0.5, curve: curve),
    ));

    return Stack(
      children: [
        // Backdrop with blur
        AnimatedBuilder(
          animation: blurAnimation,
          builder: (context, _) {
            return Container(
              color: Colors.black.withValues(alpha: animation.value * 0.3),
            );
          },
        ),
        // Main slide up transition
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}