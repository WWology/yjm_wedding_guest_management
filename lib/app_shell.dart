import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.child, super.key});

  final Widget child;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final largeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            if (largeScreen)
              NavigationRail(
                groupAlignment: -0.9,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.play_arrow),
                    label: Text('Play'),
                  ),
                ],
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });

                  switch (index) {
                    case 0:
                      HomeRouteData().go(context);
                    case 1:
                    // TODO
                  }
                },
              ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: largeScreen
            ? null
            : NavigationBar(
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.play_arrow),
                    label: 'Play',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  switch (index) {
                    case 0:
                      HomeRouteData().go(context);
                    case 1:
                    // TODO
                  }
                },
              ),
      ),
    );
  }
}
