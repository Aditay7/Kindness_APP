import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double borderRadius;
  final Duration animationDuration;
  final bool isDisabled;
  final bool showShadow;
  final bool showRippleEffect;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final bool showTitle;
  final TextStyle? titleStyle;
  final bool showSubtitle;
  final TextStyle? subtitleStyle;
  final bool showLeading;
  final bool showTrailing;
  final bool showBadge;
  final Color? badgeColor;
  final double badgeSize;
  final TextStyle? badgeTextStyle;
  final VoidCallback? onExpansionChanged;
  final VoidCallback? onLongPress;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.children,
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.borderRadius = 0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isDisabled = false,
    this.showShadow = true,
    this.showRippleEffect = true,
    this.showDivider = false,
    this.dividerColor,
    this.dividerHeight = 1,
    this.showTitle = true,
    this.titleStyle,
    this.showSubtitle = false,
    this.subtitleStyle,
    this.showLeading = true,
    this.showTrailing = true,
    this.showBadge = false,
    this.badgeColor,
    this.badgeSize = 16,
    this.badgeTextStyle,
    this.onExpansionChanged,
    this.onLongPress,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  });

  @override
  State<PremiumExpansionTile> createState() => _PremiumExpansionTileState();
}

class _PremiumExpansionTileState extends State<PremiumExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
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
    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isDisabled) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    widget.onExpansionChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: widget.backgroundColor ?? colorScheme.surface,
      elevation: widget.showShadow ? widget.elevation : 0,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _handleTap,
            onLongPress: widget.isDisabled ? null : widget.onLongPress,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.showLeading && widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showTitle)
                          DefaultTextStyle(
                            style: (widget.titleStyle ??
                                    theme.textTheme.titleMedium)!
                                .copyWith(
                              color: widget.foregroundColor ??
                                  colorScheme.onSurface,
                            ),
                            child: widget.title,
                          ),
                        if (widget.showSubtitle && widget.subtitle != null)
                          DefaultTextStyle(
                            style: (widget.subtitleStyle ??
                                    theme.textTheme.bodySmall)!
                                .copyWith(
                              color: widget.foregroundColor?.withOpacity(0.7) ??
                                  colorScheme.onSurface.withOpacity(0.7),
                            ),
                            child: widget.subtitle!,
                          ),
                      ],
                    ),
                  ),
                  if (widget.showTrailing && widget.trailing != null) ...[
                    widget.trailing!,
                    const SizedBox(width: 16),
                  ],
                  if (widget.showBadge)
                    Container(
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
                  if (widget.showTrailing)
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                      child: Icon(
                        Icons.expand_more,
                        color: widget.foregroundColor ?? colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.showDivider)
            Divider(
              color: widget.dividerColor ?? colorScheme.outlineVariant,
              height: widget.dividerHeight,
            ),
          SizeTransition(
            sizeFactor: _controller,
            child: Column(
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}
