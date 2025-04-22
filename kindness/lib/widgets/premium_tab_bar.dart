import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double? height;
  final double? indicatorHeight;
  final double? borderRadius;
  final Duration? animationDuration;
  final bool isDisabled;
  final BoxShadow? shadow;
  final bool showRippleEffect;
  final String? tooltip;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;
  final bool isScrollable;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showDivider;
  final Color? dividerColor;
  final double? dividerHeight;
  final bool showIndicator;
  final Color? indicatorColor;
  final double? indicatorWidth;
  final bool showLabel;
  final TextStyle? labelStyle;
  final bool showIcon;
  final double? iconSize;
  final bool showBadge;
  final Color? badgeColor;
  final double? badgeSize;
  final TextStyle? badgeTextStyle;

  const PremiumTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height,
    this.indicatorHeight,
    this.borderRadius,
    this.animationDuration,
    this.isDisabled = false,
    this.shadow,
    this.showRippleEffect = true,
    this.tooltip,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
    this.isScrollable = false,
    this.padding,
    this.margin,
    this.showDivider = false,
    this.dividerColor,
    this.dividerHeight,
    this.showIndicator = true,
    this.indicatorColor,
    this.indicatorWidth,
    this.showLabel = true,
    this.labelStyle,
    this.showIcon = true,
    this.iconSize,
    this.showBadge = false,
    this.badgeColor,
    this.badgeSize,
    this.badgeTextStyle,
  });

  @override
  State<PremiumTabBar> createState() => _PremiumTabBarState();
}

class _PremiumTabBarState extends State<PremiumTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 48.0;
    final indicatorHeight = widget.indicatorHeight ?? 3.0;
    final borderRadius = widget.borderRadius ?? 4.0;
    final iconSize = widget.iconSize ?? 24.0;
    final badgeSize = widget.badgeSize ?? 16.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: widget.shadow != null ? [widget.shadow!] : null,
              ),
              child: TabBar(
                controller: TabController(
                  length: widget.tabs.length,
                  vsync: this,
                  initialIndex: widget.selectedIndex,
                ),
                onTap: widget.isDisabled ? null : widget.onTap,
                isScrollable: widget.isScrollable,
                padding: widget.padding,
                indicatorColor:
                    widget.indicatorColor ?? Theme.of(context).primaryColor,
                indicatorWeight: indicatorHeight,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor:
                    widget.selectedColor ?? Theme.of(context).primaryColor,
                unselectedLabelColor: widget.unselectedColor ?? Colors.grey,
                labelStyle: widget.labelStyle,
                unselectedLabelStyle: widget.labelStyle,
                tabs: widget.tabs.map((tab) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showIcon && tab is Icon)
                          Icon(
                            tab.icon,
                            size: iconSize,
                            color: widget.selectedColor ??
                                Theme.of(context).primaryColor,
                          ),
                        if (widget.showLabel && tab is Text)
                          Text(
                            tab.data!,
                            style: widget.labelStyle,
                          ),
                        if (widget.showBadge)
                          Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              color: widget.badgeColor ??
                                  Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '!',
                                style: widget.badgeTextStyle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
