import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumRadio<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final Duration? animationDuration;
  final bool isDisabled;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final BoxShadow? shadow;
  final bool showRippleEffect;
  final String? label;
  final TextStyle? labelStyle;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.animationDuration,
    this.isDisabled = false,
    this.activeIcon,
    this.inactiveIcon,
    this.shadow,
    this.showRippleEffect = true,
    this.label,
    this.labelStyle,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  });

  @override
  State<PremiumRadio<T>> createState() => _PremiumRadioState<T>();
}

class _PremiumRadioState<T> extends State<PremiumRadio<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

    if (widget.value == widget.groupValue) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PremiumRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == widget.groupValue &&
        oldWidget.value != oldWidget.groupValue) {
      _controller.forward();
    } else if (widget.value != widget.groupValue &&
        oldWidget.value == oldWidget.groupValue) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isDisabled) return;
    if (widget.onChanged != null) {
      widget.onChanged!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radioSize = widget.size ?? 24.0;
    final isSelected = widget.value == widget.groupValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: Opacity(
            opacity: widget.isDisabled ? 0.5 : 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: radioSize,
                        height: radioSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isError
                                ? Theme.of(context).colorScheme.error
                                : (isSelected
                                    ? (widget.activeColor ??
                                        Theme.of(context).primaryColor)
                                    : (widget.inactiveColor ??
                                        Colors.grey.shade400)),
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
                            child: isSelected
                                ? (widget.activeIcon ??
                                    Container(
                                      width: radioSize * 0.5,
                                      height: radioSize * 0.5,
                                      decoration: BoxDecoration(
                                        color: widget.activeColor ??
                                            Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
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
