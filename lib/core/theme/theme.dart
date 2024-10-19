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
      scaffoldBackgroundColor: colors.grey,
  );

  static ThemeData darkTheme = ThemeData(
      primaryColor: colors.black, //
      useMaterial3: false,
      fontFamily: "FontMedium",
      scaffoldBackgroundColor: colors.black,
  );
}