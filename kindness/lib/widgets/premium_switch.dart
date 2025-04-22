import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Duration? animationDuration;
  final bool isDisabled;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final BoxShadow? shadow;
  final bool showRippleEffect;
  final VoidCallback? onTap;
  final String? tooltip;

  const PremiumSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.width,
    this.height,
    this.borderRadius,
    this.animationDuration,
    this.isDisabled = false,
    this.activeIcon,
    this.inactiveIcon,
    this.shadow,
    this.showRippleEffect = true,
    this.onTap,
    this.tooltip,
  });

  @override
  State<PremiumSwitch> createState() => _PremiumSwitchState();
}

class _PremiumSwitchState extends State<PremiumSwitch>
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

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PremiumSwitch oldWidget) {
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
    final switchWidth = widget.width ?? 50.0;
    final switchHeight = widget.height ?? 30.0;
    final borderRadius = widget.borderRadius ?? switchHeight / 2;
    final thumbSize = switchHeight - 4;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: switchWidth,
                height: switchHeight,
                decoration: BoxDecoration(
                  color: widget.value
                      ? (widget.activeColor ?? Theme.of(context).primaryColor)
                      : (widget.inactiveColor ?? Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    widget.shadow ??
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (widget.showRippleEffect && widget.value)
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleTap,
                            borderRadius: BorderRadius.circular(borderRadius),
                            child: Container(),
                          ),
                        ),
                      ),
                    AnimatedPositioned(
                      duration: widget.animationDuration ??
                          const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: widget.value ? switchWidth - thumbSize - 2 : 2,
                      top: 2,
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: widget.thumbColor ?? Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
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
                                ? (widget.activeIcon ?? const SizedBox())
                                : (widget.inactiveIcon ?? const SizedBox()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
