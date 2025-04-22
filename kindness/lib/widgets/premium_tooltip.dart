import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textFontSize;
  final EdgeInsetsGeometry padding;
  final bool showArrow;
  final double arrowSize;
  final bool showGlow;
  final double glowIntensity;
  final double glowRadius;
  final double glowSpread;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final bool showIcon;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final double maxWidth;
  final TextAlign textAlign;
  final bool wrap;
  final double elevation;
  final Duration displayDuration;
  final bool dismissOnTap;
  final bool showOnLongPress;
  final bool showOnHover;

  const PremiumTooltip({
    Key? key,
    required this.message,
    required this.child,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.textColor,
    this.textFontSize,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    this.showArrow = true,
    this.arrowSize = 8.0,
    this.showGlow = false,
    this.glowIntensity = 0.5,
    this.glowRadius = 10.0,
    this.glowSpread = 2.0,
    this.showBorder = false,
    this.borderWidth = 1.0,
    this.borderColor,
    this.showIcon = false,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.showCloseButton = false,
    this.onClose,
    this.maxWidth = 200.0,
    this.textAlign = TextAlign.center,
    this.wrap = true,
    this.elevation = 4.0,
    this.displayDuration = const Duration(seconds: 2),
    this.dismissOnTap = true,
    this.showOnLongPress = true,
    this.showOnHover = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? AppTheme.primaryColor;
    final textColor = this.textColor ?? Colors.white;
    final borderColor = this.borderColor ?? textColor;
    final iconColor = this.iconColor ?? textColor;

    return Tooltip(
      message: '',
      preferBelow: true,
      showDuration: displayDuration,
      triggerMode:
          showOnHover ? TooltipTriggerMode.longPress : TooltipTriggerMode.tap,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(glowIntensity),
                  blurRadius: glowRadius,
                  spreadRadius: glowSpread,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontSize: textFontSize,
        fontWeight: FontWeight.w500,
      ),
      padding: padding,
      margin: EdgeInsets.only(
        top: showArrow ? arrowSize : 0,
      ),
      verticalOffset: showArrow ? arrowSize : 0,
      waitDuration: const Duration(milliseconds: 500),
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: dismissOnTap
                ? () {
                    // Hide tooltip by triggering a rebuild
                    (context as Element).markNeedsBuild();
                  }
                : null,
            child: child,
          );
        },
      ),
      richMessage: TextSpan(
        children: [
          if (showIcon && icon != null) ...[
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ],
          TextSpan(
            text: message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: textFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showCloseButton) ...[
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    size: iconSize ?? 16.0,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PremiumTooltipOverlay extends StatelessWidget {
  final String message;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textFontSize;
  final EdgeInsetsGeometry padding;
  final bool showArrow;
  final double arrowSize;
  final bool showGlow;
  final double glowIntensity;
  final double glowRadius;
  final double glowSpread;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final bool showIcon;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final double maxWidth;
  final TextAlign textAlign;
  final bool wrap;
  final double elevation;
  final Offset offset;
  final bool dismissOnTap;
  final VoidCallback? onDismiss;

  const PremiumTooltipOverlay({
    Key? key,
    required this.message,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.textColor,
    this.textFontSize,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    this.showArrow = true,
    this.arrowSize = 8.0,
    this.showGlow = false,
    this.glowIntensity = 0.5,
    this.glowRadius = 10.0,
    this.glowSpread = 2.0,
    this.showBorder = false,
    this.borderWidth = 1.0,
    this.borderColor,
    this.showIcon = false,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.showCloseButton = false,
    this.onClose,
    this.maxWidth = 200.0,
    this.textAlign = TextAlign.center,
    this.wrap = true,
    this.elevation = 4.0,
    this.offset = Offset.zero,
    this.dismissOnTap = true,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? AppTheme.primaryColor;
    final textColor = this.textColor ?? Colors.white;
    final borderColor = this.borderColor ?? textColor;
    final iconColor = this.iconColor ?? textColor;

    Widget tooltipContent = Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(glowIntensity),
                  blurRadius: glowRadius,
                  spreadRadius: glowSpread,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon && icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
            const SizedBox(height: 8.0),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: textFontSize,
              fontWeight: FontWeight.w500,
            ),
            textAlign: textAlign,
          ),
          if (showCloseButton) ...[
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    size: iconSize ?? 16.0,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (animate) {
      tooltipContent = AnimationUtils.fadeSlideUp(
        child: tooltipContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTap: dismissOnTap ? onDismiss : null,
        child: tooltipContent,
      ),
    );
  }
}
