import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _doctors = [];
  bool _isLoading = true;
  bool _hasError = false;
  TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  // Fungsi untuk mendapatkan token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchDoctors() async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Token not available');
        throw Exception('Token is not available'); // Token tidak tersedia
      } else {
        print('Token: $token'); // Mencetak token ke terminal
      }

      final response = await http.post(
        Uri.parse('https://nexacaresys.codeplay.id/api/nearby'),
        headers: {
          'Content-Type': 'application/json',
          'token': '$token',
          'Authorization': 'Inherit auth from parent',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed data: $data'); // Print parsed data for debugging

        final dataResponse = data['response']['dataResponse'];

        if (dataResponse is List) {
          setState(() {
            _doctors = dataResponse;
            _hasError = false;
          });
        } else if (dataResponse is Map) {
          setState(() {
            _doctors = [dataResponse];
            _hasError = false;
          });
        } else {
          throw Exception('DataResponse is not a list or a map');
        }
      } else {
        setState(() {
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load doctors: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Failed to load doctors'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello,',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Dimas Okva',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                  'lib/images/logonexa.png'), // Ganti dengan image yang sesuai
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _doctors[index];
                            return Card(
                              color: Colors.blue,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor['nama'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            doctor['jenis'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Tanggal: ' +
                                                    (doctor['tanggal'] ??
                                                        'N/A'),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time,
                                                  size: 14,
                                                  color: Colors.white),
                                              SizedBox(width: 5),
                                              Text(
                                                'Waktu: ' +
                                                    (doctor['jadwal'] ?? 'N/A'),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
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
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari Dokter Spesialis',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  'Dokter',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.medical_information,
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  'Obat & Resep',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.local_hospital,
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  'Rumah Sakit',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Doktor Terdekat',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _doctors[index];
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.orange.shade400,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '4,8 (120 Reviews)',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.orange.shade400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time,
                                                  size: 14, color: Colors.blue),
                                              SizedBox(width: 5),
                                              Text(
                                                'Open at: ' +
                                                    (doctor['jadwal'] ?? 'N/A'),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
                )
              ]),
        ),
      ),
    );
  }
}
