import 'package:flutter/material.dart';

class PasswordFormField extends StatelessWidget {
  PasswordFormField({super.key});

  final ValueNotifier<bool> _hasError = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: 'Password*',
        border: OutlineInputBorder(),
        helperText: 'required*',
        suffixIcon: _hasError.value
            ? Icon(Icons.error_outline_rounded, color: Colors.red)
            : null,
      ),
      obscureText: true,
      onChanged: (value) {
        if (value.isEmpty || value.length < 6) {
          _hasError.value = true;
        } else {
          _hasError.value = false;
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
  }
}
