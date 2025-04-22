import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final bool isSelected;
  final bool isEnabled;

  const PremiumListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.titleFontSize,
    this.subtitleFontSize,
    this.isSelected = false,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? theme.cardColor;
    final titleColor = this.titleColor ?? theme.textTheme.titleMedium?.color;
    final subtitleColor =
        this.subtitleColor ?? theme.textTheme.bodyMedium?.color;

    Widget listTileContent = Container(
      padding: contentPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontSize: titleFontSize,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16.0),
            trailing!,
          ],
        ],
      ),
    );

    if (animate) {
      listTileContent = AnimationUtils.fadeSlideUp(
        child: listTileContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: listTileContent,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.0,
            thickness: 1.0,
            color: theme.dividerColor,
          ),
      ],
    );
  }
}

class PremiumListTileGroup extends StatelessWidget {
  final List<PremiumListTile> tiles;
  final bool showDividers;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? titleFontSize;
  final double? subtitleFontSize;

  const PremiumListTileGroup({
    Key? key,
    required this.tiles,
    this.showDividers = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.titleFontSize,
    this.subtitleFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tiles.asMap().entries.map((entry) {
        final index = entry.key;
        final tile = entry.value;
        return PremiumListTile(
          title: tile.title,
          subtitle: tile.subtitle,
          leading: tile.leading,
          trailing: tile.trailing,
          onTap: tile.onTap,
          showDivider: showDividers && index < tiles.length - 1,
          animate: animate,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          contentPadding: contentPadding,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor ?? tile.backgroundColor,
          titleColor: titleColor ?? tile.titleColor,
          subtitleColor: subtitleColor ?? tile.subtitleColor,
          titleFontSize: titleFontSize ?? tile.titleFontSize,
          subtitleFontSize: subtitleFontSize ?? tile.subtitleFontSize,
          isSelected: tile.isSelected,
          isEnabled: tile.isEnabled,
        );
      }).toList(),
    );
  }
}
