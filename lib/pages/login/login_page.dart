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
        Expanded(
          child: Center(
            child: Theme.brightnessOf(context) == Brightness.light ?
              const Image(image: AssetImage('assets/images/yj_logo_black.png')) :
              const Image(image: AssetImage('assets/images/yj_logo_white.png')),
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(child: LoginForm()),
      ],
    );
  }
}

class SmallScreenLoginPage extends StatelessWidget {
  const SmallScreenLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Center(
            child: Theme.brightnessOf(context) == Brightness.light ?
              const Image(image: AssetImage('assets/images/yj_logo_black.png')) :
              const Image(image: AssetImage('assets/images/yj_logo_white.png')),
          ),
        ),
        const SizedBox(height: 24),
        const Expanded(flex: 1, child: LoginForm()),
      ],
    );
  }
}
