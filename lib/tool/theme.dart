import 'package:flutter/material.dart';

abstract class AppTheme {
  static List<BoxShadow> boxShadow = const [BoxShadow(color: Colors.black26, offset: Offset(3, 3), blurRadius: 10)];

  static BorderRadiusGeometry borderRadius = BorderRadius.circular(4);

  static Duration transitionDuration = const Duration(milliseconds: 500);
}
