import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  Map<String, dynamic>? _userInfo;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  Map<String, dynamic>? get userInfo => _userInfo;

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
      _userInfo = {
        'id': data['user']['userId'],
        'email': data['user']['userEmail'],
        'password': data['user']['userPassword'],
        'name': data['user']['userName'],
        'gender': data['user']['userGender'],
        'age': data['user']['userAge'],
        'imgURL': data['user']['userImgURL'],
        'money': data['user']['userMoney'],
        'spend': data['user']['userSpend'],
      };
      await _saveUserData(email, password);
      return {'success': true, 'data': data};
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'success': false, 'error': errorData['error']};
    }
  }

  Future<void> logoutUser() async {
    _isLoggedIn = false;
    _userEmail = null;
    _userInfo = null;
    await _clearUserData();
    notifyListeners();
  }

  Future<void> _saveUserData(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
    await prefs.setString('userPassword', password);
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userPassword');
  }

  void setUserData(String email) {
    _isLoggedIn = true;
    _userEmail = email;
    notifyListeners();
  }
}
