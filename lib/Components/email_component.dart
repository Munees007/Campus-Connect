import 'package:campus_connect/Components/input_component.dart';
import 'package:flutter/material.dart';

class EmailComponent extends StatelessWidget {
  const EmailComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Flex(
      direction: Axis.vertical,
      children: [
        InputComponent(
          hint: "Email",
          isPassword: false,
        ),
        InputComponent(
          hint: "Password",
          isPassword: true,
        )
      ],
    );
  }
}
