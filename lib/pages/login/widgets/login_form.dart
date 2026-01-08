import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/auth/auth.dart';
import 'email_form_field.dart';
import 'password_form_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Form(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          children: [
            EmailFormField(),
            const SizedBox(height: 16),
            PasswordFormField(),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                return FilledButton.icon(
                  onPressed: () {
                    final formState = Form.of(context);
                  },
                  label: const Text('Login'),
                  icon: const Icon(Icons.login),
                  style: ButtonStyle(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
