import 'package:flutter/material.dart';

import 'package:beta_app1/login/register.dart';
import 'package:beta_app1/login/login.dart';
import 'package:beta_app1/page/dashboard.dart';
import 'package:beta_app1/splash_screen.dart'; // Pastikan ini mengarah ke splash_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrify Apps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
