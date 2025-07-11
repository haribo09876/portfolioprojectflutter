import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PurchaseService {
  final String apiUrl = dotenv.env['PURCHASE_FUNC_URL']!;

// Sends HTTP POST request to create a purchase record (구매 레코드 생성을 위한 HTTP POST 요청 전송)
  Future<void> purchaseCreate(String userId, String itemId) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'action': 'create',
        'userId': userId,
        'itemId': itemId,
        'purchaseStatus': 1,
      }),
    );

    // Throw exception if request fails (요청 실패 시 예외 발생)
    if (response.statusCode != 200) {
      throw Exception('Failed to create purchase');
    }
  }
}
