import 'package:flutter/material.dart';
import '../Components/email_component.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            "lib/Assets/Images/login_bg.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Image.asset(
                    "lib/Assets/Icons/logo_center.png",
                    width: 140.0,
                    height: 140.0,
                  ),
                  const EmailComponent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
