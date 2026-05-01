import 'package:flutter/material.dart';

class RacheetaColors {
  const RacheetaColors._();

  static const primary = Color(0xFF17B3A3);
  static const primaryHover = Color(0xFF119C90);
  static const softMint = Color(0xFFA9D6CF);
  static const mintLight = Color(0xFFCFE5E1);
  static const surface = Color(0xFFF4F6F5);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2C3135);
  static const textSecondary = Color(0xFF7E8788);
  static const border = Color(0xFFDDE7E4);
  static const danger = Color(0xFFE05252);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF22A06B);

  static const darkBackground = Color(0xFF0D1418);
  static const darkSurface = Color(0xFF111C22);
  static const darkCard = Color(0xFF16242B);
  static const darkBorder = Color(0xFF25333A);
  static const darkTextPrimary = Color(0xFFF3F7F6);
  static const darkTextSecondary = Color(0xFFA8B3B5);
}

class RacheetaSpacing {
  const RacheetaSpacing._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class RacheetaRadius {
  const RacheetaRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
}

class RacheetaShadows {
  const RacheetaShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];
}

class RacheetaGradients {
  const RacheetaGradients._();

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      RacheetaColors.primary,
      RacheetaColors.primaryHover,
    ],
  );
}
