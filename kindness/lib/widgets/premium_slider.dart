import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double? height;
  final double? thumbSize;
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
  final int? divisions;
  final String? semanticLabel;
  final bool showValue;
  final TextStyle? valueStyle;

  const PremiumSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
    this.onChangeEnd,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.height,
    this.thumbSize,
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
    this.divisions,
    this.semanticLabel,
    this.showValue = false,
    this.valueStyle,
  });

  @override
  State<PremiumSlider> createState() => _PremiumSliderState();
}

class _PremiumSliderState extends State<PremiumSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _thumbAnimation;

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

    _thumbAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
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
  }

  @override
  Widget build(BuildContext context) {
    final sliderHeight = widget.height ?? 4.0;
    final thumbSize = widget.thumbSize ?? 24.0;
    final borderRadius = widget.borderRadius ?? sliderHeight / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
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
          const SizedBox(height: 8),
        ],
        Tooltip(
          message: widget.tooltip ?? '',
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: sliderHeight,
                      activeTrackColor:
                          widget.activeColor ?? Theme.of(context).primaryColor,
                      inactiveTrackColor:
                          widget.inactiveColor ?? Colors.grey.shade300,
                      thumbColor: widget.thumbColor ?? Colors.white,
                      overlayColor:
                          (widget.activeColor ?? Theme.of(context).primaryColor)
                              .withOpacity(0.1),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: thumbSize / 2,
                        elevation: 4,
                      ),
                      trackShape: RoundedRectSliderTrackShape(),
                      disabledThumbColor: Colors.grey.shade400,
                      disabledActiveTrackColor: Colors.grey.shade300,
                      disabledInactiveTrackColor: Colors.grey.shade200,
                    ),
                    child: Slider(
                      value: widget.value,
                      min: widget.min,
                      max: widget.max,
                      onChanged: widget.isDisabled ? null : widget.onChanged,
                      onChangeEnd:
                          widget.isDisabled ? null : widget.onChangeEnd,
                      divisions: widget.divisions,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.showValue) ...[
          const SizedBox(height: 4),
          Text(
            widget.value.toStringAsFixed(widget.divisions != null ? 1 : 0),
            style: widget.valueStyle ??
                TextStyle(
                  color: widget.isDisabled
                      ? Colors.grey.shade400
                      : Colors.grey.shade800,
                  fontSize: 14,
                ),
          ),
        ],
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
