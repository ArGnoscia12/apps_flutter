import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showHistory = false;
                      });
                    },
                    child: Text(
                      'Charts',
                      style: TextStyle(
                        fontSize: 12,
                        color: !_showHistory ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_showHistory ? Colors.green[800] : Colors.grey[300],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _showHistory ? HistorySection() : ChartsSection(),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChartsSection extends StatefulWidget {
  @override
  _ChartsSectionState createState() => _ChartsSectionState();
}

class _ChartsSectionState extends State<ChartsSection> {
  List<_ChartData> waterflow1Data = [];
  List<_ChartData> waterflow2Data = [];
  List<_ChartData> tdsSensorData = [];
  List<_ChartData> ultrasonikData = [];
  bool isLoading = true;
  String errorMessage = '';

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    String start = "${startDate.toIso8601String().split('T')[0]} 00:00:00";
    String end = "${endDate.toIso8601String().split('T')[0]} 23:59:59";

    try {
      final prefs = await SharedPreferences.getInstance();
      String mqttServerIp =
          prefs.getString('mqtt_server_ip') ?? '192.168.48.153';
      String url =
          'http://$mqttServerIp/test_api/data_chart.php?start_date=$start&end_date=$end';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> data = responseData['tb_waterflow1'] ?? [];
        List<dynamic> data1 = responseData['tb_waterflow2'] ?? [];
        List<dynamic> data2 = responseData['tb_ppm'] ?? [];
        List<dynamic> data3 = responseData['tb_waterlevel'] ?? [];
        setState(() {
          waterflow1Data = data
              .map((item) =>
                  _ChartData(int.parse(item['x']), double.parse(item['y1'])))
              .toList();
          waterflow2Data = data1
              .map((item) =>
                  _ChartData(int.parse(item['x']), double.parse(item['y2'])))
              .toList();
          tdsSensorData = data2
              .map((item) =>
                  _ChartData(int.parse(item['x']), double.parse(item['y3'])))
              .toList();
          ultrasonikData = data3
              .map((item) =>
                  _ChartData(int.parse(item['x']), double.parse(item['y'])))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null &&
        picked != DateTimeRange(start: startDate, end: endDate)) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        fetchChartData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _selectDateRange(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, color: Colors.green[800]),
                  SizedBox(width: 10),
                  Text(
                    "Select Date Range",
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(child: Text(errorMessage))
            else ...[
              buildChartSection(
                title: 'Waterflow Charts',
                chart: buildWaterflowChart(),
              ),
              const SizedBox(height: 30),
              buildChartSection(
                title: 'TDS Charts',
                chart: buildTDSChart(),
              ),
              const SizedBox(height: 30),
              buildChartSection(
                title: 'Ultrasonic Charts',
                chart: buildUltrasonicChart(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildChartSection({required String title, required Widget chart}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 300,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: chart,
        ),
      ],
    );
  }

  Widget buildWaterflowChart() {
    return SfCartesianChart(
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
      ),
      primaryXAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 2, color: Colors.grey[700]),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 1000,
        interval: 200,
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        axisLine: AxisLine(width: 0),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
      series: <ChartSeries>[
        AreaSeries<_ChartData, int>(
          name: 'Waterflow 1',
          dataSource: waterflow1Data,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          color: Colors.purple.withOpacity(0.3),
          borderColor: Colors.purple,
          borderWidth: 2,
        ),
        AreaSeries<_ChartData, int>(
          name: 'Waterflow 2',
          dataSource: waterflow2Data,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          color: Colors.orange.withOpacity(0.3),
          borderColor: Colors.orange,
          borderWidth: 2,
        ),
      ],
    );
  }

  Widget buildTDSChart() {
    return SfCartesianChart(
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
      ),
      primaryXAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 2, color: Colors.grey[700]),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 1500,
        interval: 200,
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        axisLine: AxisLine(width: 0),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
      series: <ChartSeries>[
        AreaSeries<_ChartData, int>(
          name: 'TDS Sensor',
          dataSource: tdsSensorData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          color: Colors.blue.withOpacity(0.3),
          borderColor: Colors.blue,
          borderWidth: 2,
        ),
      ],
    );
  }

  Widget buildUltrasonicChart() {
    return SfCartesianChart(
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
      ),
      primaryXAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 2, color: Colors.grey[700]),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100,
        interval: 10,
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        axisLine: AxisLine(width: 0),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
      series: <ChartSeries>[
        AreaSeries<_ChartData, int>(
          name: 'Ultrasonic',
          dataSource: ultrasonikData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          color: Colors.green.withOpacity(0.3),
          borderColor: Colors.green,
          borderWidth: 2,
        ),
      ],
    );
  }
}

class HistorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Feature in development...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final int x;
  final double y;

  _ChartData(this.x, this.y);
}
