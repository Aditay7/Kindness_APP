import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final BoxShadow? shadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.gradientColors,
    this.backgroundColor,
    this.elevation = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.border,
    this.shadow,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(widget.borderRadius);

    Widget cardContent = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius,
        boxShadow: [
          widget.shadow ??
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: widget.elevation,
                offset: const Offset(0, 2),
              ),
        ],
        border: widget.border,
      ),
      child: widget.child,
    );

    // Apply gradient if specified
    if (widget.gradientColors != null) {
      cardContent = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors!,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
        ),
        child: cardContent,
      );
    }

    // Apply animation if enabled
    if (widget.animate) {
      cardContent = AnimationUtils.fadeSlideUp(
        child: cardContent,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }

    // Apply tap animation if clickable
    if (widget.onTap != null) {
      cardContent = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: cardContent,
        ),
      );
    }

    return Padding(
      padding: widget.margin,
      child: cardContent,
    );
  }
}

class PremiumGradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<Color> gradientColors;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final BoxShadow? shadow;

  const PremiumGradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.gradientColors = AppTheme.primaryGradient,
    this.backgroundColor,
    this.elevation = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: child,
      onTap: onTap,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      gradientColors: gradientColors,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      border: border,
      shadow: shadow,
    );
  }
}

class PremiumSuccessCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final BoxShadow? shadow;

  const PremiumSuccessCard({
    super.key,
    required this.child,
    this.onTap,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.backgroundColor,
    this.elevation = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: child,
      onTap: onTap,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      gradientColors: AppTheme.primaryGradient,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      border: border,
      shadow: shadow,
    );
  }
}

class PremiumWarningCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final BoxShadow? shadow;

  const PremiumWarningCard({
    super.key,
    required this.child,
    this.onTap,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.backgroundColor,
    this.elevation = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: child,
      onTap: onTap,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      gradientColors: AppTheme.accentGradient,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      border: border,
      shadow: shadow,
    );
  }
}

class PremiumEmotionalCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final BoxShadow? shadow;

  const PremiumEmotionalCard({
    super.key,
    required this.child,
    this.onTap,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.backgroundColor,
    this.elevation = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: child,
      onTap: onTap,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      gradientColors: AppTheme.emotionalGradient,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      border: border,
      shadow: shadow,
    );
  }
}

class PremiumSupportiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final BoxShadow? shadow;

  const PremiumSupportiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.backgroundColor,
    this.elevation = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: child,
      onTap: onTap,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      gradientColors: AppTheme.supportiveGradient,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      border: border,
      shadow: shadow,
    );
  }
}
