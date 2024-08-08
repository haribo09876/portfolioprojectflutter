import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class LoginService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = dotenv.env['USER_FUNC_URL'];
    final response = await http.post(
      Uri.parse(url!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'action': 'login', 'userEmail': email, 'userPassword': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      _isLoggedIn = true;
      _userEmail = data['user']['userEmail'];
      return {'success': true, 'data': data};
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'success': false, 'error': errorData['error']};
    }
  }

  Future<void> logoutUser() async {
    _isLoggedIn = false;
    _userEmail = null;
    notifyListeners();
  }
}
