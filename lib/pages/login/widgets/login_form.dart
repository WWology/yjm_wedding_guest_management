import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:yjm_wedding_guest_management/pages/login/widgets/small_screen_login_form.dart';

import 'large_screen_login_form.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Form(
      key: _formKey,
      child: isLargeScreen
          ? LargeScreenLoginForm(formKey: _formKey)
          : SmallScreenLoginForm(formKey: _formKey),
    );
  }
}
