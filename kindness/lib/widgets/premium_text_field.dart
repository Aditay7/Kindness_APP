import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class PremiumTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? textColor;
  final double? labelFontSize;
  final double? hintFontSize;
  final double? textFontSize;

  const PremiumTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    this.borderRadius = 12.0,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.labelColor,
    this.hintColor,
    this.textColor,
    this.labelFontSize,
    this.hintFontSize,
    this.textFontSize,
  }) : super(key: key);

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillColor = widget.fillColor ?? theme.inputDecorationTheme.fillColor;
    final borderColor = widget.borderColor ?? theme.dividerColor;
    final focusedBorderColor =
        widget.focusedBorderColor ?? AppTheme.primaryColor;
    final errorBorderColor = widget.errorBorderColor ?? AppTheme.errorColor;
    final labelColor = widget.labelColor ?? theme.textTheme.bodyMedium?.color;
    final hintColor = widget.hintColor ?? theme.hintColor;
    final textColor = widget.textColor ?? theme.textTheme.bodyLarge?.color;

    Widget textField = TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontSize: widget.textFontSize,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: widget.contentPadding,
        filled: true,
        fillColor: fillColor,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: _isFocused ? focusedBorderColor : labelColor,
          fontSize: widget.labelFontSize,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: hintColor,
          fontSize: widget.hintFontSize,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: errorBorderColor, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: errorBorderColor, width: 2.0),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: errorBorderColor,
        ),
      ),
    );

    // Apply animation if enabled
    if (widget.animate) {
      textField = AnimationUtils.fadeSlideUp(
        child: textField,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }

    return Focus(
      onFocusChange: _handleFocusChange,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isFocused ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: textField,
      ),
    );
  }
}

class PremiumPasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? textColor;
  final double? labelFontSize;
  final double? hintFontSize;
  final double? textFontSize;

  const PremiumPasswordField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    this.borderRadius = 12.0,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.labelColor,
    this.hintColor,
    this.textColor,
    this.labelFontSize,
    this.hintFontSize,
    this.textFontSize,
  }) : super(key: key);

  @override
  State<PremiumPasswordField> createState() => _PremiumPasswordFieldState();
}

class _PremiumPasswordFieldState extends State<PremiumPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return PremiumTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).hintColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      animate: widget.animate,
      animationDuration: widget.animationDuration,
      animationCurve: widget.animationCurve,
      contentPadding: widget.contentPadding,
      borderRadius: widget.borderRadius,
      fillColor: widget.fillColor,
      borderColor: widget.borderColor,
      focusedBorderColor: widget.focusedBorderColor,
      errorBorderColor: widget.errorBorderColor,
      labelColor: widget.labelColor,
      hintColor: widget.hintColor,
      textColor: widget.textColor,
      labelFontSize: widget.labelFontSize,
      hintFontSize: widget.hintFontSize,
      textFontSize: widget.textFontSize,
    );
  }
}
