import 'package:campus_connect/Pages/home_page.dart';
import 'package:campus_connect/Pages/login_page.dart';
import 'package:campus_connect/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Widget initPage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bool isLogin = Hive.box('userBox').get('isLogin', defaultValue: false);
    if (isLogin) {
      print(Hive.box('userBox').get('userData'));
      initPage = const HomePage();
    } else {
      initPage = const LoginPage();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: initPage);
  }
}
