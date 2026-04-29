// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ThemeData lightMode = ThemeData();

class MyTheme {
  /*configurable colors stars*/
  static Color mainColor = const Color(0xffF2F1F6);
  static const Color accent_color = Color(0xff2196F3);
  static const Color accent_color_shadow = Color.fromRGBO(
    229,
    65,
    28,
    .40,
  ); // this color is a dropshadow of
  static Color soft_accent_color = Color.fromRGBO(254, 234, 209, 1);
  static Color splash_screen_color = Color(0xff2196F3);
  static Color price_color = Colors.black;
  static Color blackColour=Colors.black;

  /*configurable colors ends*/
  /*If you are not a developer, do not change the bottom colors*/
  // These were `const` originally — made non-const so dark mode can swap them.
  static Color white = const Color.fromRGBO(255, 255, 255, 1);
  static Color noColor = Color.fromRGBO(255, 255, 255, 0);
  static Color light_grey = Color.fromRGBO(239, 239, 239, 1);
  static Color dark_grey = Color.fromRGBO(107, 115, 119, 1);
  static Color medium_grey = Color.fromRGBO(167, 175, 179, 1);
  static Color blue_grey = Color.fromRGBO(168, 175, 179, 1);
  static Color medium_grey_50 = Color.fromRGBO(167, 175, 179, .5);
  static Color grey_153 = const Color.fromRGBO(153, 153, 153, 1);
  static Color dark_font_grey = Color.fromRGBO(62, 68, 71, 1);
  static Color font_grey = const Color.fromRGBO(107, 115, 119, 1);
  // Kept const because it's used as a default constructor parameter elsewhere.
  static const Color textfield_grey = Color.fromRGBO(209, 209, 209, 1);
  static Color font_grey_Light = const Color(0xff6B7377);

  /// Switch all theme-aware colors to match the given brightness.
  /// Call BEFORE the app rebuilds (e.g. before Phoenix.rebirth).
  static void applyMode(Brightness brightness) {
    if (brightness == Brightness.dark) {
      mainColor = const Color(0xFF121212);
      white = const Color(0xFF1E1E1E);
      light_grey = const Color(0xFF2A2A2A);
      dark_grey = const Color(0xFFE0E0E0);
      medium_grey = const Color(0xFFB0B0B0);
      blue_grey = const Color(0xFFA8A8A8);
      medium_grey_50 = const Color(0x80B0B0B0);
      grey_153 = const Color(0xFFD0D0D0);
      dark_font_grey = const Color(0xFFEDEDED);
      font_grey = const Color(0xFFC8C8C8);
      font_grey_Light = const Color(0xFFB8B8B8);
      price_color = Colors.white;
      blackColour = Colors.white;
      shimmer_base = const Color(0xFF2A2A2A);
      shimmer_highlighted = const Color(0xFF3A3A3A);
      black_shadow = Colors.black.withValues(alpha: .50);
      // Splash always brand blue (branding moment), regardless of mode.
      splash_screen_color = const Color(0xff2196F3);
    } else {
      mainColor = const Color(0xffF2F1F6);
      white = const Color.fromRGBO(255, 255, 255, 1);
      light_grey = const Color.fromRGBO(239, 239, 239, 1);
      dark_grey = const Color.fromRGBO(107, 115, 119, 1);
      medium_grey = const Color.fromRGBO(167, 175, 179, 1);
      blue_grey = const Color.fromRGBO(168, 175, 179, 1);
      medium_grey_50 = const Color.fromRGBO(167, 175, 179, .5);
      grey_153 = const Color.fromRGBO(153, 153, 153, 1);
      dark_font_grey = const Color.fromRGBO(62, 68, 71, 1);
      font_grey = const Color.fromRGBO(107, 115, 119, 1);
      font_grey_Light = const Color(0xff6B7377);
      price_color = Colors.black;
      blackColour = Colors.black;
      shimmer_base = Colors.grey.shade50;
      shimmer_highlighted = Colors.grey.shade200;
      black_shadow = Colors.black.withValues(alpha: .15);
      splash_screen_color = const Color(0xff2196F3);
    }
  }
  static Color golden = Color.fromRGBO(255, 168, 0, 1);
  static Color amber = Color.fromRGBO(254, 234, 209, 1);
  static Color amber_medium = Color.fromRGBO(254, 240, 215, 1);
  static Color golden_shadow = Color(0xff2196F3).withValues(alpha: .15);
  static Color black_shadow = Colors.black.withValues(alpha: .15);
  static Color green = Colors.green;
  static Color? green_light = Colors.green[200];
  static Color shimmer_base = Colors.grey.shade50;
  static Color shimmer_highlighted = Colors.grey.shade200;
  //testing shimmer
  /*static Color shimmer_base = Colors.redAccent;
  static Color shimmer_highlighted = Colors.yellow;*/

  // gradient color for coupons
  static const Color gigas = Color.fromRGBO(95, 74, 139, 1);
  static const Color polo_blue = Color.fromRGBO(152, 179, 209, 1);
  static const Color blue_chill = Color.fromRGBO(71, 148, 147, 1);
  static const Color cruise = Color.fromRGBO(124, 196, 195, 1);
  static const Color brick_red = Color.fromRGBO(191, 25, 49, 1);
  static const Color cinnabar = Color.fromRGBO(226, 88, 62, 1);

  static TextTheme textTheme1 = TextTheme(
    bodyLarge: TextStyle(fontFamily: "PublicSansSerif", fontSize: 14),
    bodyMedium: TextStyle(fontFamily: "PublicSansSerif", fontSize: 12),
  );
  static TextTheme textTheme2 = TextTheme(
    bodyLarge: TextStyle(fontFamily: "Inter", fontSize: 14),
    bodyMedium: TextStyle(fontFamily: "Inter", fontSize: 12),
  );

  static LinearGradient buildLinearGradient3() {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [MyTheme.polo_blue, MyTheme.gigas],
    );
  }

  static LinearGradient buildLinearGradient2() {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [MyTheme.cruise, MyTheme.blue_chill],
    );
  }

  static LinearGradient buildLinearGradient1() {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [MyTheme.cinnabar, MyTheme.brick_red],
    );
  }

  static BoxShadow commonShadow() {
    return BoxShadow(
      color: Colors.black.withValues(alpha: .08),
      blurRadius: 20,
      spreadRadius: 0.0,
      offset: Offset(0.0, 10.0),
    );
  }

  static TextStyle homeText_heding() {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle priceText({required Color color}) {
    return TextStyle(
      color: color,
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
    );
  }
  static TextStyle productNameStyle() {
    return TextStyle(
      color: MyTheme.font_grey,
      fontSize: 12.sp,
      height: 1.2,
      fontWeight: FontWeight.w400,
    );
  }
}
