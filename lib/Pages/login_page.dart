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
            resizeToAvoidBottomInset: false,
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
                const EmailComponent(),
                Opacity(
                  opacity: 0.3,
                  child: Container(
                    margin: const EdgeInsets.only(top: 25, left: 20, right: 20),
                    height: 2,
                    color: Colors.black,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.only(left: 30, top: 60, right: 30),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(30)),
                    child: Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            'lib/Assets/Icons/Google.png',
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          const Text(
                            "Sign in With Google",
                            style: TextStyle(fontSize: 25),
                          ),
                        ]),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Need an account?",
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () => {},
                        child: const Text(
                          "Sign up",
                          style: TextStyle(fontSize: 20),
                        ))
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
