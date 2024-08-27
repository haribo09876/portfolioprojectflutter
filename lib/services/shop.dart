import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShopService {
  final String apiUrl = dotenv.env['ITEM_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();

  Future<void> itemCreate(
      String userId, String itemContents, XFile? imageFile) async {
    try {
      String? base64Image;
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'create',
          'userId': userId,
          'itemContents': itemContents,
          'fileContent': base64Image ?? '',
        }),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to create item');
      }
    } catch (error) {
      print('Error creating item: $error');
    }
  }

  Future<List<Map<String, dynamic>>> itemRead() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'read'}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List)
            .map((item) => {
                  'id': item['itemId'],
                  'username': item['userName'],
                  'item': item['itemContents'],
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

  Future<void> itemUpdate(String itemId, String userId, String itemContents,
      XFile? imageFile) async {
    try {
      String? base64Image;
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'update',
          'itemId': itemId,
          'userId': userId,
          'itemContents': itemContents,
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

  Future<void> itemDelete(String itemId, String userId) async {
    try {
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
