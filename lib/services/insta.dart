import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InstaService {
  final String apiUrl = dotenv.env['INSTA_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();

  Future<void> instaCreate(
      String userId, String instaContents, XFile? imageFile) async {
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
          'instaContents': instaContents,
          'fileContent': base64Image,
        }),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to create insta');
      }
    } catch (error) {
      print('Error creating insta: $error');
    }
  }

  Future<List<Map<String, dynamic>>> instaRead() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'read'}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List)
            .map((insta) => {
                  'id': insta['instaId'],
                  'username': insta['userName'],
                  'insta': insta['instaContents'],
                  'photo': insta['instaImgURL'],
                  'userImgURL': insta['userImgURL'],
                  'userId': insta['userId'],
                  'createdAt': insta['createdAt'],
                })
            .toList();
      } else {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to fetch instas');
      }
    } catch (error) {
      print('Error fetching instas: $error');
      return [];
    }
  }

  Future<void> instaUpdate(String instaId, String userId, String instaContents,
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
          'instaId': instaId,
          'userId': userId,
          'instaContents': instaContents,
          'fileContent': base64Image ?? '',
        }),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to update insta');
      }
    } catch (error) {
      print('Error updating insta: $error');
    }
  }

  Future<void> instaDelete(String instaId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'delete',
          'instaId': instaId,
          'userId': userId,
        }),
      );
      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to delete insta');
      }
    } catch (error) {
      print('Error deleting insta: $error');
    }
  }
}
