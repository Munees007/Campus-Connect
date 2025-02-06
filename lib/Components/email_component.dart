import 'package:campus_connect/Backend/Add/text_db.dart';
import 'package:flutter/material.dart';
import 'input_component.dart';

class EmailComponent extends StatelessWidget {
  const EmailComponent({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController pass = TextEditingController();

    return Column(
      children: [
        InputComponent(
          hint: "Email",
          preficIconPath: "lib/Assets/Icons/Mail.png",
          isPassword: false,
          controller: email,
        ),
        InputComponent(
          hint: "Password",
          preficIconPath: "lib/Assets/Icons/Pass.png",
          isPassword: true,
          controller: pass,
        ),
        GestureDetector(
          onTap: () {
            Textdb().setName();
            print("Email = ${email.text}");
            print("Pass = ${pass.text}");
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
            alignment: Alignment.center,
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 60),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "LOGIN",
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
      ],
    );
  }
}
