# Color Architecture Documentation

This directory contains the complete color system for the alonet Flutter app. The color architecture is designed to be scalable, maintainable, and consistent across the entire application.

## Directory Structure

```
lib/core/colors/
├── README.md              # This documentation file
├── colors.dart           # Barrel file - exports all color classes
├── app_colors.dart       # Main color constants and definitions
├── color_palette.dart    # Color palettes for different themes
├── color_extensions.dart # Color utility extensions
└── theme_colors.dart     # Theme integration for MaterialApp
```

## File Descriptions

### `colors.dart` (Barrel File)
This is the main entry point for importing colors. Import this file in your screens:
```dart
import 'package:alonet_app/core/colors/colors.dart';
```

### `app_colors.dart`
Contains all the base color constants used throughout the app:
- **Primary Brand Colors**: Main blue color variations
- **Secondary Colors**: Purple accent colors
- **Accent Colors**: Orange, green, red for highlights
- **Neutral Colors**: Grays, black, white
- **Text Colors**: Primary, secondary, hint text
- **Surface Colors**: Background and surface variations
- **Status Colors**: Success, warning, error, info
- **Border Colors**: Light, medium, dark borders
- **Shadow Colors**: Various shadow intensities

### `color_palette.dart`
Defines color palettes for different themes and semantic color meanings:
- **ColorPalette**: Light and dark theme color combinations
- **SemanticColors**: UI component-specific color definitions

### `color_extensions.dart`
Provides useful extensions for the Color class:
- `toMaterialColor()`: Convert Color to MaterialColor
- `tint(factor)`: Create lighter variations
- `shade(factor)`: Create darker variations
- `complementary`: Get complementary color
- `analogous()`: Get analogous colors
- `triadic()`: Get triadic colors
- `toHex()`: Convert to hex string
- `isLight` / `isDark`: Check color brightness
- `contrastingTextColor`: Get appropriate text color

### `theme_colors.dart`
Contains complete theme configurations:
- **ThemeColors.lightTheme**: Complete light theme setup
- **ThemeColors.darkTheme**: Complete dark theme setup
- Includes theming for all Material components

## Usage Examples

### Basic Color Usage
```dart
import 'package:alonet_app/core/colors/colors.dart';

// Using direct colors
Container(
  color: AppColors.primaryBlue,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textOnDark),
  ),
)

// Using theme colors (recommended)
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)
```

### Using Color Extensions
```dart
import 'package:alonet_app/core/colors/colors.dart';

final baseColor = AppColors.primaryBlue;

// Create variations
final lighterBlue = baseColor.tint(0.3);
final darkerBlue = baseColor.shade(0.2);
final complementary = baseColor.complementary;

// Get hex value
final hexString = baseColor.toHex(); // "#2196F3"

// Check if color is light or dark
final textColor = baseColor.contrastingTextColor;
```

### Semantic Color Usage
```dart
import 'package:alonet_app/core/colors/colors.dart';

// Use semantic colors for consistent UI
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: SemanticColors.buttonPrimary,
  ),
  child: Text('Primary Button'),
)

// Status colors
Container(
  color: SemanticColors.statusSuccess,
  child: Text('Success message'),
)
```

## Best Practices

### 1. Always Use Theme Colors
Prefer theme colors over direct color constants:
```dart
// ✅ Good - uses theme
color: Theme.of(context).colorScheme.primary

// ❌ Avoid - hardcoded
color: AppColors.primaryBlue
```

### 2. Use Semantic Colors for Components
```dart
// ✅ Good - semantic meaning
backgroundColor: SemanticColors.buttonPrimary

// ❌ Avoid - unclear intent
backgroundColor: AppColors.primaryBlue
```

### 3. Leverage Color Extensions
```dart
// ✅ Good - uses extensions
final cardColor = baseColor.tint(0.9);
final textColor = cardColor.contrastingTextColor;

// ❌ Avoid - manual calculations
final cardColor = Color.fromRGBO(/* manual calculation */);
```

### 4. Consistent Color Naming
- Use descriptive names: `primaryBlue`, not `color1`
- Include intensity: `primaryBlueDark`, `primaryBlueLight`
- Use semantic names: `textPrimary`, `surfaceVariant`

## Adding New Colors

### 1. Add to `app_colors.dart`
```dart
static const Color newFeatureColor = Color(0xFF123456);
```

### 2. Add to `color_palette.dart` if needed
```dart
static const Color newFeatureButton = AppColors.newFeatureColor;
```

### 3. Update `theme_colors.dart` if it affects theming
```dart
// Add to appropriate theme sections
```

### 4. Document the new color purpose
Update this README with the new color's purpose and usage.

## Dark Mode Support

The color system fully supports dark mode:
- Light and dark themes are defined in `theme_colors.dart`
- App automatically switches based on system preference
- All colors have appropriate dark mode variants
- Use `Theme.of(context).colorScheme` for automatic theme switching

## Testing Colors

The Home screen includes a color demonstration section that shows:
- Primary color palette
- Color hex values
- Light/dark text contrast
- Interactive examples

## Migration Guide

If you have existing hardcoded colors:

1. **Identify the color purpose**: Is it a primary action, text, background?
2. **Find the appropriate theme color**: Check `theme_colors.dart`
3. **Replace with theme reference**:
   ```dart
   // Before
   color: Colors.blue
   
   // After
   color: Theme.of(context).colorScheme.primary
   ```
4. **Test in both light and dark modes**

## Maintenance

- Review color usage quarterly
- Update colors based on design system changes
- Ensure accessibility compliance (contrast ratios)
- Keep documentation updated with changes
