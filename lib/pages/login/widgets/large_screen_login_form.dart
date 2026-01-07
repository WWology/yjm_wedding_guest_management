import 'package:flutter/material.dart';
import 'package:yjm_wedding_guest_management/pages/login/widgets/email_form_field.dart';

import 'password_form_field.dart';

class LargeScreenLoginForm extends StatelessWidget {
  const LargeScreenLoginForm({super.key, required GlobalKey<FormState> formKey})
    : _formKey = formKey;

  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        Expanded(child: Placeholder()),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .center,
            children: [
              EmailFormField(),
              const SizedBox(height: 16),
              PasswordFormField(),
            ],
          ),
        ),
      ],
    );
  }
}
