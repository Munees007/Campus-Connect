import 'package:campus_connect/Pages/chat_bot.dart';
import 'package:campus_connect/Pages/profile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = [const ChatBot(), const ProfilePage()];
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "Chat Bot",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          onTap: (index) {
            setState(() {
              currentPage = index;
            });
          },
          currentIndex: currentPage),
      body: pages[currentPage],
    );
  }
}
