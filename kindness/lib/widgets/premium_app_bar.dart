import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumAppBar extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double height;
  final double borderRadius;
  final Duration animationDuration;
  final bool isDisabled;
  final bool showShadow;
  final bool showRippleEffect;
  final bool showBackButton;
  final bool showMenuButton;
  final bool showSearchButton;
  final bool showNotificationButton;
  final bool showProfileButton;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final bool showTitle;
  final TextStyle? titleStyle;
  final bool showSubtitle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final bool showLogo;
  final Widget? logo;
  final double logoSize;
  final bool showBadge;
  final Color? badgeColor;
  final double badgeSize;
  final TextStyle? badgeTextStyle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onTitlePressed;
  final VoidCallback? onLogoPressed;
  final VoidCallback? onBadgePressed;
  final VoidCallback? onLongPress;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.height = 56,
    this.borderRadius = 0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isDisabled = false,
    this.showShadow = true,
    this.showRippleEffect = true,
    this.showBackButton = true,
    this.showMenuButton = false,
    this.showSearchButton = false,
    this.showNotificationButton = false,
    this.showProfileButton = false,
    this.showDivider = false,
    this.dividerColor,
    this.dividerHeight = 1,
    this.showTitle = true,
    this.titleStyle,
    this.showSubtitle = false,
    this.subtitle,
    this.subtitleStyle,
    this.showLogo = false,
    this.logo,
    this.logoSize = 32,
    this.showBadge = false,
    this.badgeColor,
    this.badgeSize = 16,
    this.badgeTextStyle,
    this.onBackPressed,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.onTitlePressed,
    this.onLogoPressed,
    this.onBadgePressed,
    this.onLongPress,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  });

  @override
  State<PremiumAppBar> createState() => _PremiumAppBarState();
}

class _PremiumAppBarState extends State<PremiumAppBar>
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
      elevation: widget.showShadow ? widget.elevation : 0,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colorScheme.surface,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(widget.borderRadius),
            bottomRight: Radius.circular(widget.borderRadius),
          ),
          boxShadow: widget.showShadow
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (widget.showBackButton && widget.leading == null)
                    _buildBackButton(colorScheme)
                  else if (widget.leading != null)
                    widget.leading!,
                  if (widget.showLogo && widget.logo != null)
                    _buildLogo(colorScheme),
                  if (widget.showTitle)
                    Expanded(
                      child: _buildTitle(colorScheme),
                    ),
                  if (widget.actions != null) ...widget.actions!,
                  if (widget.showMenuButton) _buildMenuButton(colorScheme),
                  if (widget.showSearchButton) _buildSearchButton(colorScheme),
                  if (widget.showNotificationButton)
                    _buildNotificationButton(colorScheme),
                  if (widget.showProfileButton)
                    _buildProfileButton(colorScheme),
                ],
              ),
            ),
            if (widget.showDivider)
              Divider(
                color: widget.dividerColor ?? colorScheme.outlineVariant,
                height: widget.dividerHeight,
              ),
            if (widget.bottom != null) widget.bottom!,
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: widget.foregroundColor ?? colorScheme.onSurface,
      ),
      onPressed: widget.isDisabled
          ? null
          : widget.onBackPressed ?? () => Navigator.pop(context),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onLogoPressed,
      child: Container(
        width: widget.logoSize,
        height: widget.logoSize,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: widget.logo,
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTitlePressed,
      onLongPress: widget.isDisabled ? null : widget.onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle)
            Text(
              widget.title,
              style:
                  (widget.titleStyle ?? Theme.of(context).textTheme.titleLarge)
                      ?.copyWith(
                color: widget.foregroundColor ?? colorScheme.onSurface,
              ),
            ),
          if (widget.showSubtitle && widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: (widget.subtitleStyle ??
                      Theme.of(context).textTheme.bodySmall)
                  ?.copyWith(
                color: widget.foregroundColor?.withOpacity(0.7) ??
                    colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        Icons.menu,
        color: widget.foregroundColor ?? colorScheme.onSurface,
      ),
      onPressed: widget.isDisabled ? null : widget.onMenuPressed,
    );
  }

  Widget _buildSearchButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        Icons.search,
        color: widget.foregroundColor ?? colorScheme.onSurface,
      ),
      onPressed: widget.isDisabled ? null : widget.onSearchPressed,
    );
  }

  Widget _buildNotificationButton(ColorScheme colorScheme) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: widget.foregroundColor ?? colorScheme.onSurface,
          ),
          onPressed: widget.isDisabled ? null : widget.onNotificationPressed,
        ),
        if (widget.showBadge)
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: widget.isDisabled ? null : widget.onBadgePressed,
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
                            Theme.of(context).textTheme.labelSmall)
                        ?.copyWith(
                      color: colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        Icons.person,
        color: widget.foregroundColor ?? colorScheme.onSurface,
      ),
      onPressed: widget.isDisabled ? null : widget.onProfilePressed,
    );
  }
}
