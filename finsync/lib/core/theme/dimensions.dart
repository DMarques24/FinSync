import 'package:flutter/material.dart';


class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const double screenHorizontal = 20;


  static const double bottomNavClearance = 120;
}


class AppRadius {
  AppRadius._();

  static const double xs = 8;

  static const double sm = 12;

  static const double md = 16;

  static const double lg = 18;

  static const double xl = 24;

  static const double xxl = 28;

  static BorderRadius all(double radius) => BorderRadius.circular(radius);

  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}

class AppSizes {
  AppSizes._();

  
  static const double minTouchTarget = 48;

  static const double primaryButton = 56;

  static const double inputHeight = 56;
}
