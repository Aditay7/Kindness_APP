import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCloseButton;
  final bool isDestructive;
  final Widget? icon;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? messageColor;
  final double? titleFontSize;
  final double? messageFontSize;

  const PremiumDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCloseButton = true,
    this.isDestructive = false,
    this.icon,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.contentPadding = const EdgeInsets.all(24.0),
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.titleColor,
    this.messageColor,
    this.titleFontSize,
    this.messageFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? theme.dialogBackgroundColor;
    final titleColor = this.titleColor ?? theme.textTheme.titleLarge?.color;
    final messageColor = this.messageColor ?? theme.textTheme.bodyLarge?.color;

    Widget dialogContent = Container(
      padding: contentPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCloseButton)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                color: theme.iconTheme.color,
              ),
            ),
          if (icon != null) ...[
            icon!,
            const SizedBox(height: 16.0),
          ],
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: titleColor,
              fontSize: titleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: messageColor,
              fontSize: messageFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cancelText != null)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    child: Text(cancelText!),
                  ),
                ),
              if (cancelText != null && confirmText != null)
                const SizedBox(width: 16.0),
              if (confirmText != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    child: Text(confirmText!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    if (animate) {
      dialogContent = AnimationUtils.fadeSlideUp(
        child: dialogContent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: dialogContent,
    );
  }
}

class PremiumSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumSuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumDialog(
      title: title,
      message: message,
      confirmText: confirmText ?? 'OK',
      onConfirm: onConfirm,
      icon: Icon(
        Icons.check_circle_outline,
        size: 48.0,
        color: AppTheme.successColor,
      ),
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }
}

class PremiumErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumDialog(
      title: title,
      message: message,
      confirmText: confirmText ?? 'OK',
      onConfirm: onConfirm,
      icon: Icon(
        Icons.error_outline,
        size: 48.0,
        color: AppTheme.errorColor,
      ),
      animate: animate,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }
}
