import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SignupService {
  final String signupUrl = dotenv.env['USER_FUNC_URL']!;

  // Validate if user already exists in the backend (백엔드에서 사용자 존재 여부 확인)
  Future<Map<String, dynamic>?> checkUser(
      String userEmail, String userName) async {
    final response = await http.post(
      Uri.parse(signupUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'read',
        'userEmail': userEmail,
        'userName': userName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['user'] != null) {
        // Return if user exists (사용자가 존재할 경우 반환)
        return {'status': 'exists', 'data': data};
      } else {
        // Return if user does not exist (사용자가 존재하지 않을 경우 반환)
        return {'status': 'not_exists'};
      }
    } else {
      // Return error from backend (백엔드 오류 반환)
      return {'status': 'error', 'message': jsonDecode(response.body)['error']};
    }
  }

  // Create a new user in the backend (백엔드에 신규 사용자 생성)
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userInfo) async {
    final response = await http.post(
      Uri.parse(signupUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'create',
        ...userInfo,
      }),
    );

    if (response.statusCode == 200) {
      return {'status': 'success', 'message': jsonDecode(response.body)};
    } else {
      return {'status': 'error', 'message': jsonDecode(response.body)['error']};
    }
  }
}
