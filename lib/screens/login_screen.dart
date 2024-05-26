import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nexamobile_app/components/my_button.dart';
import 'package:nexamobile_app/components/text_field.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<void> _login() async {
    try {
      final response = await http
          .post(
            Uri.parse('https://nexacaresys.codeplay.id/api/login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'username': usernameController.text,
              'password': passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final token = responseData['response']['token'];

        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        customAlertDialog("Sukses", "Sukses melakukan login", 'success');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
        customAlertDialog('Gagal', 'Gagal melakukan login', 'error');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
      customAlertDialog('Gagal', 'Gagal melakukan login: $e', 'error');
    }
  }

  // alert

  void customAlertDialog(String title, String message, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                // image nexa
                Image.asset(
                  'lib/images/logonexa.png',
                  width: 300,
                  height: 300,
                ),

                // text
                const Text(
                  'Kesehatan adalah aset berharga',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),

                const SizedBox(
                  height: 80,
                ),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'username',
                  obscureText: false,
                ),

                const SizedBox(
                  height: 25,
                ),

                // pw textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'password',
                  obscureText: true,
                ),

                const SizedBox(
                  height: 100,
                ),

                //btn login
                MyButton(onPressed: _login)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
