import 'package:flutter/material.dart';

class WaterflowMonitor extends StatelessWidget {
  final double waterflow1Value;
  final double waterflow2Value;
  final double waterflow1Speed;
  final double waterflow2Speed;

  WaterflowMonitor({
    required this.waterflow1Value,
    required this.waterflow2Value,
    required this.waterflow1Speed,
    required this.waterflow2Speed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Waterflow 1',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: waterflow1Value / 500,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(height: 4.0),
                Text(
                  '${waterflow1Value.toStringAsFixed(1)} mL',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Speed: ${waterflow1Speed.toStringAsFixed(1)} mL/s',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Colors.orangeAccent,
                      size: 24,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Waterflow 2',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: waterflow2Value / 500,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                  backgroundColor: Colors.orange[100],
                ),
                SizedBox(height: 4.0),
                Text(
                  '${waterflow2Value.toStringAsFixed(1)} mL',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Speed: ${waterflow2Speed.toStringAsFixed(1)} mL/s',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
