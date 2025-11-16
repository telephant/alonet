import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable bottom navigation icon widget with an optional highlight circle.
/// Supports different sizes for inner icon, highlight circle, and overall container.
class NavIcon extends StatelessWidget {
  final String iconPath; // Path to the main icon SVG
  final String activeCirclePath; // Path to the highlight circle SVG
  final double iconSize; // Size of the inner icon
  final double circleSize; // Size of the highlight circle
  final double overallSize; // Outer container size
  final bool isActive; // Whether the icon is in active (selected) state

  const NavIcon({
    super.key,
    required this.iconPath,
    required this.activeCirclePath,
    this.iconSize = 28,
    this.circleSize = 40,
    this.overallSize = 40,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: overallSize,
      height: overallSize,
      child: isActive
          ? Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  activeCirclePath,
                  width: circleSize,
                  height: circleSize,
                ),
                SvgPicture.asset(iconPath, width: iconSize, height: iconSize),
              ],
            )
          : Center(
              child: SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
              ),
            ),
    );
  }

  /// Helper method to directly create a BottomNavigationBarItem
  BottomNavigationBarItem toNavBarItem({required String label}) {
    return BottomNavigationBarItem(
      icon: NavIcon(
        iconPath: iconPath,
        activeCirclePath: activeCirclePath,
        iconSize: iconSize,
        circleSize: circleSize,
        overallSize: overallSize,
        isActive: false,
      ),
      activeIcon: NavIcon(
        iconPath: iconPath,
        activeCirclePath: activeCirclePath,
        iconSize: iconSize,
        circleSize: circleSize,
        overallSize: overallSize,
        isActive: true,
      ),
      label: label,
    );
  }
}
