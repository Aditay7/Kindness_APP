import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumDrawer extends StatefulWidget {
  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? width;
  final BorderRadius? borderRadius;
  final Duration? animationDuration;
  final bool isDisabled;
  final BoxShadow? shadow;
  final bool showRippleEffect;
  final bool showHeader;
  final bool showFooter;
  final bool showLogo;
  final String? logoUrl;
  final double? logoSize;
  final bool showTitle;
  final String? title;
  final TextStyle? titleStyle;
  final bool showSubtitle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final bool showProfile;
  final String? profileName;
  final String? profileEmail;
  final String? profileImage;
  final double? profileImageSize;
  final VoidCallback? onProfilePressed;
  final bool showBadge;
  final Color? badgeColor;
  final double? badgeSize;
  final TextStyle? badgeTextStyle;
  final VoidCallback? onBadgePressed;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumDrawer({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.width,
    this.borderRadius,
    this.animationDuration,
    this.isDisabled = false,
    this.shadow,
    this.showRippleEffect = true,
    this.showHeader = true,
    this.showFooter = true,
    this.showLogo = true,
    this.logoUrl,
    this.logoSize,
    this.showTitle = true,
    this.title,
    this.titleStyle,
    this.showSubtitle = true,
    this.subtitle,
    this.subtitleStyle,
    this.showProfile = true,
    this.profileName,
    this.profileEmail,
    this.profileImage,
    this.profileImageSize = 48.0,
    this.onProfilePressed,
    this.showBadge = false,
    this.badgeColor,
    this.badgeSize = 16.0,
    this.badgeTextStyle,
    this.onBadgePressed,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  });

  @override
  State<PremiumDrawer> createState() => _PremiumDrawerState();
}

class _PremiumDrawerState extends State<PremiumDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
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

  Widget _buildLogo(ColorScheme colorScheme) {
    if (!widget.showLogo || widget.logoUrl == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Image.network(
        widget.logoUrl!,
        width: widget.logoSize,
        height: widget.logoSize,
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    if (!widget.showTitle || widget.title == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title!,
            style: (widget.titleStyle ?? Theme.of(context).textTheme.titleLarge)
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

  Widget _buildProfile(ColorScheme colorScheme) {
    if (!widget.showProfile) return const SizedBox();

    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onProfilePressed,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.profileImage != null)
              Container(
                width: widget.profileImageSize,
                height: widget.profileImageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(widget.profileImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              CircleAvatar(
                radius: widget.profileImageSize! / 2,
                backgroundColor: colorScheme.primary,
                child: Text(
                  widget.profileName?[0] ?? 'U',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.profileName != null)
                    Text(
                      widget.profileName!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                widget.foregroundColor ?? colorScheme.onSurface,
                          ),
                    ),
                  if (widget.profileEmail != null)
                    Text(
                      widget.profileEmail!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.foregroundColor?.withOpacity(0.7) ??
                                colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                ],
              ),
            ),
            if (widget.showBadge)
              GestureDetector(
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Drawer(
              backgroundColor: widget.backgroundColor ?? Colors.white,
              elevation: widget.elevation ?? 16,
              width: widget.width,
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
              ),
              child: Column(
                children: [
                  if (widget.showHeader && widget.header != null)
                    widget.header!
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(colorScheme),
                        _buildTitle(colorScheme),
                        _buildProfile(colorScheme),
                      ],
                    ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: widget.children,
                    ),
                  ),
                  if (widget.showFooter && widget.footer != null)
                    widget.footer!,
                  if (widget.isError && widget.errorText != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.errorText!,
                        style: widget.errorTextStyle ??
                            TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
