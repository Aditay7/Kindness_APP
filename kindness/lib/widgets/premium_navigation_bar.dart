import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumNavigationBar extends StatefulWidget {
  final List<Widget> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double height;
  final double borderRadius;
  final Duration animationDuration;
  final bool isDisabled;
  final bool showShadow;
  final bool showRippleEffect;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final bool showLabel;
  final TextStyle? labelStyle;
  final bool showIcon;
  final double iconSize;
  final bool showBadge;
  final Color? badgeColor;
  final double badgeSize;
  final TextStyle? badgeTextStyle;
  final VoidCallback? onLongPress;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height = 56,
    this.borderRadius = 0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isDisabled = false,
    this.showShadow = true,
    this.showRippleEffect = true,
    this.showDivider = false,
    this.dividerColor,
    this.dividerHeight = 1,
    this.showLabel = true,
    this.labelStyle,
    this.showIcon = true,
    this.iconSize = 24,
    this.showBadge = false,
    this.badgeColor,
    this.badgeSize = 16,
    this.badgeTextStyle,
    this.onLongPress,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  });

  @override
  State<PremiumNavigationBar> createState() => _PremiumNavigationBarState();
}

class _PremiumNavigationBarState extends State<PremiumNavigationBar>
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
      color: widget.backgroundColor ?? colorScheme.surface,
      elevation: widget.showShadow ? 8 : 0,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.borderRadius),
            topRight: Radius.circular(widget.borderRadius),
          ),
          boxShadow: widget.showShadow
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showDivider)
              Divider(
                color: widget.dividerColor ?? colorScheme.outlineVariant,
                height: widget.dividerHeight,
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  widget.items.length,
                  (index) => _buildNavigationItem(
                    context,
                    index,
                    colorScheme,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
      BuildContext context, int index, ColorScheme colorScheme) {
    final isSelected = index == widget.selectedIndex;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.isDisabled ? null : () => widget.onTap(index),
      onLongPress: widget.isDisabled ? null : widget.onLongPress,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.selectedColor ?? colorScheme.primary).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon)
              IconTheme(
                data: IconThemeData(
                  color: isSelected
                      ? widget.selectedColor ?? colorScheme.primary
                      : widget.unselectedColor ??
                          colorScheme.onSurface.withOpacity(0.7),
                  size: widget.iconSize,
                ),
                child: widget.items[index],
              ),
            if (widget.showLabel)
              Text(
                'Item ${index + 1}',
                style:
                    (widget.labelStyle ?? theme.textTheme.labelSmall)?.copyWith(
                  color: isSelected
                      ? widget.selectedColor ?? colorScheme.primary
                      : widget.unselectedColor ??
                          colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
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
                    style: (widget.badgeTextStyle ?? theme.textTheme.labelSmall)
                        ?.copyWith(
                      color: colorScheme.onError,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
