//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';

import '../../util/responsive.dart';

class SkyleTheme {
  static ThemeData data() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      // accentColor: Colors.teal.shade800,
      colorScheme: ColorScheme(
        primary: Colors.teal.shade800,
        secondary: Colors.blue,
        background: Colors.black,
        brightness: Brightness.dark,
        error: Colors.red,
        surface: Colors.grey.shade900,
        onBackground: Colors.white,
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      toggleableActiveColor: Colors.teal.shade800,
      primaryColor: Colors.teal.shade800,
      primaryTextTheme: TextTheme(
        headline1: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        headline2: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        bodyText1: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
        ),
        bodyText2: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
        ),
      ),
      // visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData of(BuildContext context) {
    return data().copyWith(
      primaryTextTheme: TextTheme(
        headline1: TextStyle(
          color: Colors.white,
          fontSize: Responsive.getResponsiveValue(
            forLargeScreen: 40,
            forMediumScreen: 25,
            context: context,
          ),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        headline2: TextStyle(
          color: Colors.white,
          fontSize: Responsive.getResponsiveValue(
            forLargeScreen: 30,
            forMediumScreen: 20,
            context: context,
          ),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        headline3: TextStyle(
          color: Colors.white,
          fontSize: Responsive.getResponsiveValue(
            forLargeScreen: 20,
            forMediumScreen: 14,
            context: context,
          ),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        bodyText1: TextStyle(
          color: Colors.white,
          fontSize: Responsive.getResponsiveValue(
            forLargeScreen: 20,
            forMediumScreen: 14,
            context: context,
          ),
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
        ),
        bodyText2: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: Responsive.getResponsiveValue(
            forLargeScreen: 20,
            forMediumScreen: 14,
            context: context,
          ),
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
        ),
      ),
      // visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
