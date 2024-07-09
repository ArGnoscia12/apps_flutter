import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:beta_app1/widget/control/config.dart';
import 'package:beta_app1/widget/control/ui_component.dart';
import 'package:beta_app1/widget/control/logic_function.dart';

class ControlScreen extends StatefulWidget {
  final MqttServerClient client;

  ControlScreen({required this.client});

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with AutomaticKeepAliveClientMixin {
  bool isManualMode = true;
  bool _switchPump1 = false;
  bool _switchPump2 = false;
  bool _switchPump3 = false;
  bool _switchUltrasonic = false;
  bool _autoCycleNutrisi = false;

  double tdsMin = 0.0;
  double tdsMax = 0.0;
  double currentTDS = 0.0;
  double ultrasonicLevel = 0.0;

  @override
  void initState() {
    super.initState();

    BusinessLogic.loadPreferences().then((prefs) {
      setState(() {
        _switchPump1 = prefs.getBool('switchPump1') ?? false;
        _switchPump2 = prefs.getBool('switchPump2') ?? false;
        _switchPump3 = prefs.getBool('switchPump3') ?? false;
        _switchUltrasonic = prefs.getBool('switchUltrasonic') ?? false;
        _autoCycleNutrisi = prefs.getBool('autoCycleNutrisi') ?? false;
      });
    });

    BusinessLogic.getTDSValues().then((values) {
      setState(() {
        tdsMin = values['initialTDS'] ?? 0.0;
        tdsMax = values['finalTDS'] ?? 0.0;
      });
    });

    if (widget.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      widget.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        switch (c[0].topic) {
          case 'tds_topic':
            setState(() {
              currentTDS = double.parse(payload);
            });
            break;
          case 'ultrasonic_topic':
            setState(() {
              ultrasonicLevel = double.parse(payload);
            });
            break;
          case 'control':
            setState(() {});
        }
      });

      widget.client.subscribe('tds_topic', MqttQos.atMostOnce);
      widget.client.subscribe('ultrasonic_topic', MqttQos.atMostOnce);
      widget.client.subscribe('control', MqttQos.atMostOnce);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Koneksi MQTT'),
              content: Text('Tolong hubungkan dengan MQTT terlebih dahulu'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  void handleManualSwitchChange(int pumpNumber, bool value) {
    if (widget.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      setState(() {
        switch (pumpNumber) {
          case 1:
            _switchPump1 = value;
            break;
          case 2:
            _switchPump2 = value;
            break;
          case 3:
            _switchPump3 = value;
            break;
          case 4:
            _switchUltrasonic = value;
            break;
        }
      });
      BusinessLogic.publishMessage(widget.client, Config.manualControlTopic,
          value ? 'on$pumpNumber' : 'off$pumpNumber');
      BusinessLogic.savePreferences({
        'switchPump1': _switchPump1,
        'switchPump2': _switchPump2,
        'switchPump3': _switchPump3,
        'switchUltrasonic': _switchUltrasonic,
        'autoCycleNutrisi': _autoCycleNutrisi,
      });
    } else {
      _showMQTTDisconnectedDialog();
    }
  }

  void handleAutoSwitchChange(bool value) {
    if (widget.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      setState(() {
        _autoCycleNutrisi = value;
      });
      BusinessLogic.publishMessage(widget.client, Config.manualControlTopic,
          value ? 'onAuto' : 'offAuto');
      BusinessLogic.savePreferences({
        'autoCycleNutrisi': _autoCycleNutrisi,
      });
    } else {
      _showMQTTDisconnectedDialog();
    }
  }

  void _showMQTTDisconnectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Koneksi MQTT'),
          content: Text('Tolong hubungkan dengan MQTT terlebih dahulu'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalibrationDialog(
          initialTDS: tdsMin,
          finalTDS: tdsMax,
          onSave: (initialTDS, finalTDS) {
            setState(() {
              tdsMin = initialTDS;
              tdsMax = finalTDS;
            });
            BusinessLogic.saveTDSValues(initialTDS, finalTDS);
          },
          mqttClient: widget.client,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ModeSwitch(
                isManualMode: isManualMode,
                onModeChanged: (mode) {
                  setState(() {
                    isManualMode = mode;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (isManualMode) ...[
                ControlButton(
                  title: 'Pompa 1',
                  subtitle: 'Pompa mengarah ke sensor TDS',
                  isActive: _switchPump1,
                  onPressed: () {
                    handleManualSwitchChange(1, !_switchPump1);
                  },
                  activeIcon: Icons.power,
                  inactiveIcon: Icons.power_off,
                ),
                SizedBox(height: 16.0),
                ControlButton(
                  title: 'Pompa 2',
                  subtitle: 'Pompa Nutrisi A dan sensor waterflow 1',
                  isActive: _switchPump2,
                  onPressed: () {
                    handleManualSwitchChange(2, !_switchPump2);
                  },
                  activeIcon: Icons.power,
                  inactiveIcon: Icons.power_off,
                ),
                SizedBox(height: 16.0),
                ControlButton(
                  title: 'Pompa 3',
                  subtitle: 'Pompa Nutrisi B dan sensor waterflow 2',
                  isActive: _switchPump3,
                  onPressed: () {
                    handleManualSwitchChange(3, !_switchPump3);
                  },
                  activeIcon: Icons.power,
                  inactiveIcon: Icons.power_off,
                ),
                SizedBox(height: 16.0),
                ControlButton(
                  title: 'Sensor Ultrasonic',
                  subtitle: 'Sensor untuk mendeteksi level air',
                  isActive: _switchUltrasonic,
                  onPressed: () {
                    handleManualSwitchChange(4, !_switchUltrasonic);
                  },
                  activeIcon: Icons.sensors,
                  inactiveIcon: Icons.sensors_off,
                ),
              ] else ...[
                ControlButton(
                  title: 'Siklus Nutrisi Otomatis',
                  subtitle: 'Mengatur siklus nutrisi secara otomatis',
                  isActive: _autoCycleNutrisi,
                  onPressed: () {
                    handleAutoSwitchChange(!_autoCycleNutrisi);
                  },
                  activeIcon: Icons.autorenew,
                  inactiveIcon: Icons.autorenew,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    showCalibrationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 10.0,
                    shadowColor: Colors.green.shade200,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science, color: Colors.white, size: 24.0),
                      SizedBox(width: 10.0),
                      Text(
                        'Kalibrasi TDS',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
