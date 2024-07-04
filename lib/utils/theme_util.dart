import 'package:flutter/material.dart';

import 'color_util.dart';

ThemeData themeData = ThemeData(
  colorSchemeSeed: CustomColors.midnightBlue,
  scaffoldBackgroundColor: CustomColors.dirtyWhite,
  appBarTheme: const AppBarTheme(
      actionsIconTheme: IconThemeData(color: CustomColors.midnightBlue),
      backgroundColor: CustomColors.dirtyWhite,
      toolbarHeight: 40),
  snackBarTheme:
      const SnackBarThemeData(backgroundColor: CustomColors.midnightBlue),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: CustomColors.tangerine)),
);
