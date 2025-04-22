import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumProgressIndicator extends StatelessWidget {
  final double value;
  final double? size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final String? label;
  final TextStyle? labelStyle;
  final bool showPercentage;
  final bool isCircular;
  final double borderRadius;
  final bool showGlow;

  const PremiumProgressIndicator({
    Key? key,
    required this.value,
    this.size,
    this.strokeWidth = 4.0,
    this.color,
    this.backgroundColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.label,
    this.labelStyle,
    this.showPercentage = true,
    this.isCircular = true,
    this.borderRadius = 8.0,
    this.showGlow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? AppTheme.primaryColor;
    final backgroundColor = this.backgroundColor ?? color.withOpacity(0.1);
    final size = this.size ?? (isCircular ? 48.0 : 200.0);

    Widget progressContent = isCircular
        ? _buildCircularProgress(context, theme, color, backgroundColor, size)
        : _buildLinearProgress(context, theme, color, backgroundColor, size);

    if (animate) {
      progressContent = AnimationUtils.fadeSlideUp(
        child: progressContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    return progressContent;
  }

  Widget _buildCircularProgress(
    BuildContext context,
    ThemeData theme,
    Color color,
    Color backgroundColor,
    double size,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          if (label != null || showPercentage)
            Text(
              label ?? '${(value * 100).toInt()}%',
              style: labelStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildLinearProgress(
    BuildContext context,
    ThemeData theme,
    Color color,
    Color backgroundColor,
    double size,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showGlow)
          Container(
            height: strokeWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: LinearProgressIndicator(
            value: value,
            minHeight: strokeWidth,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (label != null || showPercentage) ...[
          const SizedBox(height: 8.0),
          Text(
            label ?? '${(value * 100).toInt()}%',
            style: labelStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ],
    );
  }
}

class PremiumProgressOverlay extends StatelessWidget {
  final Widget child;
  final double value;
  final double? size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final String? label;
  final TextStyle? labelStyle;
  final bool showPercentage;
  final bool isCircular;
  final double borderRadius;
  final bool showGlow;
  final Color? overlayColor;

  const PremiumProgressOverlay({
    Key? key,
    required this.child,
    required this.value,
    this.size,
    this.strokeWidth = 4.0,
    this.color,
    this.backgroundColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.label,
    this.labelStyle,
    this.showPercentage = true,
    this.isCircular = true,
    this.borderRadius = 8.0,
    this.showGlow = true,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayColor = this.overlayColor ?? Colors.black54;

    return Stack(
      children: [
        child,
        AnimatedOpacity(
          opacity: value > 0 ? 1.0 : 0.0,
          duration: animationDuration,
          curve: animationCurve,
          child: Container(
            color: overlayColor,
            child: Center(
              child: PremiumProgressIndicator(
                value: value,
                size: size,
                strokeWidth: strokeWidth,
                color: color,
                backgroundColor: backgroundColor,
                animate: animate,
                animationDuration: animationDuration,
                animationCurve: animationCurve,
                label: label,
                labelStyle: labelStyle,
                showPercentage: showPercentage,
                isCircular: isCircular,
                borderRadius: borderRadius,
                showGlow: showGlow,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
