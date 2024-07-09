import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';

class BusinessLogic {
  static Future<SharedPreferences> loadPreferences() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> savePreferences(Map<String, bool> prefs) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    prefs.forEach((key, value) async {
      await sharedPrefs.setBool(key, value);
    });
  }

  static void publishMessage(
      MqttServerClient client, String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  static Future<void> saveTDSValues(double initialTDS, double finalTDS) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('initialTDS', initialTDS);
    await prefs.setDouble('finalTDS', finalTDS);
  }

  static Future<Map<String, double>> getTDSValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final initialTDS = prefs.getDouble('initialTDS') ?? 0.0;
    final finalTDS = prefs.getDouble('finalTDS') ?? 0.0;
    return {
      'initialTDS': initialTDS,
      'finalTDS': finalTDS,
    };
  }
}
