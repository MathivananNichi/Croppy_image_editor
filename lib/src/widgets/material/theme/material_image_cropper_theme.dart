import 'package:flutter/material.dart';

ThemeData generateMaterialImageCropperTheme(BuildContext context) {
  final outerTheme = Theme.of(context);

  return ThemeData.localize(
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: outerTheme.colorScheme.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: outerTheme.useMaterial3,
    ),
    outerTheme.textTheme,
  ).copyWith(scaffoldBackgroundColor: Colors.blue);
}
