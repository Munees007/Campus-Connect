import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.amber[300],
        body: const Center(
          child: Text(
            'Campus Connect',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
