import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TDSMonitor extends StatefulWidget {
  final double value;

  TDSMonitor({required this.value});

  @override
  _TDSMonitorState createState() => _TDSMonitorState();
}

class _TDSMonitorState extends State<TDSMonitor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showGauge = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant TDSMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getWaterQuality(double tds) {
    if (tds < 300) return 'Excellent';
    if (tds < 600) return 'Good';
    if (tds < 900) return 'Fair';
    if (tds < 1200) return 'Poor';
    return 'Unacceptable';
  }

  Color getQualityColor(double tds) {
    if (tds < 300) return Colors.blue;
    if (tds < 600) return Colors.green;
    if (tds < 900) return Colors.yellow;
    if (tds < 1200) return Colors.orange;
    return Colors.red;
  }

  Widget _buildGauge(double value) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 1500,
          startAngle: 150,
          endAngle: 30,
          interval: 300,
          labelFormat: '{value}',
          axisLineStyle: AxisLineStyle(
            thickness: 0.2,
            thicknessUnit: GaugeSizeUnit.factor,
            cornerStyle: CornerStyle.bothCurve,
          ),
          majorTickStyle: MajorTickStyle(length: 6, thickness: 2),
          minorTickStyle: MinorTickStyle(length: 3, thickness: 1),
          axisLabelStyle: GaugeTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: value,
              width: 0.2,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: SweepGradient(
                colors: [Colors.green, getQualityColor(value)],
                stops: [0.0, 1.0],
              ),
              cornerStyle: CornerStyle.bothCurve,
            ),
            MarkerPointer(
              value: value,
              markerType: MarkerType.triangle,
              color: Colors.white,
              markerHeight: 15,
              markerWidth: 15,
              markerOffset: -7,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '${value.toStringAsFixed(0)} PPM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getQualityColor(value),
                ),
              ),
              positionFactor: 0.1,
              angle: 90,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleDisplay(double value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: getQualityColor(value),
          ),
        ),
        SizedBox(height: 16),
        Text(
          getWaterQuality(value),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: getQualityColor(value),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showGauge = !_showGauge;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science,
                  size: 30,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  'TDS Monitor',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return AnimatedCrossFade(
                  duration: Duration(milliseconds: 300),
                  firstChild: Container(
                    height: 250,
                    width: 250,
                    child: _buildGauge(_animation.value),
                  ),
                  secondChild: Container(
                    height: 250,
                    width: 250,
                    child: Center(
                      child: _buildSimpleDisplay(_animation.value),
                    ),
                  ),
                  crossFadeState: _showGauge
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Tap to toggle view',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
