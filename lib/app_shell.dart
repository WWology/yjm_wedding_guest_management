import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final smallOrMediumScreen = ResponsiveBreakpoints.of(
      context,
    ).smallerThan(DESKTOP);

    return SafeArea(child: smallOrMediumScreen ? Placeholder() : Placeholder());
  }
}