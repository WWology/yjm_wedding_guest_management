import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  EmailFormField({super.key});

  final ValueNotifier<bool> _hasError = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _hasError,
      builder: (context, value, child) {
        return TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            labelText: 'Email*',
            border: OutlineInputBorder(),
            helperText: 'required*',
            suffixIcon: _hasError.value
                ? Icon(Icons.error_outline_rounded, color: Colors.red)
                : null,
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              _hasError.value = true;
            }

            final validEmail = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
            ).hasMatch(value);
            if (!validEmail) {
              _hasError.value = true;
            } else {
              _hasError.value = false;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              _hasError.value = true;
              return 'Please enter your email';
            }

            final validEmail = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
            ).hasMatch(value);
            if (!validEmail) {
              _hasError.value = true;
              return 'Please enter a valid email';
            }

            return null;
          },
          autovalidateMode: .onUserInteraction,
        );
      },
    );
  }
}
