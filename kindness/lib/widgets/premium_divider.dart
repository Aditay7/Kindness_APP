import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final EdgeInsetsGeometry margin;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showGradient;
  final List<Color>? gradientColors;
  final double gradientWidth;
  final bool isVertical;
  final double borderRadius;
  final bool showGlow;
  final double glowIntensity;
  final double glowRadius;
  final double glowSpread;

  const PremiumDivider({
    Key? key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.color,
    this.margin = EdgeInsets.zero,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.showGradient = false,
    this.gradientColors,
    this.gradientWidth = 100.0,
    this.isVertical = false,
    this.borderRadius = 0.0,
    this.showGlow = false,
    this.glowIntensity = 0.5,
    this.glowRadius = 10.0,
    this.glowSpread = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? AppTheme.primaryColor.withOpacity(0.1);
    final gradientColors = this.gradientColors ??
        [
          color.withOpacity(0.0),
          color,
          color,
          color.withOpacity(0.0),
        ];

    Widget dividerContent = Container(
      height: isVertical ? null : height,
      width: isVertical ? height : null,
      margin: margin,
      decoration: BoxDecoration(
        color: showGradient ? null : color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withOpacity(glowIntensity),
                  blurRadius: glowRadius,
                  spreadRadius: glowSpread,
                ),
              ]
            : null,
      ),
      child: showGradient
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  colors: gradientColors,
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  begin:
                      isVertical ? Alignment.topCenter : Alignment.centerLeft,
                  end: isVertical
                      ? Alignment.bottomCenter
                      : Alignment.centerRight,
                ),
              ),
            )
          : null,
    );

    if (animate) {
      dividerContent = AnimationUtils.fadeSlideUp(
        child: dividerContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    return dividerContent;
  }
}

class PremiumDashedDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final EdgeInsetsGeometry margin;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final double dashWidth;
  final double dashSpace;
  final bool isVertical;
  final double borderRadius;
  final bool showGlow;
  final double glowIntensity;
  final double glowRadius;
  final double glowSpread;

  const PremiumDashedDivider({
    Key? key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.color,
    this.margin = EdgeInsets.zero,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
    this.isVertical = false,
    this.borderRadius = 0.0,
    this.showGlow = false,
    this.glowIntensity = 0.5,
    this.glowRadius = 10.0,
    this.glowSpread = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? AppTheme.primaryColor.withOpacity(0.1);

    Widget dividerContent = Container(
      height: isVertical ? null : height,
      width: isVertical ? height : null,
      margin: margin,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          strokeWidth: thickness,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
          isVertical: isVertical,
          borderRadius: borderRadius,
          showGlow: showGlow,
          glowIntensity: glowIntensity,
          glowRadius: glowRadius,
          glowSpread: glowSpread,
        ),
      ),
    );

    if (animate) {
      dividerContent = AnimationUtils.fadeSlideUp(
        child: dividerContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    return dividerContent;
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final bool isVertical;
  final double borderRadius;
  final bool showGlow;
  final double glowIntensity;
  final double glowRadius;
  final double glowSpread;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.isVertical,
    required this.borderRadius,
    required this.showGlow,
    required this.glowIntensity,
    required this.glowRadius,
    required this.glowSpread,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (showGlow) {
      paint.maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        glowRadius,
      );
    }

    final path = Path();
    final dashPath = Path();

    if (isVertical) {
      var currentY = 0.0;
      while (currentY < size.height) {
        dashPath.moveTo(size.width / 2, currentY);
        dashPath.lineTo(size.width / 2, currentY + dashWidth);
        currentY += dashWidth + dashSpace;
      }
    } else {
      var currentX = 0.0;
      while (currentX < size.width) {
        dashPath.moveTo(currentX, size.height / 2);
        dashPath.lineTo(currentX + dashWidth, size.height / 2);
        currentX += dashWidth + dashSpace;
      }
    }

    if (borderRadius > 0) {
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );
      canvas.clipPath(path);
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
