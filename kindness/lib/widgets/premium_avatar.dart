import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textFontSize;
  final bool showGlow;
  final double glowIntensity;
  final double glowRadius;
  final double glowSpread;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showStatus;
  final bool isOnline;
  final double statusSize;
  final Color? onlineColor;
  final Color? offlineColor;
  final bool showShadow;
  final double elevation;
  final bool isEnabled;
  final Widget? child;
  final VoidCallback? onTap;
  final bool showLoading;
  final Color? loadingColor;
  final double loadingStrokeWidth;
  final bool showError;
  final Widget? errorWidget;
  final bool showPlaceholder;
  final Widget? placeholderWidget;
  final BoxFit fit;
  final EdgeInsetsGeometry margin;
  final bool showTooltip;
  final String? tooltipMessage;
  final bool showBadge;
  final String? badgeLabel;
  final Color? badgeColor;
  final double badgeSize;
  final Alignment badgeAlignment;
  final EdgeInsetsGeometry badgeMargin;

  const PremiumAvatar({
    Key? key,
    this.imageUrl,
    this.initials,
    this.size = 40.0,
    this.borderRadius = 20.0,
    this.backgroundColor,
    this.textColor,
    this.textFontSize,
    this.showGlow = false,
    this.glowIntensity = 0.5,
    this.glowRadius = 10.0,
    this.glowSpread = 2.0,
    this.showBorder = false,
    this.borderWidth = 1.0,
    this.borderColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.showStatus = false,
    this.isOnline = false,
    this.statusSize = 12.0,
    this.onlineColor,
    this.offlineColor,
    this.showShadow = true,
    this.elevation = 4.0,
    this.isEnabled = true,
    this.child,
    this.onTap,
    this.showLoading = false,
    this.loadingColor,
    this.loadingStrokeWidth = 2.0,
    this.showError = false,
    this.errorWidget,
    this.showPlaceholder = false,
    this.placeholderWidget,
    this.fit = BoxFit.cover,
    this.margin = EdgeInsets.zero,
    this.showTooltip = false,
    this.tooltipMessage,
    this.showBadge = false,
    this.badgeLabel,
    this.badgeColor,
    this.badgeSize = 16.0,
    this.badgeAlignment = Alignment.topRight,
    this.badgeMargin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? AppTheme.primaryColor;
    final textColor = this.textColor ?? Colors.white;
    final borderColor = this.borderColor ?? textColor;
    final onlineColor = this.onlineColor ?? Colors.green;
    final offlineColor = this.offlineColor ?? Colors.grey;
    final loadingColor = this.loadingColor ?? textColor;

    Widget avatarContent = Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: [
          if (showShadow)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation,
              offset: const Offset(0, 2),
            ),
          if (showGlow)
            BoxShadow(
              color: backgroundColor.withOpacity(glowIntensity),
              blurRadius: glowRadius,
              spreadRadius: glowSpread,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showLoading)
              Center(
                child: SizedBox(
                  width: size * 0.5,
                  height: size * 0.5,
                  child: CircularProgressIndicator(
                    strokeWidth: loadingStrokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  ),
                ),
              )
            else if (showError && errorWidget != null)
              errorWidget!
            else if (showPlaceholder && placeholderWidget != null)
              placeholderWidget!
            else if (imageUrl != null)
              Image.network(
                imageUrl!,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials(theme, textColor, textFontSize);
                },
              )
            else if (initials != null)
              _buildInitials(theme, textColor, textFontSize)
            else if (child != null)
              child!,
          ],
        ),
      ),
    );

    if (showStatus) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: statusSize,
              height: statusSize,
              decoration: BoxDecoration(
                color: isOnline ? onlineColor : offlineColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: backgroundColor,
                  width: borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: elevation,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (showBadge) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: badgeAlignment == Alignment.topRight ||
                    badgeAlignment == Alignment.bottomRight
                ? badgeMargin.resolve(TextDirection.ltr).right
                : null,
            left: badgeAlignment == Alignment.topLeft ||
                    badgeAlignment == Alignment.bottomLeft
                ? badgeMargin.resolve(TextDirection.ltr).left
                : null,
            top: badgeAlignment == Alignment.topRight ||
                    badgeAlignment == Alignment.topLeft
                ? badgeMargin.resolve(TextDirection.ltr).top
                : null,
            bottom: badgeAlignment == Alignment.bottomRight ||
                    badgeAlignment == Alignment.bottomLeft
                ? badgeMargin.resolve(TextDirection.ltr).bottom
                : null,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: badgeColor ?? AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: elevation,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: badgeLabel != null
                  ? Center(
                      child: Text(
                        badgeLabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontSize: badgeSize * 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      );
    }

    if (animate) {
      avatarContent = AnimationUtils.fadeSlideUp(
        child: avatarContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    if (!isEnabled) {
      avatarContent = Opacity(
        opacity: 0.5,
        child: avatarContent,
      );
    }

    if (onTap != null) {
      avatarContent = GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    if (showTooltip && tooltipMessage != null) {
      avatarContent = Tooltip(
        message: tooltipMessage!,
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildInitials(
      ThemeData theme, Color textColor, double? textFontSize) {
    return Center(
      child: Text(
        initials!,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor,
          fontSize: textFontSize ?? size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PremiumAvatarGroup extends StatelessWidget {
  final List<PremiumAvatar> avatars;
  final double spacing;
  final double maxWidth;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showOverflow;
  final int maxDisplay;
  final double overflowSize;
  final Color? overflowColor;
  final Color? overflowTextColor;
  final double? overflowTextFontSize;
  final bool showTooltip;
  final String? overflowTooltipMessage;
  final bool showShadow;
  final double elevation;
  final bool isEnabled;

  const PremiumAvatarGroup({
    Key? key,
    required this.avatars,
    this.spacing = 8.0,
    this.maxWidth = double.infinity,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.showOverflow = true,
    this.maxDisplay = 3,
    this.overflowSize = 40.0,
    this.overflowColor,
    this.overflowTextColor,
    this.overflowTextFontSize,
    this.showTooltip = true,
    this.overflowTooltipMessage,
    this.showShadow = true,
    this.elevation = 4.0,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overflowColor = this.overflowColor ?? AppTheme.primaryColor;
    final overflowTextColor = this.overflowTextColor ?? Colors.white;

    final displayAvatars = avatars.take(maxDisplay).toList();
    final overflowCount = avatars.length - maxDisplay;

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...displayAvatars.asMap().entries.map((entry) {
            final index = entry.key;
            final avatar = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                right: index < displayAvatars.length - 1 ? spacing : 0,
              ),
              child: avatar,
            );
          }),
          if (showOverflow && overflowCount > 0)
            PremiumAvatar(
              initials: '+$overflowCount',
              size: overflowSize,
              backgroundColor: overflowColor,
              textColor: overflowTextColor,
              textFontSize: overflowTextFontSize,
              animate: animate,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              showShadow: showShadow,
              elevation: elevation,
              isEnabled: isEnabled,
              showTooltip: showTooltip,
              tooltipMessage:
                  overflowTooltipMessage ?? 'Show $overflowCount more',
            ),
        ],
      ),
    );
  }
}
