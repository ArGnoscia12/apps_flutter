import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  bool _obscureText = true;

  String usernameError = '';
  String passwordError = '';

  Future<void> registerUser() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String fullname = fullnameController.text.trim();

    // Validasi username
    if (username.length < 6 ||
        !RegExp(r'^(?=.*[A-Z])(?=.*[0-9])[A-Za-z0-9]+$').hasMatch(username)) {
      setState(() {
        usernameError =
            'Username harus minimal 6 karakter, mengandung huruf kapital dan angka.';
      });
      return;
    } else {
      setState(() {
        usernameError = '';
      });
    }

    // Validasi password
    if (password.length < 6 ||
        !RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?~`]).{6,}$')
            .hasMatch(password)) {
      setState(() {
        passwordError =
            'Password harus minimal 6 karakter, mengandung angka dan simbol.';
      });
      return;
    } else {
      setState(() {
        passwordError = '';
      });
    }

    final prefs = await SharedPreferences.getInstance();
    String mqttServerIp =
        prefs.getString('mqtt_server_ip') ?? '192.168.182.153';
    String url = 'http://$mqttServerIp/test_api/register.php';

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "fullname": fullname,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to register user'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/nutrify.png",
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                              'Register',
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
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'Username',
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              ),
                              hintText: 'Username',
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(92, 0, 0, 0)
                                    .withOpacity(0.25),
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          if (usernameError.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 12.0),
                              child: Text(
                                usernameError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: fullnameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.perm_identity),
                              labelText: 'Fullname',
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              ),
                              hintText: 'Fullname',
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
                              prefixIcon: const Icon(Icons.password),
                              labelText: 'Password',
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              ),
                              hintText: 'Password',
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
                          if (passwordError.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 12.0),
                              child: Text(
                                passwordError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 221, 41, 41),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah memiliki akun?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  ' Masuk',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
