import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class UltrasonicMonitor extends StatelessWidget {
  final double ultrasonicValue;

  const UltrasonicMonitor({required this.ultrasonicValue, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentage = calculatePercentage(ultrasonicValue);

    return Container(
      decoration: BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Water Level Monitor',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.blue.withOpacity(0.3),
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LiquidLinearProgressIndicator(
                      value: percentage / 100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.withOpacity(0.7),
                      ),
                      backgroundColor: Colors.blue[50],
                      borderRadius: 30,
                      direction: Axis.vertical,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${ultrasonicValue.toStringAsFixed(1)} cm',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 190,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      8,
                      (index) => Expanded(
                        child: Text(
                          '${(35 - index * 5).toString()} cm',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Water Level: ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double calculatePercentage(double distance) {
  if (distance <= 2) {
    return 100;
  } else if (distance >= 35) {
    return 0;
  } else {
    return 100 - ((distance - 2) / (35 - 2)) * 100;
  }
}
