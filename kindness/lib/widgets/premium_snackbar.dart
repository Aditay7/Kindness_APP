import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumSnackBar extends StatefulWidget {
  final String message;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final bool showCloseIcon;
  final VoidCallback? onDismissed;
  final bool isError;
  final bool isSuccess;
  final bool isWarning;
  final bool isInfo;
  final Duration? duration;
  final SnackBarBehavior? behavior;
  final VoidCallback? onVisible;

  const PremiumSnackBar({
    super.key,
    required this.message,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.margin,
    this.borderRadius,
    this.shadow,
    this.showCloseIcon = true,
    this.onDismissed,
    this.isError = false,
    this.isSuccess = false,
    this.isWarning = false,
    this.isInfo = false,
    this.duration,
    this.behavior,
    this.onVisible,
  });

  void show(BuildContext context) {
    final snackBar = SnackBar(
      content: this,
      elevation: elevation,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      behavior: behavior ?? SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 4),
      onVisible: onVisible,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  State<PremiumSnackBar> createState() => _PremiumSnackBarState();
}

class _PremiumSnackBarState extends State<PremiumSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.isError) return Theme.of(context).colorScheme.error;
    if (widget.isSuccess) return Colors.green;
    if (widget.isWarning) return Colors.orange;
    if (widget.isInfo) return Colors.blue;
    return widget.backgroundColor ?? Theme.of(context).primaryColor;
  }

  IconData _getLeadingIcon() {
    if (widget.isError) return Icons.error_outline;
    if (widget.isSuccess) return Icons.check_circle_outline;
    if (widget.isWarning) return Icons.warning_amber_outlined;
    if (widget.isInfo) return Icons.info_outline;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: widget.margin ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  widget.shadow ??
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (widget.leading != null)
                        widget.leading!
                      else
                        Icon(
                          _getLeadingIcon(),
                          color: widget.textColor ?? Colors.white,
                          size: 24,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: widget.textColor ?? Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.trailing != null) ...[
                        const SizedBox(width: 12),
                        widget.trailing!,
                      ],
                      if (widget.showCloseIcon) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: widget.textColor ?? Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            if (widget.onDismissed != null) {
                              widget.onDismissed!();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
