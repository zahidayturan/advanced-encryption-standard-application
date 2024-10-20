import 'package:aes/core/constants/colors.dart';
import 'package:flutter/material.dart';

AppColors colors = AppColors();
@immutable
class AppTheme {
  const AppTheme._();
  static ThemeData lightTheme = ThemeData(
      primaryColor: colors.grey,
      useMaterial3: false,
      fontFamily: "FontMedium",
      colorScheme: const ColorScheme.light().copyWith(
        secondary: colors.black,
          primaryContainer: colors.white,
      ),
      scaffoldBackgroundColor: colors.grey,
  );

  static ThemeData darkTheme = ThemeData(
      primaryColor: colors.black, //
      useMaterial3: false,
      fontFamily: "FontMedium",
      colorScheme: const ColorScheme.light().copyWith(
        secondary: colors.grey,
        primaryContainer: colors.blackLight,
      ),
      scaffoldBackgroundColor: colors.black,
  );
}