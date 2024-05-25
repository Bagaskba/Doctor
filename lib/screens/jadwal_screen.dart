import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class JadwalScreen extends StatefulWidget {
  @override
  _JadwalScreenState createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  List _schedules = [];
  int _selectedIndex = 1;
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedTopBar = 'jadwal_dokter';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchSchedules() async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Token not available');
        throw Exception('Token is not available'); // Token tidak tersedia
      } else {
        print('Token: $token'); // Mencetak token ke terminal
      }

      final response = await http.post(
        Uri.parse('https://nexacaresys.codeplay.id/api/doctor'),
        headers: {
          'Content-Type': 'application/json',
          'token': '$token',
          'Authorization': 'Inherit auth from parent',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _schedules = data['response']['data'];
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/jadwal');
        break;
      case 2:
        // Add navigation to chat screen when implemented
        break;
      case 3:
        // Add navigation to profile screen when implemented
        break;
    }
  }

  Widget _buildTopBarButton(String text, String value) {
    bool isActive = _selectedTopBar == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTopBar = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Color.fromARGB(255, 222, 250, 255) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopBarButton('Dibatalkan', 'dibatalkan'),
                _buildTopBarButton('Jadwal Dokter', 'jadwal_dokter'),
                _buildTopBarButton('Semua', 'semua'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final doctor = _schedules[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                                'lib/images/logonexa.png'), // Ganti dengan image yang sesuai
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor['nama'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  doctor['jenis'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Tanggal: ' +
                                          (doctor['tanggal'] ?? 'N/A'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Jadwal: ' + (doctor['jadwal'] ?? 'N/A'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: 295,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      print('Detail halaman index $index');
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(230, 255, 255, 255)),
                                    child: Text(
                                      'Detail',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            gap: 8,
            padding: EdgeInsets.all(16),
            color: Colors.blue,
            activeColor: Colors.blue,
            onTabChange: _onTabChange,
            selectedIndex: _selectedIndex,
            tabBackgroundColor: Color.fromARGB(111, 66, 164, 245),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.calendar_today,
                text: 'Jadwal',
              ),
              GButton(
                icon: Icons.message,
                text: 'Chat',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
