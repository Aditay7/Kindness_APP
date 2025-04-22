import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final double? textFontSize;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  final bool isEnabled;

  const PremiumChip({
    Key? key,
    required this.label,
    this.avatar,
    this.trailing,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.selectedTextColor,
    this.textFontSize,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 8.0,
    ),
    this.showBorder = false,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isSelected
        ? (selectedColor ?? AppTheme.primaryColor)
        : (this.backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1));
    final textColor = isSelected
        ? (selectedTextColor ?? Colors.white)
        : (this.textColor ?? AppTheme.primaryColor);

    Widget chipContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: textColor,
                width: 1.0,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avatar != null) ...[
            avatar!,
            const SizedBox(width: 8.0),
          ],
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: textFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8.0),
            trailing!,
          ],
          if (onDeleted != null) ...[
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.close, size: 18.0),
              onPressed: onDeleted,
              color: textColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );

    if (animate) {
      chipContent = AnimationUtils.fadeSlideUp(
        child: chipContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    if (onTap != null && isEnabled) {
      chipContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: chipContent,
        ),
      );
    }

    return chipContent;
  }
}

class PremiumChipGroup extends StatelessWidget {
  final List<PremiumChip> chips;
  final bool wrap;
  final double spacing;
  final double runSpacing;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final double? textFontSize;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  final bool isEnabled;

  const PremiumChipGroup({
    Key? key,
    required this.chips,
    this.wrap = true,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.selectedTextColor,
    this.textFontSize,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 8.0,
    ),
    this.showBorder = false,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: chips.map((chip) {
          return PremiumChip(
            label: chip.label,
            avatar: chip.avatar,
            trailing: chip.trailing,
            onTap: chip.onTap,
            onDeleted: chip.onDeleted,
            isSelected: chip.isSelected,
            animate: animate,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
            borderRadius: borderRadius,
            backgroundColor: backgroundColor ?? chip.backgroundColor,
            selectedColor: selectedColor ?? chip.selectedColor,
            textColor: textColor ?? chip.textColor,
            selectedTextColor: selectedTextColor ?? chip.selectedTextColor,
            textFontSize: textFontSize ?? chip.textFontSize,
            padding: padding,
            showBorder: showBorder,
            isEnabled: isEnabled && chip.isEnabled,
          );
        }).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          return Padding(
            padding: EdgeInsets.only(
              right: spacing,
            ),
            child: PremiumChip(
              label: chip.label,
              avatar: chip.avatar,
              trailing: chip.trailing,
              onTap: chip.onTap,
              onDeleted: chip.onDeleted,
              isSelected: chip.isSelected,
              animate: animate,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              borderRadius: borderRadius,
              backgroundColor: backgroundColor ?? chip.backgroundColor,
              selectedColor: selectedColor ?? chip.selectedColor,
              textColor: textColor ?? chip.textColor,
              selectedTextColor: selectedTextColor ?? chip.selectedTextColor,
              textFontSize: textFontSize ?? chip.textFontSize,
              padding: padding,
              showBorder: showBorder,
              isEnabled: isEnabled && chip.isEnabled,
            ),
          );
        }).toList(),
      ),
    );
  }
}
