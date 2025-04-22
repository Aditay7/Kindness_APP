import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Duration animationDuration;
  final bool showShadow;
  final bool showRippleEffect;
  final bool showLoadingIndicator;
  final bool showErrorIcon;
  final bool showRetryButton;
  final bool showZoomButton;
  final bool showDownloadButton;
  final bool showShareButton;
  final bool showFavoriteButton;
  final String? caption;
  final TextStyle? captionStyle;
  final Widget? overlay;
  final Border? border;
  final Gradient? gradient;
  final double? opacity;
  final double? blurRadius;
  final double? scale;
  final double? rotation;
  final Offset? offset;
  final bool showTooltip;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onZoom;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final VoidCallback? onRetry;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showShadow = true,
    this.showRippleEffect = true,
    this.showLoadingIndicator = true,
    this.showErrorIcon = true,
    this.showRetryButton = true,
    this.showZoomButton = true,
    this.showDownloadButton = true,
    this.showShareButton = true,
    this.showFavoriteButton = true,
    this.caption,
    this.captionStyle,
    this.overlay,
    this.border,
    this.gradient,
    this.opacity,
    this.blurRadius,
    this.scale,
    this.rotation,
    this.offset,
    this.showTooltip = true,
    this.tooltip,
    this.onTap,
    this.onLongPress,
    this.onZoom,
    this.onDownload,
    this.onShare,
    this.onFavorite,
    this.onRetry,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  }) : super(key: key);

  @override
  State<PremiumImage> createState() => _PremiumImageState();
}

class _PremiumImageState extends State<PremiumImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
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

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    }
  }

  void _handleZoom() {
    if (widget.onZoom != null) {
      widget.onZoom!();
    }
  }

  void _handleDownload() {
    if (widget.onDownload != null) {
      widget.onDownload!();
    }
  }

  void _handleShare() {
    if (widget.onShare != null) {
      widget.onShare!();
    }
  }

  void _handleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (widget.onFavorite != null) {
      widget.onFavorite!();
    }
  }

  void _handleRetry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    if (widget.onRetry != null) {
      widget.onRetry!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Colors.transparent,
                    borderRadius: widget.borderRadius,
                    border: widget.border,
                    gradient: widget.gradient,
                    boxShadow: widget.showShadow
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (_hasError)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.showErrorIcon)
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                              if (widget.errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    widget.errorText!,
                                    style: widget.errorTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              if (widget.showRetryButton)
                                TextButton(
                                  onPressed: _handleRetry,
                                  child: const Text('Retry'),
                                ),
                            ],
                          ),
                        )
                      else
                        Image.network(
                          widget.imageUrl,
                          width: widget.width,
                          height: widget.height,
                          fit: widget.fit,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              _isLoading = false;
                              return child;
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            _isLoading = false;
                            _hasError = true;
                            return const SizedBox();
                          },
                        ),
                      if (widget.overlay != null)
                        Positioned.fill(
                          child: widget.overlay!,
                        ),
                      if (widget.caption != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              widget.caption!,
                              style: widget.captionStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      if (widget.showZoomButton ||
                          widget.showDownloadButton ||
                          widget.showShareButton ||
                          widget.showFavoriteButton)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.showZoomButton)
                                IconButton(
                                  icon: const Icon(Icons.zoom_in),
                                  onPressed: _handleZoom,
                                  color: Colors.white,
                                ),
                              if (widget.showDownloadButton)
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: _handleDownload,
                                  color: Colors.white,
                                ),
                              if (widget.showShareButton)
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: _handleShare,
                                  color: Colors.white,
                                ),
                              if (widget.showFavoriteButton)
                                IconButton(
                                  icon: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        _isFavorite ? Colors.red : Colors.white,
                                  ),
                                  onPressed: _handleFavorite,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
