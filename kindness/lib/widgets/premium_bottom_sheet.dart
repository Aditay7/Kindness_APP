import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showCloseButton;
  final bool isScrollControlled;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? titleFontSize;
  final double? maxHeight;
  final double? minHeight;

  const PremiumBottomSheet({
    Key? key,
    required this.child,
    this.title,
    this.showCloseButton = true,
    this.isScrollControlled = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.contentPadding = const EdgeInsets.all(24.0),
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.titleColor,
    this.titleFontSize,
    this.maxHeight,
    this.minHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor =
        this.backgroundColor ?? theme.bottomSheetTheme.backgroundColor;
    final titleColor = this.titleColor ?? theme.textTheme.titleLarge?.color;

    Widget bottomSheetContent = Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
        minHeight: minHeight ?? 0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || showCloseButton)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: titleColor,
                          fontSize: titleFontSize,
                        ),
                      ),
                    ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: theme.iconTheme.color,
                    ),
                ],
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: contentPadding,
              child: child,
            ),
          ),
        ],
      ),
    );

    if (animate) {
      bottomSheetContent = AnimationUtils.fadeSlideUp(
        child: bottomSheetContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    return bottomSheetContent;
  }
}

class PremiumBottomSheetHelper {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showCloseButton = true,
    bool isScrollControlled = true,
    bool animate = true,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeOutCubic,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(24.0),
    double borderRadius = 16.0,
    Color? backgroundColor,
    Color? titleColor,
    double? titleFontSize,
    double? maxHeight,
    double? minHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      builder: (context) => PremiumBottomSheet(
        child: child,
        title: title,
        showCloseButton: showCloseButton,
        isScrollControlled: isScrollControlled,
        animate: animate,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        contentPadding: contentPadding,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        titleColor: titleColor,
        titleFontSize: titleFontSize,
        maxHeight: maxHeight,
        minHeight: minHeight,
      ),
    );
  }
}
