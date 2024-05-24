import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalScreen extends StatefulWidget {
  @override
  _JadwalScreenState createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  List _schedules = [];

  Future<void> _fetchSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('https://nexacaresys.codeplay.id/api/schedules'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _schedules = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load schedules')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedules')),
      body: ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_schedules[index]['tanggal']),
            subtitle: Text(
                '${_schedules[index]['nama']} - ${_schedules[index]['jadwal']}'),
          );
        },
      ),
    );
  }
}
