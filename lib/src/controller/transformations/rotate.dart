import 'dart:math';

import 'package:croppy/src/src.dart';
import 'package:flutter/widgets.dart';

/// Provides methods for rotating the image.
mixin RotateTransformation on BaseCroppableImageController {
  /// Rotates the image counter-clockwise by 90 degrees.

  double _getSnappedAngle({
    required double currentRad,
    required bool clockwise,
  }) {
    final currentDeg = _normalizeDeg(_radToDeg(currentRad));

    final lower = (currentDeg ~/ 90) * 90;
    final upper = lower + 90;

    final targetDeg = clockwise
        ? (upper >= 360 ? 360 : upper)
        : lower;

    return _degToRad(targetDeg.toDouble());
  }
  double _radToDeg(double rad) => rad * 180 / pi;
  double _degToRad(double deg) => deg * pi / 180;

  double _normalizeDeg(double deg) {
    return (deg % 360 + 360) % 360;
  }

  bool _isExact90(double deg) => deg % 90 == 0;
  void onRotateCCW() {
    final currentDeg =
    _radToDeg(data.baseTransformations.rotationZ);

    final targetDeg = _nextRotationDeg(
      currentDeg: currentDeg,
      clockwise: false,
    );

    final targetRad = _degToRad(targetDeg);

    final newBaseTransformations =
    data.baseTransformations.copyWith(
      rotationZ: targetRad,
    );

    final transformation =
    getMatrixForBaseTransformations(newBaseTransformations);

    final newCropRect =
    data.cropRect.transform(transformation);

    onBaseTransformation(
      data.copyWith(
        cropRect: newCropRect,
        baseTransformations: newBaseTransformations,
      ),
    );
  }

  void onRotateACW() {
    final currentDeg =
    _radToDeg(data.baseTransformations.rotationZ);

    final targetDeg = _nextRotationDeg(
      currentDeg: currentDeg,
      clockwise: true,
    );

    final targetRad = _degToRad(targetDeg);

    final newBaseTransformations =
    data.baseTransformations.copyWith(
      rotationZ: targetRad,
    );

    final transformation =
    getMatrixForBaseTransformations(newBaseTransformations);

    final newCropRect =
    data.cropRect.transform(transformation);

    onBaseTransformation(
      data.copyWith(
        cropRect: newCropRect,
        baseTransformations: newBaseTransformations,
      ),
    );
  }


  double _nextRotationDeg({
    required double currentDeg,
    required bool clockwise,
  }) {
    final normalized = _normalizeDeg(currentDeg);

    if (_isExact90(normalized)) {
      // ✅ Normal step
      return clockwise
          ? normalized + 90
          : normalized - 90;
    } else {
      // ✅ Snap first
      final lower = (normalized ~/ 90) * 90;
      final upper = lower + 90;

      return (clockwise ? upper : lower).toDouble();
    }
  }
  void onRotateByAngle({
    double angleRad = pi / 2,
    RotateDirection? direction,
  }) {
    // Determine signed angle
    final double signedAngle = direction == null
        ? angleRad
        : direction == RotateDirection.right
            ? angleRad
            : -angleRad;

    final newBaseTransformations = data.baseTransformations.copyWith(
      rotationZ: data.baseTransformations.rotationZ + signedAngle,
    );

    final transformation = getMatrixForBaseTransformations(newBaseTransformations);

    final newCropRect = data.cropRect.transform(transformation);

    onBaseTransformation(
      data.copyWith(
        cropRect: newCropRect,
        baseTransformations: newBaseTransformations,
      ),
    );
  }

  /// The base rotation around Z axis of the image in radians.
  final baseRotationZNotifier = ValueNotifier(0.0);

  @override
  void recomputeValueNotifiers() {
    super.recomputeValueNotifiers();
    baseRotationZNotifier.value = data.baseTransformations.rotationZ;
  }

  @override
  void dispose() {
    baseRotationZNotifier.dispose();
    super.dispose();
  }
}
