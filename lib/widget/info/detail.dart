import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _infoList = []; // Gunakan dynamic untuk data dinamis
  List<dynamic> _filteredInfoList = [];

  @override
  void initState() {
    super.initState();
    _fetchInfoFromApi();
  }

  Future<void> _fetchInfoFromApi() async {
    final url = Uri.parse(
        'http://your_api_endpoint/plants'); // Ganti dengan endpoint API Anda
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Jika koneksi berhasil
      setState(() {
        _infoList = jsonDecode(response.body);
        _filteredInfoList = _infoList;
      });
    } else {
      // Jika terjadi kesalahan koneksi
      print('Failed to load data: ${response.statusCode}');
    }
  }

  void _searchInfo(String query) {
    final filteredList = _infoList.where((info) {
      final titleLower = info['title']?.toLowerCase() ?? '';
      final descriptionLower = info['description']?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower) ||
          descriptionLower.contains(searchLower);
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

          // Customize sesuai data API Anda
          IconData icon;
          Color color;
          switch (info['category']) {
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
            description: info['description'] ?? 'No Description',
            icon: icon,
            color: color,
            image: info['image'] ?? 'assets/placeholder.jpg',
            info: info,
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String image;
  final dynamic info;

  const InfoCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.image,
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
              description: info['description'] ?? 'No Description',
              image: info['image'] ?? 'assets/placeholder.jpg',
              category: info['category'] ?? 'Unknown',
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                  ),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String category;

  const DetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(image),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Category: $category',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
