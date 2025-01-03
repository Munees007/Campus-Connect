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
                  Opacity(
                    opacity: 0.3,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 2,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Google Sign-in Tapped");
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      alignment: Alignment.center,
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 55),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/Assets/Icons/Google.png',
                            width: 35,
                            height: 35,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in With Google",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Need an account?",
                        style: TextStyle(fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Navigate to Sign Up");
                        },
                        child: const Text(
                          " Sign up",
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
