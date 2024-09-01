import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PurchaseService {
  final String apiUrl = dotenv.env['PURCHASE_FUNC_URL']!;

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

    if (response.statusCode != 200) {
      throw Exception('Failed to create purchase');
    }
  }
}
