import 'package:campus_connect/Backend/Add/text_db.dart';
import 'package:campus_connect/Components/drop_down.dart';
import 'package:campus_connect/Components/toast_message.dart';
import 'package:flutter/material.dart';
import 'input_component.dart';

class EmailComponent extends StatefulWidget {
  const EmailComponent({super.key});

  @override
  State<EmailComponent> createState() => _EmailComponentState();
}

class _EmailComponentState extends State<EmailComponent> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  String role = "Student";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDropdown(
            value: role,
            onChanged: (value) {
              setState(() {
                role = value!;
              });
            },
            options: const ["Student", "Staff"],
            hintText: "Select Role"),
        InputComponent(
          hint: role == "Student" ? "Roll Number" : "Staff ID",
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
            ToastManager().showToast(
                context: context, message: "hi", type: ToastType.info);
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
