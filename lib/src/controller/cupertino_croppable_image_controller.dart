import 'dart:async';
import 'dart:developer';

import 'package:croppy/src/src.dart';
import 'package:flutter/material.dart';

/// A croppable image controller that is similar to the iOS Photos app.
class CupertinoCroppableImageController extends CroppableImageControllerWithMixins
    with AnimatedControllerMixin, TransformationFrictionMixin {
  CupertinoCroppableImageController({
    required TickerProvider vsync,
    required super.data,
    this.onRotateCommitted,
    required super.imageProvider,
    super.postProcessFn,
    super.cropShapeFn,
    super.enabledTransformations,
    super.minimumCropDimension,
    List<CropAspectRatio?>? allowedAspectRatios,
  }) : allowedAspectRatios = allowedAspectRatios ?? _createDefaultAspectRatios(data.imageSize) {
    initAnimationControllers(vsync);
    maybeSetAspectRatioOnInit();
  }

  /// Allowed aspect ratios for the aspect ratio toolbar.
  @override
  final List<CropAspectRatio?> allowedAspectRatios;
  VoidCallback? onRotateCommitted;

  /// Whether the guide lines are visible.
  final guideLinesVisibility = ValueNotifier<bool>(false);
  final baseNotifier = ValueNotifier<CroppableImageData?>(null);
  final flipNotifier = ValueNotifier<bool?>(null);
  final toolbarNotifier = ValueNotifier<CupertinoCroppableImageToolbar>(
    CupertinoCroppableImageToolbar.transform,
  );
  bool _commandLocked = false;

  @override
  void onStraighten({
    required double angleRad,
  }) {
    if (isRotatingZ) {
      super.onStraighten(angleRad: angleRad);

      normalize();
      setViewportScale();
    } else {
      animatedNormalizeAfterTransform(
        () {
          super.onStraighten(angleRad: angleRad);
          normalize();
        },
      );
    }
// 🔥 ROTATION FINISHED
    onRotateCommitted?.call();
  }

  @override
  void onRotateX({
    required double angleRad,
  }) {
    log("-onRotateX");
    if (isRotatingX) {
      super.onRotateX(angleRad: angleRad);
      onRotateCommitted?.call();
      normalize();
      setViewportScale();
    } else {
      animatedNormalizeAfterTransform(
        () {
          super.onRotateX(angleRad: angleRad);
          onRotateCommitted?.call();
          normalize();
        },
      );
    }
  }

  @override
  void onRotateY({
    required double angleRad,
  }) {
    if (isRotatingY) {
      log("-onRotateX");
      super.onRotateY(angleRad: angleRad);
      normalize();
      setViewportScale();
    } else {
      animatedNormalizeAfterTransform(
        () {
          super.onRotateY(angleRad: angleRad);
          normalize();
        },
      );
    }
  }

  @override
  void onBaseTransformation(CroppableImageData newData) {
    super.onBaseTransformation(newData);

    // Aspect ratio & non-gesture changes
    if (!isTransforming) {
      baseNotifier.value = newData;
    }
  }
  Future<void> _runSafely(VoidCallback action) async {
    if (_commandLocked) return;

    _commandLocked = true;
    action();

    // Croppy flip animation duration (safe buffer)
    await Future.delayed(const Duration(milliseconds: 300));

    _commandLocked = false;
  }
  @override
  void onMirrorHorizontal() {
    _runSafely(() {
      super.onMirrorHorizontal();
    });
  }

  @override
  void onMirrorVertical() {
    _runSafely(() {
      super.onMirrorVertical();
    });
  }
  @override
  void onPanAndScale({
    required double scaleDelta,
    required Offset offsetDelta,
  }) {
    super.onPanAndScale(scaleDelta: scaleDelta, offsetDelta: offsetDelta);
    setViewportScale();
  }

  @override
  void onPanAndScaleEnd() {
    super.onPanAndScaleEnd();

    final normalizedRect = normalizeWithAnimation();
    setViewportScaleWithAnimation(overrideCropRect: normalizedRect);
  }

  @override
  void onResize({
    required Offset offsetDelta,
    required ResizeDirection direction,
  }) {
    super.onResize(offsetDelta: offsetDelta, direction: direction);

    computeStaticCropRectDuringResize();
    setStaticCropRectTweenEnd(staticCropRect);
    setViewportScale(overrideCropRect: staticCropRect);
  }

  @override
  void onResizeEnd() {
    super.onResizeEnd();
    normalizeWithAnimation();
    recomputeViewportScaleWithDelay();
  }

  @override
  void onTransformationStart() {
    super.onTransformationStart();

    if (_recomputeViewportScaleTimer?.isActive == true) {
      _recomputeViewportScaleTimer?.cancel();
      setViewportScaleWithAnimation();
    }

    showGuideLines();
  }

  @override
  void onTransformationEnd() {
    super.onTransformationEnd();

    maybeHideGuideLines();
  }

  Timer? _recomputeViewportScaleTimer;

  void recomputeViewportScaleWithDelay() {
    _recomputeViewportScaleTimer?.cancel();
    _recomputeViewportScaleTimer = Timer(
      const Duration(seconds: 1),
      setViewportScaleWithAnimation,
    );
  }

  Timer? _hideGuideLinesTimer;

  void showGuideLines() {
    _hideGuideLinesTimer?.cancel();
    guideLinesVisibility.value = true;
  }

  void maybeHideGuideLines() {
    _hideGuideLinesTimer?.cancel();
    _hideGuideLinesTimer = Timer(
      const Duration(seconds: 1),
      () => guideLinesVisibility.value = false,
    );
  }

  void toggleToolbar(CupertinoCroppableImageToolbar toolbar) {
    if (toolbarNotifier.value == toolbar) {
      toolbarNotifier.value = CupertinoCroppableImageToolbar.transform;
    } else {
      toolbarNotifier.value = toolbar;
    }
  }

  @override
  void dispose() {
    guideLinesVisibility.dispose();
    toolbarNotifier.dispose();
    _recomputeViewportScaleTimer?.cancel();
    _hideGuideLinesTimer?.cancel();

    super.dispose();
  }
}

enum CupertinoCroppableImageToolbar {
  transform,
  aspectRatio,
}

List<CropAspectRatio?> _createDefaultAspectRatios(Size imageSize) {
  return [
    CropAspectRatio(
      width: imageSize.width.round(),
      height: imageSize.height.round(),
    ),
    CropAspectRatio(
      width: imageSize.height.round(),
      height: imageSize.width.round(),
    ),
    null,
    ..._basicAspectRatios,
  ];
}

const _basicAspectRatios = [
  CropAspectRatio(width: 1, height: 1),
  CropAspectRatio(width: 16, height: 9),
  CropAspectRatio(width: 9, height: 16),
  CropAspectRatio(width: 4, height: 3),
  CropAspectRatio(width: 3, height: 4),
];
