import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  Future<Map<String, dynamic>> readUser(String userId) async {
    final url = dotenv.env['USER_FUNC_URL'];
    final response = await http.post(
      Uri.parse(url!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': 'read', 'userId': userId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {'success': true, 'data': data['user']};
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'success': false, 'error': errorData['error']};
    }
  }
}
