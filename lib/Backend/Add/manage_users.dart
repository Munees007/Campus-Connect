import 'package:campus_connect/Components/toast_message.dart';
import 'package:campus_connect/Pages/admin_home_page.dart';
import 'package:campus_connect/Pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
          await Hive.box('UserBox').put("isLogin", true);
          await Hive.box('UserBox').put("userData", userData);
          print(userData['staffId'] == "ADMIN");

          if (userData['staffId'] == "ADMIN") {
            ToastManager().showToast(
                context: context,
                message: "Login Successful",
                type: ToastType.info);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AdminHomePage()));
            return;
          }
          ToastManager().showToast(
              context: context,
              message: "Login Successful",
              type: ToastType.info);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
          return;
        }
      }
    }
  }
  ToastManager().showToast(
      context: context, message: "Invalid Credentials.", type: ToastType.error);
  print("❌ Invalid credentials. Please try again.");
}
