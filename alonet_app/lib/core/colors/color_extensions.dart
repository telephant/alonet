import 'package:flutter/material.dart';

/// Extensions for Color class to provide additional functionality
extension ColorExtensions on Color {
  /// Creates a MaterialColor from this Color
  MaterialColor toMaterialColor() {
    final Map<int, Color> swatch = {
      50: _tintColor(this, 0.9),
      100: _tintColor(this, 0.8),
      200: _tintColor(this, 0.6),
      300: _tintColor(this, 0.4),
      400: _tintColor(this, 0.2),
      500: this,
      600: _shadeColor(this, 0.1),
      700: _shadeColor(this, 0.2),
      800: _shadeColor(this, 0.3),
      900: _shadeColor(this, 0.4),
    };
    return MaterialColor(value, swatch);
  }

  /// Creates a tinted version of this color (lighter)
  Color tint(double factor) => _tintColor(this, factor);

  /// Creates a shaded version of this color (darker)
  Color shade(double factor) => _shadeColor(this, factor);

  /// Returns the complementary color
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }

  /// Returns an analogous color (30 degrees apart on color wheel)
  Color analogous({double degrees = 30}) {
    final hsl = HSLColor.fromColor(this);
    final analogousHue = (hsl.hue + degrees) % 360;
    return hsl.withHue(analogousHue).toColor();
  }

  /// Returns a triadic color (120 degrees apart on color wheel)
  Color triadic() {
    final hsl = HSLColor.fromColor(this);
    final triadicHue = (hsl.hue + 120) % 360;
    return hsl.withHue(triadicHue).toColor();
  }

  /// Converts color to hex string
  String toHex({bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${alpha.toRadixString(16).padLeft(2, '0')}'
          '${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}';
    } else {
      return '#${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}';
    }
  }

  /// Checks if the color is considered light
  bool get isLight {
    final luminance = computeLuminance();
    return luminance > 0.5;
  }

  /// Checks if the color is considered dark
  bool get isDark => !isLight;

  /// Returns appropriate text color (black or white) based on this background color
  Color get contrastingTextColor => isLight ? Colors.black : Colors.white;
}

/// Helper function to create tinted color
Color _tintColor(Color color, double factor) {
  return Color.fromRGBO(
    _tintValue(color.red, factor),
    _tintValue(color.green, factor),
    _tintValue(color.blue, factor),
    1,
  );
}

/// Helper function to create shaded color
Color _shadeColor(Color color, double factor) {
  return Color.fromRGBO(
    _shadeValue(color.red, factor),
    _shadeValue(color.green, factor),
    _shadeValue(color.blue, factor),
    1,
  );
}

int _tintValue(int value, double factor) =>
    (value + ((255 - value) * factor)).round();

int _shadeValue(int value, double factor) =>
    (value * (1 - factor)).round();
