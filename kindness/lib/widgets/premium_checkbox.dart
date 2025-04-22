import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double? size;
  final double? borderRadius;
  final Duration? animationDuration;
  final bool isDisabled;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final BoxShadow? shadow;
  final bool showRippleEffect;
  final VoidCallback? onTap;
  final String? tooltip;
  final String? label;
  final TextStyle? labelStyle;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size,
    this.borderRadius,
    this.animationDuration,
    this.isDisabled = false,
    this.activeIcon,
    this.inactiveIcon,
    this.shadow,
    this.showRippleEffect = true,
    this.onTap,
    this.tooltip,
    this.label,
    this.labelStyle,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  });

  @override
  State<PremiumCheckbox> createState() => _PremiumCheckboxState();
}

class _PremiumCheckboxState extends State<PremiumCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PremiumCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isDisabled) return;

    if (widget.onTap != null) {
      widget.onTap!();
    }

    if (widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkboxSize = widget.size ?? 24.0;
    final borderRadius = widget.borderRadius ?? 4.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: widget.tooltip ?? '',
          child: GestureDetector(
            onTap: _handleTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: checkboxSize,
                        height: checkboxSize,
                        decoration: BoxDecoration(
                          color: widget.value
                              ? (widget.activeColor ??
                                  Theme.of(context).primaryColor)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(borderRadius),
                          border: Border.all(
                            color: widget.isError
                                ? Theme.of(context).colorScheme.error
                                : (widget.value
                                    ? (widget.activeColor ??
                                        Theme.of(context).primaryColor)
                                    : Colors.grey.shade400),
                            width: 2,
                          ),
                          boxShadow: [
                            widget.shadow ??
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: widget.animationDuration ??
                                const Duration(milliseconds: 200),
                            child: widget.value
                                ? (widget.activeIcon ??
                                    Icon(
                                      Icons.check,
                                      color: widget.checkColor ?? Colors.white,
                                      size: checkboxSize * 0.6,
                                    ))
                                : (widget.inactiveIcon ?? const SizedBox()),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (widget.label != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.label!,
                    style: widget.labelStyle ??
                        TextStyle(
                          color: widget.isDisabled
                              ? Colors.grey.shade400
                              : Colors.grey.shade800,
                          fontSize: 16,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.isError && widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: widget.errorTextStyle ??
                TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
          ),
        ],
      ],
    );
  }
}
