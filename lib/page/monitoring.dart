import 'dart:async';
import 'dart:convert';
import 'package:beta_app1/widget/monitoring/Ultrasonik.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:beta_app1/widget/monitoring/TdsMonitor.dart';
import 'package:beta_app1/widget/monitoring/WaterflowMonitoring.dart';

// Instance global dari SensorData
final sensorData = SensorData();

class SensorMonitoringScreen extends StatefulWidget {
  final MqttServerClient client;

  SensorMonitoringScreen({required this.client});

  @override
  _SensorMonitoringScreenState createState() => _SensorMonitoringScreenState();
}

class _SensorMonitoringScreenState extends State<SensorMonitoringScreen> {
  late StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>?
      subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToTopics();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  void _subscribeToTopics() {
    if (widget.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      widget.client.subscribe('sensor/tds', MqttQos.atMostOnce);
      widget.client.subscribe('sensor/waterflow1', MqttQos.atLeastOnce);
      widget.client.subscribe('sensor/waterflow2', MqttQos.atLeastOnce);
      widget.client.subscribe('sensor/ultrasonic', MqttQos.atLeastOnce);

      subscription = widget.client.updates!.listen(
        (List<MqttReceivedMessage<MqttMessage?>> messages) async {
          final message = messages[0].payload as MqttPublishMessage;
          final payload =
              MqttPublishPayload.bytesToStringAsString(message.payload.message);

          if (messages[0].topic == 'sensor/waterflow1' ||
              messages[0].topic == 'sensor/waterflow2') {
            // Parsing JSON payload untuk waterflow1_topic atau waterflow2_topic
            try {
              Map<String, dynamic> data = jsonDecode(payload);
              double? flowRatePerSecond =
                  (data['speed_waterflow'] as num?)?.toDouble();
              double? totalFlow = (data['total_cairan'] as num?)?.toDouble();

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
            } catch (e) {
              print('Error parsing JSON payload for ${messages[0].topic}: $e');
            }
          } else {
            // Parsing string payload untuk topik lainnya
            try {
              double? value = double.parse(payload);

              if (mounted) {
                setState(() {
                  switch (messages[0].topic) {
                    case 'sensor/tds':
                      sensorData.tdsValue = value;
                      break;
                    case 'sensor/ultrasonic':
                      sensorData.ultrasonicValue = value;
                      break;
                    default:
                      print('Unknown topic: ${messages[0].topic}');
                  }
                });
              }
            } catch (e) {
              print(
                  'Error parsing string payload for ${messages[0].topic}: $e');
            }
          }
        },
      );
    } else {
      print('MQTT Client is not connected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TDSMonitor(value: sensorData.tdsValue ?? 0.0),
              SizedBox(height: 16.0),
              WaterflowMonitor(
                waterflow1Value: sensorData.waterflow1Value ?? 0.0,
                waterflow2Value: sensorData.waterflow2Value ?? 0.0,
                waterflow1Speed: sensorData.waterflow1speed ?? 0.0,
                waterflow2Speed: sensorData.waterflow2speed ?? 0.0,
              ),
              SizedBox(height: 16.0),
              UltrasonicMonitor(
                ultrasonicValue: sensorData.ultrasonicValue ?? 0.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorData {
  double? tdsValue;
  double? waterflow1Value;
  double? waterflow2Value;
  double? ultrasonicValue;
  double? waterflow1speed;
  double? waterflow2speed;
}
