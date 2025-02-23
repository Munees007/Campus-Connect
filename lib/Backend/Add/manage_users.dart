import 'package:campus_connect/Pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> loginUser(
    String id, String password, String role, BuildContext context) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child("users");

  print("Logging in user with role: $role, ID: $id, Password: $password");

  final snapshot = await ref.get();

  if (snapshot.exists && snapshot.value is Map<Object?, Object?>) {
    final Map<Object?, Object?> users = snapshot.value as Map<Object?, Object?>;

    for (var entry in users.entries) {
      if (entry.value is Map<Object?, Object?>) {
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(entry.value as Map<Object?, Object?>);

        // Match user by role, ID (staffId/rollNo), and password
        if (userData['role'] == role &&
            ((role == 'staff' && userData['staffId'] == id) ||
                (role == 'student' && userData['rollNo'] == id)) &&
            userData['password'] == password) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
          return;
        }
      }
    }
  }

  print("❌ Invalid credentials. Please try again.");
}
