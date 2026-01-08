import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/auth/auth.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final emailHasError = ValueNotifier(false);
    final passwordHasError = ValueNotifier(false);

    String? email;
    String? password;
    return SizedBox(
      height: 300,
      child: Form(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          children: [
            // Email Form Field
            ValueListenableBuilder(
              valueListenable: emailHasError,
              builder: (context, value, child) {
                return TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Email*',
                    border: OutlineInputBorder(),
                    helperText: 'required*',
                    suffixIcon: emailHasError.value
                        ? Icon(Icons.error_outline_rounded, color: Colors.red)
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (newEmail) => email = newEmail,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      emailHasError.value = true;
                    }

                    final validEmail = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value);
                    if (!validEmail) {
                      emailHasError.value = true;
                    } else {
                      emailHasError.value = false;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      emailHasError.value = true;
                      return 'Please enter your email';
                    }

                    final validEmail = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value);
                    if (!validEmail) {
                      emailHasError.value = true;
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                  autovalidateMode: .onUserInteraction,
                );
              },
            ),
            const SizedBox(height: 16),
            // Password Form Field
            ValueListenableBuilder(
              valueListenable: passwordHasError,
              builder: (context, value, child) {
                return TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: 'Password*',
                    border: OutlineInputBorder(),
                    helperText: 'required*',
                    suffixIcon: passwordHasError.value
                        ? Icon(Icons.error_outline_rounded, color: Colors.red)
                        : null,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  onSaved: (newPassword) => password = newPassword,
                  obscureText: true,
                  onChanged: (value) {
                    if (value.isEmpty || value.length < 6) {
                      passwordHasError.value = true;
                    } else {
                      passwordHasError.value = false;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: .onUserInteraction,
                );
              },
            ),
            const SizedBox(height: 16),
            // Login Button
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
