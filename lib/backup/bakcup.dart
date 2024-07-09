// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:mqtt_client/mqtt_client.dart';

// import 'package:beta_app1/login/api_service.dart';
// import 'package:beta_app1/login/user.dart';
// import 'package:beta_app1/login/login.dart';
// import 'package:beta_app1/page/control.dart';
// import 'package:beta_app1/page/monitoring.dart';
// import 'package:beta_app1/page/info.dart';
// import 'package:beta_app1/page/homecontent.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//   bool _isConnected = false;
//   late MqttServerClient _client;
//   final ApiService apiService = ApiService();

//   List<Widget> _children = [];
//   @override
//   void initState() {
//     super.initState();
//     _initializeClient();
//   }

//   void _initializeClient() async {
//     final broker = '192.168.0.111';
//     final port = 1883; // MQTT default port
//     final clientId = 'Mqqt_Flutter';

//     _client = MqttServerClient(broker, clientId);
//     _client.port = port;
//     _client.keepAlivePeriod = 20;
//     _client.connectTimeoutPeriod = 2000;
//     _client.onConnected = _onConnected;

//     // Membuat objek MqttConnectMessage dengan autentikasi
//     final connMess = MqttConnectMessage()
//         .withClientIdentifier(clientId)
//         .withWillTopic('willtopic')
//         .withWillMessage('My Will message')
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);
//     print('EXAMPLE::Mosquitto client Connecting....');
//     _client.connectionMessage = connMess;

//     try {
//       await _client.connect();
//       setState(() {
//         _isConnected = true;
//       });
//     } catch (e) {
//       print('Exception: $e');
//       _showErrorDialog('Failed to connect to MQTT broker');
//     }

//     _children = [
//       HomeContent(),
//       SensorMonitoringScreen(),
//       ControlScreen(
//         client: _client,
//       ),
//       InfoScreen(),
//     ];
//   }

//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   Future<void> removeAuthToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auth_token');
//   }

//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');

//     if (token != null) {
//       try {
//         await apiService.logout(token);
//         await removeAuthToken();
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage()),
//         );
//       } catch (e) {
//         _showErrorDialog('Failed to logout. Please try again');
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Ok'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _toggleConnection() async {
//     if (_isConnected) {
//       _client.disconnect();
//       setState(() {
//         _isConnected = false;
//       });
//     } else {
//       final broker = '192.168.0.111';
//       final port = 1883; // MQTT default port
//       final clientId = 'Mqqt_Flutter';

//       _client = MqttServerClient(broker, clientId);
//       _client.port = port;
//       _client.keepAlivePeriod = 20;
//       _client.connectTimeoutPeriod = 2000;
//       _client.onConnected = _onConnected;

//       // Membuat objek MqttConnectMessage dengan autentikasi
//       final connMess = MqttConnectMessage()
//           .withClientIdentifier(clientId)
//           .withWillTopic('willtopic')
//           .withWillMessage('My Will message')
//           .startClean()
//           .withWillQos(MqttQos.atLeastOnce);
//       print('EXAMPLE::Mosquitto client Connecting....');
//       _client.connectionMessage = connMess;

//       try {
//         await _client.connect();
//         setState(() {
//           _isConnected = true;
//         });
//       } catch (e) {
//         print('Exception: $e');
//         _showErrorDialog('Failed to connect to MQTT broker');
//       }
//     }
//   }

//   void _onConnected() {
//     print('Connected');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           ['Dashboard', 'Monitoring', 'Control', 'Info'][_currentIndex],
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       drawer: Drawer(
//         child: FutureBuilder<List<User>>(
//           future: apiService.fetchUsers(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               List<User>? users = snapshot.data;
//               return ListView(
//                 padding: EdgeInsets.zero,
//                 children: <Widget>[
//                   UserAccountsDrawerHeader(
//                     accountName: Text(users!.first.fullname),
//                     accountEmail: Text(users.first.username),
//                     currentAccountPicture: CircleAvatar(
//                       backgroundImage: AssetImage('images/ahri_icon.jpg'),
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                     ),
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.logout),
//                     title: Text('Logout'),
//                     onTap: _logout,
//                   ),
//                 ],
//               );
//             } else if (snapshot.hasError) {
//               return Text('${snapshot.error}');
//             }
//             return Center(child: CircularProgressIndicator());
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           AnimatedSwitcher(
//             duration: Duration(milliseconds: 300),
//             child: _children[_currentIndex],
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: onTabTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_filled),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.monitor),
//             label: 'Monitor',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Control',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.info),
//             label: 'Info',
//           ),
//         ],
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.green,
//         unselectedItemColor: Colors.grey,
//         showSelectedLabels: true,
//         showUnselectedLabels: false,
//         selectedLabelStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _toggleConnection,
//         child: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
//         backgroundColor: _isConnected ? Colors.green : Colors.red,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }


// <?php
// $servername = "localhost";
// $username = "username";
// $password = "password";
// $dbname = "database_name";

// // Create connection
// $conn = new mysqli($servername, $username, $password, $dbname);

// // Check connection
// if ($conn->connect_error) {
//     die("Connection failed: " . $conn->connect_error);
// }

// // Query to get data from the first table
// $sql1 = "SELECT x, y1, y2 FROM table1";
// $result1 = $conn->query($sql1);

// $data1 = array();
// if ($result1->num_rows > 0) {
//     while($row = $result1->fetch_assoc()) {
//         $data1[] = $row;
//     }
// }

// // Query to get data from the second table
// $sql2 = "SELECT x, y FROM table2";
// $result2 = $conn->query($sql2);

// $data2 = array();
// if ($result2->num_rows > 0) {
//     while($row = $result2->fetch_assoc()) {
//         $data2[] = $row;
//     }
// }

// $conn->close();

// header('Content-Type: application/json');
// echo json_encode(array('table1' => $data1, 'table2' => $data2));
// ?>


// import 'package:flutter/material.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';

// import 'package:beta_app1/widget/monitoring/TdsMonitor.dart';
// import 'package:beta_app1/widget/monitoring/WaterflowMonitoring.dart';
// import 'package:beta_app1/widget/monitoring/Ultrasonik.dart';

// class SensorMonitoringScreen extends StatefulWidget {
//   final MqttServerClient client;

//   SensorMonitoringScreen({required this.client});

//   @override
//   _SensorMonitoringScreenState createState() => _SensorMonitoringScreenState();
// }

// class _SensorMonitoringScreenState extends State<SensorMonitoringScreen> {
//   double? tdsValue;
//   double? waterflow1Value;
//   double? waterflow2Value;
//   double? ultrasonicValue;

//   @override
//   void initState() {
//     super.initState();
//     _subscribeToTopics();
//   }

//   void _subscribeToTopics() {
//     if (widget.client.connectionStatus!.state ==
//         MqttConnectionState.connected) {
//       widget.client.subscribe('tds_topic', MqttQos.atMostOnce);
//       widget.client.subscribe('waterflow1_topic', MqttQos.atLeastOnce);
//       widget.client.subscribe('waterflow2_topic', MqttQos.atLeastOnce);
//       widget.client.subscribe('ultrasonic_topic', MqttQos.atLeastOnce);

//       widget.client.updates!.listen(
//         (List<MqttReceivedMessage<MqttMessage?>> messages) {
//           final message = messages[0].payload as MqttPublishMessage;
//           final payload =
//               MqttPublishPayload.bytesToStringAsString(message.payload.message);

//           double? value;
//           try {
//             value = double.parse(payload);
//           } catch (e) {
//             print('Error parsing payload: $e');
//           }

//           setState(() {
//             switch (messages[0].topic) {
//               case 'tds_topic':
//                 tdsValue = value;
//                 break;
//               case 'waterflow1_topic':
//                 waterflow1Value = value;
//                 break;
//               case 'waterflow2_topic':
//                 waterflow2Value = value;
//                 break;
//               case 'ultrasonic_topic':
//                 ultrasonicValue = value;
//                 break;
//               default:
//                 print('Unknown topic: ${messages[0].topic}');
//             }
//           });
//         },
//       );
//     } else {
//       print('MQTT Client is not connected');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 0,
//         titleSpacing: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TDSMonitor(value: tdsValue ?? 0.0),
//               SizedBox(height: 16.0),
//               WaterflowMonitor(
//                 waterflow1Value: waterflow1Value ?? 0.0,
//                 waterflow2Value: waterflow2Value ?? 0.0,
//               ),
//               SizedBox(height: 16.0),
//               UltrasonicMonitor(
//                 ultrasonicValue: ultrasonicValue ?? 0.0,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class UltrasonicMonitor extends StatelessWidget {
//   final double value;

//   UltrasonicMonitor({required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Ultrasonic',
//             style: TextStyle(
//               fontSize: 18.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(
//             height: 200.0, // Tinggi maksimum container
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: [
//                 Container(
//                   width: 50.0,
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(
//                       maxHeight: 200.0), // Batasi tinggi maksimum
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 500),
//                     width: 50.0,
//                     height: value * 2, // Ubah menjadi nilai yang sesuai
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: value * 2 + 8.0, // Ubah menjadi nilai yang sesuai
//                   child: Text(
//                     '${value.toStringAsFixed(2)} cm',
//                     style: TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }