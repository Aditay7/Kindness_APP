import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumBadge extends StatelessWidget {
  final String? text;
  final Widget? child;
  final BadgeType type;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textFontSize;
  final EdgeInsetsGeometry padding;
  final double? size;
  final bool showBorder;
  final bool isPulsing;

  const PremiumBadge({
    Key? key,
    this.text,
    this.child,
    this.type = BadgeType.primary,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.textColor,
    this.textFontSize,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 4.0,
    ),
    this.size,
    this.showBorder = false,
    this.isPulsing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? _getBackgroundColor(type);
    final textColor = this.textColor ?? _getTextColor(type);

    Widget badgeContent = Container(
      padding: padding,
      constraints: BoxConstraints(
        minWidth: size ?? 0,
        minHeight: size ?? 0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: textColor,
                width: 1.0,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child ??
          (text != null
              ? Text(
                  text!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null),
    );

    if (animate) {
      badgeContent = AnimationUtils.fadeSlideUp(
        child: badgeContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    if (isPulsing) {
      badgeContent = _PulsingBadge(
        child: badgeContent,
        color: backgroundColor,
      );
    }

    return badgeContent;
  }

  Color _getBackgroundColor(BadgeType type) {
    switch (type) {
      case BadgeType.primary:
        return AppTheme.primaryColor.withOpacity(0.1);
      case BadgeType.success:
        return AppTheme.successColor.withOpacity(0.1);
      case BadgeType.warning:
        return AppTheme.warningColor.withOpacity(0.1);
      case BadgeType.error:
        return AppTheme.errorColor.withOpacity(0.1);
      case BadgeType.info:
        return AppTheme.infoColor.withOpacity(0.1);
    }
  }

  Color _getTextColor(BadgeType type) {
    switch (type) {
      case BadgeType.primary:
        return AppTheme.primaryColor;
      case BadgeType.success:
        return AppTheme.successColor;
      case BadgeType.warning:
        return AppTheme.warningColor;
      case BadgeType.error:
        return AppTheme.errorColor;
      case BadgeType.info:
        return AppTheme.infoColor;
    }
  }
}

enum BadgeType {
  primary,
  success,
  warning,
  error,
  info,
}

class _PulsingBadge extends StatefulWidget {
  final Widget child;
  final Color color;

  const _PulsingBadge({
    Key? key,
    required this.child,
    required this.color,
  }) : super(key: key);

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class PremiumBadgeOverlay extends StatelessWidget {
  final Widget child;
  final String? text;
  final BadgeType type;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textFontSize;
  final EdgeInsetsGeometry padding;
  final double? size;
  final bool showBorder;
  final bool isPulsing;
  final Alignment alignment;

  const PremiumBadgeOverlay({
    Key? key,
    required this.child,
    this.text,
    this.type = BadgeType.primary,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.textColor,
    this.textFontSize,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 4.0,
    ),
    this.size,
    this.showBorder = false,
    this.isPulsing = false,
    this.alignment = Alignment.topRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: alignment == Alignment.topRight ||
                  alignment == Alignment.bottomRight
              ? 0
              : null,
          left: alignment == Alignment.topLeft ||
                  alignment == Alignment.bottomLeft
              ? 0
              : null,
          top: alignment == Alignment.topRight || alignment == Alignment.topLeft
              ? 0
              : null,
          bottom: alignment == Alignment.bottomRight ||
                  alignment == Alignment.bottomLeft
              ? 0
              : null,
          child: Transform.translate(
            offset: Offset(
              alignment == Alignment.topRight ||
                      alignment == Alignment.bottomRight
                  ? 8.0
                  : alignment == Alignment.topLeft ||
                          alignment == Alignment.bottomLeft
                      ? -8.0
                      : 0,
              alignment == Alignment.topRight || alignment == Alignment.topLeft
                  ? -8.0
                  : alignment == Alignment.bottomRight ||
                          alignment == Alignment.bottomLeft
                      ? 8.0
                      : 0,
            ),
            child: PremiumBadge(
              text: text,
              type: type,
              animate: animate,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              borderRadius: borderRadius,
              backgroundColor: backgroundColor,
              textColor: textColor,
              textFontSize: textFontSize,
              padding: padding,
              size: size,
              showBorder: showBorder,
              isPulsing: isPulsing,
            ),
          ),
        ),
      ],
    );
  }
}
