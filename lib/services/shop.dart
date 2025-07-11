import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShopService {
  final String apiUrl = dotenv.env['ITEM_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();

  // Create item via HTTP POST (아이템 생성 요청)
  Future<void> itemCreate(String userId, String itemTitle, String itemContents,
      double itemPrice, XFile? imageFile) async {
    try {
      String? base64Image;
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      // Send create request with payload (생성 요청 전송)
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'create',
          'userId': userId,
          'itemTitle': itemTitle,
          'itemContents': itemContents,
          'itemPrice': itemPrice,
          'fileContent': base64Image ?? '',
        }),
      );

      // Check for success status code (정상 응답 코드 확인)
      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to create item');
      }
    } catch (error) {
      print('Error creating item: $error');
    }
  }

  // Read item list from server (서버로부터 아이템 목록 조회)
  Future<List<Map<String, dynamic>>> itemRead() async {
    try {
      // Send read request (조회 요청 전송)
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'read'}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Deserialize response into list of maps (응답을 Map 리스트로 디코딩)
        return (data as List)
            .map((item) => {
                  'itemId': item['itemId'],
                  'username': item['userName'],
                  'itemTitle': item['itemTitle'],
                  'itemPrice': item['itemPrice'],
                  'itemContents': item['itemContents'],
                  'photo': item['itemImgURL'],
                  'userImgURL': item['userImgURL'],
                  'userId': item['userId'],
                })
            .toList();
      } else {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to fetch items');
      }
    } catch (error) {
      print('Error fetching items: $error');
      return [];
    }
  }

  // Update item via HTTP POST (아이템 수정 요청)
  Future<void> itemUpdate(String itemId, String userId, String itemTitle,
      String itemContents, double itemPrice, XFile? imageFile) async {
    try {
      String? base64Image;
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }
      // Send update request (수정 요청 전송)
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'update',
          'itemId': itemId,
          'userId': userId,
          'itemTitle': itemTitle,
          'itemContents': itemContents,
          'itemPrice': itemPrice,
          'fileContent': base64Image ?? '',
        }),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to update item');
      }
    } catch (error) {
      print('Error updating item: $error');
    }
  }

  // Delete item via HTTP POST (아이템 삭제 요청)
  Future<void> itemDelete(String itemId, String userId) async {
    try {
      // Send delete request (삭제 요청 전송)
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'delete',
          'itemId': itemId,
          'userId': userId,
        }),
      );
      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to delete item');
      }
    } catch (error) {
      print('Error deleting item: $error');
    }
  }
}
