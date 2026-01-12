import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../routes.dart';

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
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return SafeArea(
      child: Scaffold(
        appBar: isLargeScreen ? null : AppBar(title: const Text('My App')),
        body: Row(
          children: [
            if (isLargeScreen)
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
                      HomeRoute().go(context);
                    case 1:
                    // TODO
                  }
                },
              ),
            Expanded(
              child: Scaffold(
                appBar: isLargeScreen
                    ? AppBar(title: const Text('My App'))
                    : null,
                body: widget.child,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('Add a guest'),
          icon: Icon(Icons.person_add),
        ),
        bottomNavigationBar: isLargeScreen
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
                      HomeRoute().go(context);
                    case 1:
                    // TODO
                  }
                },
              ),
      ),
    );
  }
}
