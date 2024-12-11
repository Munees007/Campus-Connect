import 'package:campus_connect/Components/email_component.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "lib/Assets/Images/login_bg.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 80),
                  child: Image.asset(
                    "lib/Assets/Icons/logo_center.png",
                    width: 140.0,
                    height: 140.0,
                    fit: BoxFit.cover,
                  ),
                ),
                EmailComponent()
              ],
            ),
          ),
        )
      ],
    );
  }
}
