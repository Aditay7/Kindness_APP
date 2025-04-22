import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumLoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 3.0,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<PremiumLoadingIndicator> createState() => _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _LoadingPainter(
                color: color,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _LoadingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw the main circle
    canvas.drawCircle(center, radius, paint);

    // Draw the loading arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      0.0,
      2.0,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PremiumLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double indicatorSize;
  final String? loadingText;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumLoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorSize = 40.0,
    this.loadingText,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: animationDuration,
            curve: animationCurve,
            child: Container(
              color: backgroundColor ?? Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumLoadingIndicator(
                      size: indicatorSize,
                      color: indicatorColor,
                      animate: animate,
                      animationDuration: animationDuration,
                      animationCurve: animationCurve,
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: 16.0),
                      Text(
                        loadingText!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
} 