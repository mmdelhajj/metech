import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';

class BoxDecorations {
  static BoxDecoration buildBoxDecoration_1({double radius = 6.0}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: MyTheme.white,
    );
  }

  static BoxDecoration buildBoxDecorationWithShadow({double radius = 6.0}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: MyTheme.white,
      boxShadow: [
        BoxShadow(
          color: MyTheme.blackColour.withValues(alpha: .08),
          blurRadius: 20,
          spreadRadius: 0.0,
          offset: Offset(0.0, 10.0),
        ),
      ],
    );
  }

  static BoxDecoration buildCartCircularButtonDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      color: Color.fromRGBO(229, 241, 248, 1),
    );
  }

  static BoxDecoration buildCircularButtonDecoration_1() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(36.0),
      color: MyTheme.white.withValues(alpha: 0.80),
      boxShadow: [
        BoxShadow(
          color: MyTheme.blackColour.withValues(alpha: 0.08),
          blurRadius: 20,
          spreadRadius: 0.0,
          offset: Offset(0.0, 10.0),
        ),
      ],
    );
  }

  static BoxDecoration buildCircularButtonDecorationForProductDetails() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: MyTheme.white.withValues(alpha: 0.80),
      boxShadow: [
        BoxShadow(
          color: MyTheme.blackColour.withValues(alpha: 0.08),
          blurRadius: 20,
          spreadRadius: 0,
          offset: Offset(0.0, 10.0),
        ),
      ],
    );
  }
}
