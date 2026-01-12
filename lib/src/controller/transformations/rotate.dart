import 'dart:math';

import 'package:croppy/src/src.dart';
import 'package:flutter/widgets.dart';

/// Provides methods for rotating the image.
mixin RotateTransformation on BaseCroppableImageController {
  /// Rotates the image counter-clockwise by 90 degrees.

  double _radToDeg(double rad) => rad * 180 / pi;

  double _degToRad(double deg) => deg * pi / 180;

  void onRotateCCW() {
    final currentDeg = _radToDeg(data.baseTransformations.rotationZ);

    final targetDeg = currentDeg - 90; // 🔥 JUST ADD

    final targetRad = _degToRad(targetDeg);

    final newBaseTransformations = data.baseTransformations.copyWith(
      rotationZ: targetRad,
    );

    final transformation = getMatrixForBaseTransformations(newBaseTransformations);

    final newCropRect = data.cropRect.transform(transformation);

    onBaseTransformation(
      data.copyWith(
        cropRect: newCropRect,
        baseTransformations: newBaseTransformations,
      ),
    );
    updateRotationNotifier();
  }

  void onRotateACW() {
    final currentDeg = _radToDeg(data.baseTransformations.rotationZ);

    final targetDeg = currentDeg + 90; // 🔥 JUST ADD

    final targetRad = _degToRad(targetDeg);

    final newBaseTransformations = data.baseTransformations.copyWith(
      rotationZ: targetRad,
    );

    final transformation = getMatrixForBaseTransformations(newBaseTransformations);

    final newCropRect = data.cropRect.transform(transformation);

    onBaseTransformation(
      data.copyWith(
        cropRect: newCropRect,
        baseTransformations: newBaseTransformations,
      ),
    );
    updateRotationNotifier();
  }

  void onRotateByAngle({required double angleRad}) {
    final currentDeg = _radToDeg(data.baseTransformations.rotationZ);

    final targetDeg = currentDeg + angleRad;

    final targetRad = _degToRad(targetDeg);

    // 3️⃣ Build new base transformations
    final newBaseTransformations = data.baseTransformations.copyWith(
      rotationZ: targetRad,
    );

    // 4️⃣ Transform cropRect correctly
    final transformation = getMatrixForBaseTransformations(newBaseTransformations);

    final newCropRect = data.cropRect.transform(transformation);

    // 5️⃣ Commit
    onBaseTransformation(
      data.copyWith(
        cropRect: newCropRect,
        baseTransformations: newBaseTransformations,
      ),
    );
    updateRotationNotifier();
  }

  updateRotationNotifier() {
    Future.delayed(const Duration(milliseconds: 600)).then((_) {
      dataChangedNotifier.value = data;
    });
  }

  /// The base rotation around Z axis of the image in radians.
  final baseRotationZNotifier = ValueNotifier(0.0);
  ValueNotifier<CroppableImageData?> dataChangedNotifier = ValueNotifier(null);

  @override
  void recomputeValueNotifiers() {
    super.recomputeValueNotifiers();

    baseRotationZNotifier.value = data.baseTransformations.rotationZ;
  }

  @override
  void dispose() {
    baseRotationZNotifier.dispose();
    dataChangedNotifier.dispose();
    super.dispose();
  }
}
