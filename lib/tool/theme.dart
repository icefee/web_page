import 'package:flutter/material.dart';

abstract class AppTheme {
  static List<BoxShadow> boxShadow = const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 10)];

  static BorderRadiusGeometry borderRadius = BorderRadius.circular(4);

  static Duration transitionDuration = const Duration(milliseconds: 500);

  static double fontSize = 16.0;

  static TextStyle textStyle = TextStyle(fontSize: AppTheme.fontSize);
}
