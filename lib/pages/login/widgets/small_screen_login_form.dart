import 'package:flutter/material.dart';

import 'email_form_field.dart';
import 'password_form_field.dart';

class SmallScreenLoginForm extends StatelessWidget {
  const SmallScreenLoginForm({super.key, required GlobalKey<FormState> formKey})
    : _formKey = formKey;

  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Expanded(child: Placeholder()),
          const SizedBox(height: 24),
          EmailFormField(),
          const SizedBox(height: 16),
          PasswordFormField(),
        ],
      ),
    );
  }
}
