import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  Map<String, dynamic>? _userInfo;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  Map<String, dynamic>? get userInfo => _userInfo;

  // Authenticate user via backend API (백엔드 API를 통한 사용자 인증)
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = dotenv.env['USER_FUNC_URL'];
    final response = await http.post(
      Uri.parse(url!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'action': 'login', 'userEmail': email, 'userPassword': password}),
    );

    if (response.statusCode == 200) {
      // parse JSON response (응답 JSON 파싱)
      final Map<String, dynamic> data = jsonDecode(response.body);
      _isLoggedIn = true;
      _userEmail = data['user']['userEmail'];

      // map user attributes from response (응답으로부터 사용자 속성 매핑)
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
      // persist login credentials (로그인 정보 저장)
      await _saveUserData(email, password);
      // return success result (성공 결과 반환)
      return {'success': true, 'data': data};
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'success': false, 'error': errorData['error']};
    }
  }

  // Clear login state and persistent data (로그인 상태 및 저장 데이터 초기화)
  Future<void> logoutUser() async {
    _isLoggedIn = false;
    _userEmail = null;
    _userInfo = null;
    // remove local credentials (로컬 저장 자격 정보 제거)
    await _clearUserData();
    // notify UI listeners (UI 리스너에 변경 사항 알림)
    notifyListeners();
  }

  // Store user credentials locally via SharedPreferences (사용자 자격 정보를 SharedPreferences에 저장)
  Future<void> _saveUserData(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
    await prefs.setString('userPassword', password);
  }

  // Remove stored user credentials (저장된 사용자 자격 정보 제거)
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userPassword');
  }

  // Manually set user login state (수동으로 로그인 상태 설정)
  void setUserData(String email) {
    _isLoggedIn = true;
    _userEmail = email;
    // update UI on change (변경 시 UI 업데이트)
    notifyListeners();
  }
}
