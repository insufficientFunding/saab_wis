import 'package:flutter/material.dart';
import 'package:saab_wis/extensions/context.dart';
import 'package:saab_wis/theme/theme.dart';

class ZoomWidget extends StatefulWidget {
  /// The widget that should be zoomed.
  final Widget zoomWidget;

  /// The minimal scale that is allowed for this widget to be zoomed to.
  final double minScaleEmbeddedView;

  /// The maximal scale that is allowed for this widget to be zoomed to.
  final double maxScaleEmbeddedView;

  /// min scale for the widget in fullscreen
  final double minScaleFullscreen;

  /// max scale for the widget in fullscreen
  final double maxScaleFullscreen;

  /// if not specified the [maxScaleFullscreen] is used
  final double? fullScreenDoubleTapZoomScale;

  /// provide custom hero animation tag and make sure every [ZoomWidget] in your subtree uses a different tag. otherwise the animation doesnt work
  final Object heroAnimationTag;

  /// Controls whether the full screen image will be closed once the widget is disposed.
  final bool closeFullScreenImageOnDispose;

  final double? width, height;
  final bool invertColors;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;

  const ZoomWidget({
    super.key,
    this.minScaleEmbeddedView = 1,
    this.maxScaleEmbeddedView = 4,
    this.minScaleFullscreen = 1,
    this.maxScaleFullscreen = 4,
    this.fullScreenDoubleTapZoomScale,
    this.closeFullScreenImageOnDispose = false,
    required this.heroAnimationTag,
    required this.zoomWidget,
    this.width,
    this.height,
    this.invertColors = false,
    this.borderRadius,
    this.shadows,
  });

  @override
  State<ZoomWidget> createState() => _ZoomWidgetState();
}

class _ZoomWidgetState extends State<ZoomWidget> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  late double _scale = widget.minScaleEmbeddedView;
  Animation<Matrix4>? _animation;
  OverlayEntry? _entry;
  Duration _opcaityBackgroundDuration = Duration.zero;
  bool _isFullScreenImageOpened = false;

  late NavigatorState _rootNavigator;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addListener(() => _transformationController.value = _animation!.value)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _removeOverlay();
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rootNavigator = Navigator.of(context, rootNavigator: true);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    _removeOverlay();
    _closeFullScreenImage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(),
        SizedBox(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: (widget.invertColors ? Colors.black : Colors.white).withOpacity(0.06),
              splashColor: (widget.invertColors ? Colors.black : Colors.white).withOpacity(0.12),
              onTap: _openImageFullscreen,
            ),
          ),
        )
      ],
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.width ?? double.infinity,
        maxHeight: widget.height ?? double.infinity,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  Widget _buildImage() {
    return InteractiveViewer(
      transformationController: _transformationController,
      panEnabled: false,
      clipBehavior: Clip.none,
      minScale: widget.minScaleEmbeddedView,
      maxScale: widget.maxScaleEmbeddedView,
      onInteractionStart: _showOverlay,
      onInteractionUpdate: _onInteractionUpdate,
      onInteractionEnd: (details) => _resetAnimation(),
      child: Hero(
        tag: widget.heroAnimationTag,
        child: widget.zoomWidget,
      ),
    );
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_entry != null) {
      _scale = details.scale;
      _entry?.markNeedsBuild();
    }
  }

  void _showOverlay(ScaleStartDetails details) {
    if (details.pointerCount > 1) {
      _removeOverlay();
      final RenderBox imageBox = context.findRenderObject() as RenderBox;
      final Offset imageOffset = imageBox.localToGlobal(Offset.zero);
      _entry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                duration: _opcaityBackgroundDuration,
                opacity: ((_scale - 1) / (widget.maxScaleEmbeddedView - 1)).clamp(0, 1).toDouble(),
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              left: imageOffset.dx,
              top: imageOffset.dy,
              width: imageBox.size.width,
              height: imageBox.size.height,
              child: _buildImage(),
            ),
          ],
        ),
      );

      final OverlayState overlay = Overlay.of(context);
      overlay.insert(_entry!);
    }
  }

  void _removeOverlay() {
    _opcaityBackgroundDuration = Duration.zero;
    _entry?.remove();
    _entry = null;
  }

  void _resetAnimation() {
    _opcaityBackgroundDuration = _animationController.duration ?? const Duration(milliseconds: 300);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward(from: 0);
  }

  Future<void> _openImageFullscreen() async {
    _isFullScreenImageOpened = true;
    await _rootNavigator.push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation1, animation2) => FadeTransition(
          opacity: animation1,
          child: _ZoomWidgetExpanded(
            zoomWidget: widget.zoomWidget is Image
                ? Image(
                    image: (widget.zoomWidget as Image).image,
                    fit: BoxFit.contain,
                  )
                : widget.zoomWidget,
            minScale: widget.minScaleFullscreen,
            maxScale: widget.maxScaleFullscreen,
            heroAnimationTag: widget.heroAnimationTag,
            fullScreenDoubleTapZoomScale: widget.fullScreenDoubleTapZoomScale,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
    _isFullScreenImageOpened = false;
  }

  void _closeFullScreenImage() {
    if (_isFullScreenImageOpened && _rootNavigator.canPop()) {
      _rootNavigator.pop();
    }
  }
}

class _ZoomWidgetExpanded extends StatefulWidget {
  final Widget zoomWidget;
  final double minScale;
  final double maxScale;
  final Object heroAnimationTag;
  final double? fullScreenDoubleTapZoomScale;
  const _ZoomWidgetExpanded({
    required this.zoomWidget,
    required this.minScale,
    required this.maxScale,
    required this.heroAnimationTag,
    this.fullScreenDoubleTapZoomScale,
  });

  @override
  State<_ZoomWidgetExpanded> createState() => _ImageZoomFullscreenState();
}

class _ImageZoomFullscreenState extends State<_ZoomWidgetExpanded> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  late double closingTreshold = MediaQuery.of(context).size.height /
      5; //the higher you set the last value the earlier the full screen gets closed

  Animation<Matrix4>? _animation;
  double _opacity = 1;
  double _imagePosition = 0;
  Duration _animationDuration = Duration.zero;
  Duration _opacityDuration = Duration.zero;
  late double _currentScale = widget.minScale;
  TapDownDetails? _doubleTapDownDetails;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => _transformationController.value = _animation!.value);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            duration: _opacityDuration,
            opacity: _opacity,
            child: Container(
              color: context.colorScheme.surface,
            ),
          ),
        ),
        AnimatedPositioned(
          duration: _animationDuration,
          top: _imagePosition,
          bottom: -_imagePosition,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: InteractiveViewer(
              constrained: true,
              transformationController: _transformationController,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              onInteractionStart: _onInteractionStart,
              onInteractionUpdate: _onInteractionUpdate,
              onInteractionEnd: _onInteractionEnd,
              child: GestureDetector(
                // need to have both methods, otherwise the zoom will be triggered before the second tap releases the screen
                onDoubleTapDown: (details) => _doubleTapDownDetails = details,
                onDoubleTap: _zoomInOut,
                child: Hero(
                  tag: widget.heroAnimationTag,
                  child: widget.zoomWidget,
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(50),
                  child: AnimatedOpacity(
                    duration: _opacityDuration,
                    opacity: _opacity,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.close,
                        color: AppTheme.tertiaryColor,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 12,
                          ),
                        ],
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _zoomInOut() {
    final Offset tapPosition = _doubleTapDownDetails!.localPosition;
    final double zoomScale = widget.fullScreenDoubleTapZoomScale ?? widget.maxScale;

    final double x = -tapPosition.dx * (zoomScale - 1);
    final double y = -tapPosition.dy * (zoomScale - 1);

    final Matrix4 zoomedMatrix = Matrix4.identity()
      ..translate(x, y)
      ..scale(zoomScale);

    final Matrix4 widgetMatrix = _transformationController.value.isIdentity() ? zoomedMatrix : Matrix4.identity();

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: widgetMatrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );

    _animationController.forward(from: 0);
    _currentScale = _transformationController.value.isIdentity() ? zoomScale : widget.minScale;
  }

  void _onInteractionStart(ScaleStartDetails details) {
    _animationDuration = Duration.zero;
    _opacityDuration = Duration.zero;
  }

  void _onInteractionEnd(ScaleEndDetails details) async {
    _currentScale = _transformationController.value.getMaxScaleOnAxis();
    setState(() {
      _animationDuration = const Duration(milliseconds: 300);
    });
    if (_imagePosition > closingTreshold) {
      setState(() {
        _imagePosition = MediaQuery.of(context).size.height; // move image down
      });
      Navigator.of(context).pop();
    } else {
      setState(() {
        _imagePosition = 0;
        _opacity = 1;
        _opacityDuration = const Duration(milliseconds: 300);
      });
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) async {
    // chose 1.05 because maybe the image was not fully zoomed back but it almost looks like that
    if (details.pointerCount == 1 && _currentScale <= 1.05) {
      setState(() {
        _imagePosition += details.focalPointDelta.dy;
        _opacity = (1 - (_imagePosition / closingTreshold)).clamp(0, 1).toDouble();
      });
    }
  }
}
