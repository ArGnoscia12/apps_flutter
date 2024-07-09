// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SwitchTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchTileWidget({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required IconData icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class ModeSwitch extends StatelessWidget {
  final bool isManualMode;
  final ValueChanged<bool> onModeChanged;

  const ModeSwitch({
    required this.isManualMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            onModeChanged(true);
          },
          child: Text(
            'Mode Manual',
            style: TextStyle(
              fontSize: 12,
              color: isManualMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isManualMode ? Colors.green[800] : Colors.grey[300],
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            onModeChanged(false);
          },
          child: Text(
            'Mode Otomatis',
            style: TextStyle(
              fontSize: 12,
              color: isManualMode ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isManualMode ? Colors.grey[300] : Colors.green[800],
          ),
        ),
      ],
    );
  }
}

class CalibrationDialog extends StatefulWidget {
  final double initialTDS;
  final double finalTDS;
  final Function(double, double) onSave;
  final MqttServerClient mqttClient;

  CalibrationDialog({
    required this.initialTDS,
    required this.finalTDS,
    required this.onSave,
    required this.mqttClient,
  });

  @override
  _CalibrationDialogState createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends State<CalibrationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController initialTDSController;
  late TextEditingController finalTDSController;
  late MqttServerClient mqttClient;

  @override
  void initState() {
    super.initState();
    initialTDSController = TextEditingController(
      text: widget.initialTDS.toString(),
    );
    finalTDSController = TextEditingController(
      text: widget.finalTDS.toString(),
    );
    mqttClient = widget.mqttClient;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text(
                    'Kalibrasi Parameter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: initialTDSController,
                    decoration: const InputDecoration(
                      labelText: 'TDS min',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan TDS minimal';
                      }
                      double? initialTDS = double.tryParse(value);
                      double? finalTDS =
                          double.tryParse(finalTDSController.text);
                      if (initialTDS == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (finalTDS != null && initialTDS > finalTDS) {
                        return 'TDS min tidak boleh lebih besar dari TDS max';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: finalTDSController,
                    decoration: const InputDecoration(
                      labelText: 'TDS max',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan TDS maximum';
                      }
                      double? finalTDS = double.tryParse(value);
                      double? initialTDS =
                          double.tryParse(initialTDSController.text);
                      if (finalTDS == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (initialTDS != null && finalTDS < initialTDS) {
                        return 'TDS max tidak boleh lebih kecil dari TDS min';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final initialTDS =
                            double.parse(initialTDSController.text);
                        final finalTDS = double.parse(finalTDSController.text);

                        sendToMQTT(initialTDS, finalTDS);

                        widget.onSave(initialTDS, finalTDS);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Simpan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendToMQTT(double initialTDS, double finalTDS) {
    final payload = jsonEncode({"tdsmin": initialTDS, "tdsmax": finalTDS});
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    mqttClient.publishMessage(
        'parameter', MqttQos.exactlyOnce, builder.payload!);
  }
}

class ControlButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onPressed;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const ControlButton({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onPressed,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (_) => onPressed(),
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
