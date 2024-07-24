import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthToken();
  }

  _checkAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    await Future.delayed(
        Duration(milliseconds: 3000), () {}); // Durasi splash screen

    if (authToken != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Ubah sesuai warna latar belakang yang diinginkan
      body: Center(
        child: Image.asset('images/nutrify.png',
            width: 200,
            height:
                200), // Pastikan untuk menambahkan logo Anda di folder assets
      ),
    );
  }
}
