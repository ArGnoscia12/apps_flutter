// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beta_app1/page/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _cekLogin();
  }

  Future<void> _prosesLogin() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      _showDialog('Login Gagal', 'Harap isi semua field.', false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String mqttServerIp = prefs.getString('mqtt_server_ip') ?? '192.168.87.153';
    String url = 'http://$mqttServerIp/test_api/login.php';

    final response = await http.post(
      Uri.parse(url),
      body: {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      if (responseBody['success']) {
        final datauser = responseBody['data'];
        final token = datauser['token'];
        final username = datauser['username'];

        await saveAuthToken(
            token, username); // Simpan token ke SharedPreferences

        _showDialog(
            'Login Berhasil', 'Selamat datang, ${datauser['fullname']}!', true);
      } else {
        _showDialog('Login Gagal', responseBody['message'], false);
      }
    } else {
      _showDialog('Login Gagal', 'Terjadi kesalahan pada server.', false);
    }
  }

  Future<void> saveAuthToken(String token, String username) async {
    if (token.isNotEmpty && username.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_username', username);
      await prefs.setString('auth_token', token);
    } else {
      _showDialog(
          'Upaya Login Gagal', 'Cek Kembali Username dan Password', false);
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _cekLogin() async {
    final authToken = await getAuthToken();
    if (authToken != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  void _showDialog(String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "images/nature.gif",
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 25),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            hintText: 'Please input your username',
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.25),
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.password),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            hintText: "Please input your password",
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.25),
                              fontSize: 14.0,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _prosesLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 41, 221, 47),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                                color: Color.fromARGB(166, 26, 21, 21)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Apps Made For",
                  style: TextStyle(color: Colors.black, fontSize: 10),
                ),
                const Text(
                  "Nutrient Hydroponic Control",
                  style: TextStyle(color: Colors.black, fontSize: 10.0),
                ),
                const Text(
                  "@2024",
                  style: TextStyle(color: Colors.black, fontSize: 10.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
