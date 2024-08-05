import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SignupService {
  final String signupUrl = dotenv.env['USER_FUNC_URL']!;

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
        return {'status': 'exists', 'data': data};
      } else {
        return {'status': 'not_exists'};
      }
    } else {
      return {'status': 'error', 'message': jsonDecode(response.body)['error']};
    }
  }

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
