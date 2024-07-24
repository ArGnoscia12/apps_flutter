import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:beta_app1/login/api_service.dart';
import 'package:beta_app1/login/user.dart';
import 'package:beta_app1/login/login.dart';
import 'package:beta_app1/page/control.dart';
import 'package:beta_app1/page/monitoring.dart';
import 'package:beta_app1/page/info.dart';
import 'package:beta_app1/page/homecontent.dart';

final sensorData = SensorData();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isConnected = false;
  late MqttServerClient _client;
  late StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>?
      subscription;
  final ApiService apiService = ApiService();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Widget> _children = [];

  double? tdsmin;
  double? tdsmax;
  double? tdsnow;

  @override
  void initState() {
    super.initState();
    _initializeClient();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin
        .initialize(initializationSettings)
        .then((_) {
      print('Notification plugin initialized');
    });
  }

  void _initializeClient() async {
    final prefs = await SharedPreferences.getInstance();
    String mqttServerIp = prefs.getString('mqtt_server_ip') ?? '192.168.1.100';
    String baseUrl = 'http://$mqttServerIp';

    _client = MqttServerClient(mqttServerIp, 'Mqtt_Flutter');
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.connectTimeoutPeriod = 2000;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.autoReconnect = true;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_Flutter')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('Connecting to Mosquitto client...');
    _client.connectionMessage = connMess;

    try {
      await _client.connect().timeout(Duration(seconds: 1));
      setState(() {
        _isConnected = true;
      });
      _subscribeToTopics();
    } catch (e) {
      print('Exception: $e');
      _showErrorDialog('Failed to connect to MQTT broker');
    }

    _children = [
      HomeContent(),
      SensorMonitoringScreen(client: _client),
      ControlScreen(client: _client),
      InfoPage(),
    ];
  }

  void _onConnected() {
    print('Connected');
    setState(() {
      _isConnected = true;
    });
  }

  void _onDisconnected() {
    print('Disconnected');
    setState(() {
      _isConnected = false;
    });
  }

  void _onAutoReconnect() {
    print('Attempting to reconnect...');
    setState(() {
      _isConnected = false;
    });
  }

  void _onAutoReconnected() {
    print('Successfully reconnected');
    setState(() {
      _isConnected = true;
    });
  }

//Fungsi untuk subscribe Topic MQTT sensor
  void _subscribeToTopics() {
    _client.subscribe('sensor/tds', MqttQos.atMostOnce);
    _client.subscribe('sensor/waterflow1', MqttQos.atLeastOnce);
    _client.subscribe('sensor/waterflow2', MqttQos.atLeastOnce);
    _client.subscribe('sensor/ultrasonic', MqttQos.atLeastOnce);
    _client.subscribe(
        'parameter', MqttQos.atLeastOnce); // Subscribe to parameter topic

    subscription = _client.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage?>> messages) async {
        final message = messages[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        print('Received message: $payload from topic: ${messages[0].topic}');

        try {
          if (messages[0].topic == 'sensor/waterflow1' ||
              messages[0].topic == 'sensor/waterflow2') {
            Map<String, dynamic> data = jsonDecode(payload);

            if (data.containsKey('speed_waterflow') &&
                data['speed_waterflow'] != null &&
                data.containsKey('total_cairan') &&
                data['total_cairan'] != null) {
              double flowRatePerSecond =
                  (data['speed_waterflow'] as num).toDouble();
              double totalFlow = (data['total_cairan'] as num).toDouble();

              if (mounted) {
                setState(() {
                  if (messages[0].topic == 'sensor/waterflow1') {
                    sensorData.waterflow1Value = totalFlow;
                    sensorData.waterflow1speed = flowRatePerSecond;
                  } else if (messages[0].topic == 'sensor/waterflow2') {
                    sensorData.waterflow2Value = totalFlow;
                    sensorData.waterflow2speed = flowRatePerSecond;
                  }
                });
              }

              // Simpan data ke database
              await saveDataToDatabase(
                  messages[0].topic, totalFlow, flowRatePerSecond);
            } else {
              print('Invalid data format in ${messages[0].topic}: $data');
            }
          } else if (messages[0].topic == 'parameter') {
            Map<String, dynamic> data = jsonDecode(payload);

            if (data.containsKey('tdsmin') && data['tdsmin'] != null) {
              setState(() {
                tdsmin = (data['tdsmin'] as num).toDouble();
              });
              print('Updated tdsmin: $tdsmin');
            }

            if (data.containsKey('tdsmax') && data['tdsmax'] != null) {
              setState(() {
                tdsmax = (data['tdsmax'] as num).toDouble();
              });
              print('Updated tdsmax: $tdsmax');
            }
          } else {
            double? value;
            try {
              value = double.parse(payload);
            } catch (e) {
              print('Error parsing payload: $e');
              return;
            }

            if (mounted) {
              setState(() {
                switch (messages[0].topic) {
                  case 'sensor/tds':
                    sensorData.tdsValue = value;
                    tdsnow = value;
                    if (tdsnow != null && tdsmax != null && tdsnow! > tdsmax!) {
                      _showNotification(
                        'TDS Alert',
                        'Nilai TDS ($tdsnow) melebihi batas maksimum ($tdsmax). Mohon segera tambahkan air',
                      );
                    }
                    break;
                  case 'sensor/ultrasonic':
                    sensorData.ultrasonicValue = value;
                    break;
                  default:
                    print('Unknown topic: ${messages[0].topic}');
                }
              });
            }

            // Simpan data ke database
            await saveDataToDatabase(messages[0].topic, value, null);
          }
        } catch (e) {
          print('Exception in _subscribeToTopics: $e');
        }
      },
    );
  }

  Future<void> _showNotification(String title, String body) async {
    print('Attempting to show notification');

    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'alerts_channel',
      'Alerts',
      channelDescription: 'Channel for important alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      vibrationPattern: vibrationPattern,
      enableVibration: true,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> saveTdsValues(double tdsmin, double tdsmax) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tdsmin', tdsmin);
    await prefs.setDouble('tdsmax', tdsmax);
  }

  Future<Map<String, double?>> loadTdsValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    double? tdsmin = prefs.getDouble('tdsmin');
    double? tdsmax = prefs.getDouble('tdsmax');
    return {'tdsmin': tdsmin, 'tdsmax': tdsmax};
  }

// Fungsi untuk menyimpan data ke database
  Future<void> saveDataToDatabase(
      String topic, double value, double? speed) async {
    final prefs = await SharedPreferences.getInstance();
    String mqttServerIp = prefs.getString('mqtt_server_ip') ?? '192.168.1.100';
    String url = 'http://$mqttServerIp/test_api/save_msg.php';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, dynamic>{'topic': topic, 'value': value, 'speed': speed}),
    );

    if (response.statusCode == 200) {
      print('Data berhasil disimpan ke database');
    } else {
      print('Gagal menyimpan data ke database: ${response.body}');
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        await apiService.logout(token);
        await removeAuthToken();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        _showErrorDialog('Failed to logout. Please try again');
      }
    }
  }

  void _showErrorDialog(String message) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(message),
              SizedBox(height: 20),
              Text('Masukkan IP Server:'),
              TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Contoh: 192.168.1.100'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String ipServer = _controller.text.trim();
                if (ipServer.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('mqtt_server_ip', ipServer);

                  try {
                    _client.disconnect();
                    _initializeClient();
                  } catch (e) {
                    print('Exception: $e');
                    _showErrorDialog('failed to reconnect to MQTT Broker');
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _toggleConnection() async {
    if (_isConnected) {
      _client.disconnect();
    } else {
      final prefs = await SharedPreferences.getInstance();
      String ipServer =
          prefs.getString('mqtt_server_ip') ?? '192.168.65.153'; // Default IP
      try {
        await _client.connect(ipServer);
      } catch (e) {
        print('Exception: $e');
        _showErrorDialog('Failed to connect to MQTT broker');
      }
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Dashboard', 'Monitoring', 'Control', 'Info'][_currentIndex],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 66, 66, 66)),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: FutureBuilder<List<User>>(
          future: apiService.fetchUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            }

            User user = snapshot.data!.first;

            return Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    accountName: Text(
                      user.fullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    accountEmail: Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    currentAccountPicture: const CircleAvatar(
                      backgroundImage: AssetImage('images/ahri_icon.jpg'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    onTap: _logout,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _currentIndex >= 0 && _currentIndex < _children.length
                ? _children[_currentIndex]
                : Container(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Info',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isConnected ? Colors.green : Colors.red,
        onPressed: _toggleConnection,
        child: Icon(
          _isConnected ? Icons.wifi : Icons.wifi_off,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SensorData {
  double? tdsValue;
  double? waterflow1Value;
  double? waterflow1speed;
  double? waterflow2Value;
  double? waterflow2speed;
  double? ultrasonicValue;
}
