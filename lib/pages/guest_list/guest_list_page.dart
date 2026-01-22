import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'widgets/guest_statistics_card.dart';

class GuestListPage extends StatelessWidget {
  const GuestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    return isLargeScreen ? LargeGuestListPage() : SmallGuestListPage();
  }
}

class LargeGuestListPage extends StatelessWidget {
  const LargeGuestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: .center,
          mainAxisSize: .max,
          spacing: 24.0,
          children: [
            Flexible(
              child: GuestStatisticsCard(
                title: "Card A",
                value: "42",
                subtitle: 'New Guests',
                icon: Icons.people,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Flexible(
              child: GuestStatisticsCard(
                title: "Card B",
                value: "128",
                icon: Icons.event,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SmallGuestListPage extends StatelessWidget {
  const SmallGuestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24.0,
      children: [
        const SizedBox(height: 24),
        Flexible(
          child: GuestStatisticsCard(
            title: "Card A",
            value: "42",
            icon: Icons.people,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Flexible(
          child: GuestStatisticsCard(
            title: "Card B",
            value: "128",
            icon: Icons.event,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
