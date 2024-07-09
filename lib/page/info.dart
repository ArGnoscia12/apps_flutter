import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _infoList = [];
  List<Map<String, dynamic>> _filteredInfoList = [];

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  Future<void> _fetchPlants() async {
    final prefs = await SharedPreferences.getInstance();
    String mqttServerIp = prefs.getString('mqtt_server_ip') ?? '192.168.1.100';
    String url = 'http://$mqttServerIp/test_api/data_plant.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _infoList = data.map((item) => item as Map<String, dynamic>).toList();
          _filteredInfoList = List<Map<String, dynamic>>.from(_infoList);
        });
      } else {
        print('Gagal mengambil data tanaman: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _searchInfo(String query) {
    final filteredList = _infoList.where((info) {
      final titleLower = info['title']?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredInfoList = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            onChanged: _searchInfo,
            decoration: InputDecoration(
              hintText: 'Cari tanaman...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _filteredInfoList.length,
        itemBuilder: (context, index) {
          final info = _filteredInfoList[index];
          IconData icon;
          Color color;
          switch (info['kategori']) {
            case 'Sayur':
              icon = Icons.eco;
              color = Colors.green;
              break;
            case 'Bunga':
              icon = Icons.filter_vintage;
              color = Colors.red;
              break;
            case 'Herb':
              icon = Icons.emoji_nature;
              color = Colors.blue;
              break;
            default:
              icon = Icons.category;
              color = Colors.black;
          }

          return InfoCard(
            title: info['title'] ?? 'No Title',
            icon: icon,
            color: color,
            imageUrl: info['img'] ?? 'assets/placeholder.jpg',
            info: info,
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String imageUrl;
  final Map<String, dynamic> info;

  const InfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.imageUrl,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              title: info['title'] ?? 'No Title',
              description: info['desk'] ?? 'No Description',
              imageUrl: info['img'] ?? 'assets/placeholder.jpg',
              category: info['kategori'] ?? 'Unknown',
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.error, color: Colors.red)),
                ),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Row(
                children: [
                  Icon(icon, color: color),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String category;

  const DetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.error, color: Colors.red)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Category: $category',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              buildDescriptionText(description),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDescriptionText(String description) {
    List<String> paragraphs = description.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: '     ', // Add indentation (5 spaces) at the start
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5, // Line height
              ),
              children: [
                TextSpan(
                  text: paragraph,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5, // Line height
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
