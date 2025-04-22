import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final List<Color>? gradientColors;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.gradientColors,
    this.textColor,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = widget.gradientColors ?? AppTheme.primaryGradient;
    final textColor = widget.textColor ?? Colors.white;

    Widget buttonContent = Container(
      height: widget.height,
      width: widget.isFullWidth ? double.infinity : null,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: widget.isOutlined
            ? null
            : LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.isOutlined
            ? Border.all(
                color: colors.first,
                width: 2.0,
              )
            : null,
        boxShadow: widget.isOutlined
            ? null
            : [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isOutlined ? colors.first : textColor,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.isOutlined ? colors.first : textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: widget.isOutlined ? colors.first : textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );

    // Apply animation if enabled
    if (widget.animate) {
      buttonContent = AnimationUtils.fadeSlideUp(
        child: buttonContent,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: buttonContent,
      ),
    );
  }
}

class PremiumSuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumSuccessButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.textColor,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: isOutlined,
      isFullWidth: isFullWidth,
      icon: icon,
      gradientColors: AppTheme.primaryGradient,
      textColor: textColor,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }
}

class PremiumWarningButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumWarningButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.textColor,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: isOutlined,
      isFullWidth: isFullWidth,
      icon: icon,
      gradientColors: AppTheme.accentGradient,
      textColor: textColor,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }
}

class PremiumEmotionalButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumEmotionalButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.textColor,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: isOutlined,
      isFullWidth: isFullWidth,
      icon: icon,
      gradientColors: AppTheme.emotionalGradient,
      textColor: textColor,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }
}
