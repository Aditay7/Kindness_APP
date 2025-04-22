import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumFab extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double size;
  final double borderRadius;
  final Duration animationDuration;
  final bool isDisabled;
  final bool showShadow;
  final bool showRippleEffect;
  final bool showBadge;
  final Color? badgeColor;
  final double badgeSize;
  final TextStyle? badgeTextStyle;
  final VoidCallback? onLongPress;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;
  final bool isExtended;
  final String? label;
  final TextStyle? labelStyle;
  final bool showIcon;
  final double iconSize;
  final bool showTooltip;
  final String? tooltip;
  final bool showProgressIndicator;
  final double progressValue;
  final Color? progressColor;
  final double progressSize;
  final bool showSuccessIcon;
  final bool showErrorIcon;
  final bool showWarningIcon;
  final bool showInfoIcon;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final VoidCallback? onWarning;
  final VoidCallback? onInfo;

  const PremiumFab({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6,
    this.size = 56,
    this.borderRadius = 28,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isDisabled = false,
    this.showShadow = true,
    this.showRippleEffect = true,
    this.showBadge = false,
    this.badgeColor,
    this.badgeSize = 16,
    this.badgeTextStyle,
    this.onLongPress,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
    this.isExtended = false,
    this.label,
    this.labelStyle,
    this.showIcon = true,
    this.iconSize = 24,
    this.showTooltip = false,
    this.tooltip,
    this.showProgressIndicator = false,
    this.progressValue = 0,
    this.progressColor,
    this.progressSize = 24,
    this.showSuccessIcon = false,
    this.showErrorIcon = false,
    this.showWarningIcon = false,
    this.showInfoIcon = false,
    this.onSuccess,
    this.onError,
    this.onWarning,
    this.onInfo,
  });

  @override
  State<PremiumFab> createState() => _PremiumFabState();
}

class _PremiumFabState extends State<PremiumFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: widget.backgroundColor ?? colorScheme.primary,
      elevation: widget.showShadow ? widget.elevation : 0,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InkWell(
        onTap: widget.isDisabled ? null : widget.onPressed,
        onLongPress: widget.isDisabled ? null : widget.onLongPress,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          width: widget.isExtended ? null : widget.size,
          height: widget.size,
          padding: widget.isExtended
              ? const EdgeInsets.symmetric(horizontal: 16)
              : null,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? colorScheme.primary,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showIcon)
                      IconTheme(
                        data: IconThemeData(
                          color:
                              widget.foregroundColor ?? colorScheme.onPrimary,
                          size: widget.iconSize,
                        ),
                        child: widget.child,
                      ),
                    if (widget.isExtended && widget.label != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          widget.label!,
                          style:
                              (widget.labelStyle ?? theme.textTheme.labelLarge)
                                  ?.copyWith(
                            color:
                                widget.foregroundColor ?? colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.showBadge)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: widget.badgeSize,
                    height: widget.badgeSize,
                    decoration: BoxDecoration(
                      color: widget.badgeColor ?? colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '!',
                        style: (widget.badgeTextStyle ??
                                theme.textTheme.labelSmall)
                            ?.copyWith(
                          color: colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.showProgressIndicator)
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: widget.progressValue,
                    color: widget.progressColor ?? colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                ),
              if (widget.showSuccessIcon)
                Positioned.fill(
                  child: Icon(
                    Icons.check,
                    color: colorScheme.onPrimary,
                  ),
                ),
              if (widget.showErrorIcon)
                Positioned.fill(
                  child: Icon(
                    Icons.error,
                    color: colorScheme.onPrimary,
                  ),
                ),
              if (widget.showWarningIcon)
                Positioned.fill(
                  child: Icon(
                    Icons.warning,
                    color: colorScheme.onPrimary,
                  ),
                ),
              if (widget.showInfoIcon)
                Positioned.fill(
                  child: Icon(
                    Icons.info,
                    color: colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
