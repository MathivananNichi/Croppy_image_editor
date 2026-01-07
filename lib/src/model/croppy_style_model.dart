import 'package:flutter/material.dart';

import '../../croppy.dart';

class CroppyStyleModel {
  final Widget? backIcon;
  final Color? backGroundColor;
  final Color? bottomIconColor;
  final Widget? doneIcon;
  final Widget? resetIcon;
  final TextStyle? titleTextStyle;
  final String? titleText;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appbar;

  CroppyStyleModel({
    this.backIcon,
    this.backGroundColor,
    this.doneIcon,
    this.resetIcon,
    this.titleTextStyle,
    this.titleText,
    this.bottomNavigationBar,
    this.appbar,
    this.bottomIconColor,
  });
}

class CropUndoNode {
  final CroppableImageData data;
  final CropShapeType shape;

  CropUndoNode({
    required this.data,
    required this.shape,
  });
}
