import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    return Scaffold(
      body: isLargeScreen ? LargeScreenLoginPage() : SmallScreenLoginPage(),
    );
  }
}

class LargeScreenLoginPage extends StatelessWidget {
  const LargeScreenLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        Expanded(child: Placeholder()),
        const SizedBox(width: 24),
        Expanded(child: LoginForm()),
      ],
    );
  }
}

class SmallScreenLoginPage extends StatelessWidget {
  const SmallScreenLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [Placeholder(), const SizedBox(height: 24), LoginForm()],
      ),
    );
  }
}
