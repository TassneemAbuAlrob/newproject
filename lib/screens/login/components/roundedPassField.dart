import 'package:flutter/material.dart';
import 'package:finalfrontproject/constants.dart';
import 'package:finalfrontproject/screens/login/components/text_field_container.dart';
import 'package:finalfrontproject/user.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final User user; // Add this parameter

  const RoundedPasswordField({
    Key? key,
    required this.onChanged,
    required this.user, // Accept the User object as a parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        // Use TextFormField instead of TextField
        controller: TextEditingController(text: user.password),
        onChanged: (value) {
          user.password = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Enter something';
          }
          return null;
        },
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: Color.fromARGB(255, 141, 199, 241),
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: Color.fromARGB(255, 141, 199, 241),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
