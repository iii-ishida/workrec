import 'package:flutter/widgets.dart';

class SpacingUnit {
  static const small = 8.0;
  static const medium = 16.0;
}

class Sizes {
  static const padding = EdgeInsets.all(32.0);
  static const marginSmall = 8.0;
  static const marginMedium = SpacingUnit.medium;
  static const buttonPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
}

class ThemeColors {
  static const gray900 = Color.fromARGB(255, 28, 28, 30);
  static const gray800 = Color.fromARGB(255, 58, 58, 60);
  static const gray700 = Color.fromARGB(255, 72, 72, 74);
  static const gray600 = Color.fromARGB(255, 99, 99, 102);
  static const gray500 = Color.fromARGB(255, 142, 142, 147);
  static const gray400 = Color.fromARGB(255, 174, 174, 178);
  static const gray300 = Color.fromARGB(255, 207, 207, 211);
  static const gray200 = Color.fromARGB(255, 244, 244, 246);
  static const gray100 = Color.fromARGB(255, 249, 249, 251);
  static const primary900 = Color.fromARGB(255, 0, 15, 61);
  static const primary800 = Color.fromARGB(255, 8, 27, 84);
  static const primary700 = Color.fromARGB(255, 23, 46, 115);
  static const primary600 = Color.fromARGB(255, 38, 66, 151);
  static const primary500 = Color.fromARGB(255, 56, 88, 183);
  static const primary400 = Color.fromARGB(255, 127, 150, 225);
  static const primary300 = Color.fromARGB(255, 188, 203, 245);
  static const primary200 = Color.fromARGB(255, 221, 228, 254);
  static const primary100 = Color.fromARGB(255, 235, 240, 255);
}
