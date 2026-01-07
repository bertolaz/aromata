// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Yellow palette
  static const yellow50 = Color(0xFFFFFDE7);
  static const yellow100 = Color(0xFFFFF9C4);
  static const yellow200 = Color(0xFFFFF59D);
  static const yellow300 = Color(0xFFFFF176);
  static const yellow400 = Color(0xFFFFEE58);
  static const yellow500 = Color(0xFFFFEB3B);
  static const yellow600 = Color(0xFFFDD835);
  static const yellow700 = Color(0xFFFBC02D);
  static const yellow800 = Color(0xFFF9A825);
  static const yellow900 = Color(0xFFF57F17);
  
  // Amber (warm yellow) palette
  static const amber50 = Color(0xFFFFF8E1);
  static const amber100 = Color(0xFFFFECB3);
  static const amber200 = Color(0xFFFFE082);
  static const amber300 = Color(0xFFFFD54F);
  static const amber400 = Color(0xFFFFCA28);
  static const amber500 = Color(0xFFFFC107);
  static const amber600 = Color(0xFFFFB300);
  static const amber700 = Color(0xFFFFA000);
  static const amber800 = Color(0xFFFF8F00);
  static const amber900 = Color(0xFFFF6F00);
  
  // Neutral colors
  static const black1 = Color(0xFF1A1A1A);
  static const white1 = Color(0xFFFFFEF9);
  static const grey1 = Color(0xFFF5F5F5);
  static const grey2 = Color(0xFF757575);
  static const grey3 = Color(0xFF9E9E9E);
  static const whiteTransparent = Color(0x4DFFFFFF);
  static const blackTransparent = Color(0x4D000000);
  static const red1 = Color(0xFFE74C3C);

  // Legacy aliases for backward compatibility
  static const yellow1 = amber500;
  static const yellow2 = yellow200;

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: amber600,
    onPrimary: black1,
    secondary: yellow400,
    onSecondary: black1,
    tertiary: amber300,
    onTertiary: black1,
    error: red1,
    onError: white1,
    surface: white1,
    onSurface: black1,
    outline: yellow700,
    outlineVariant: yellow200,
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: amber400,
    onPrimary: black1,
    secondary: yellow500,
    onSecondary: black1,
    tertiary: amber300,
    onTertiary: black1,
    error: red1,
    onError: white1,
    surface: black1,
    onSurface: yellow100,
    outline: amber600,
    outlineVariant: amber800,
  );
}
