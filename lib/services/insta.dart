import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InstaService {
  final String apiUrl = dotenv.env['INSTA_FUNC_URL']!;

  // Image picker instance to select media (이미지 선택을 위한 인스턴스)
  final ImagePicker _picker = ImagePicker();

  // Create a new insta post with optional image (새 인스타 게시물 생성)
  Future<void> instaCreate(
      String userId, String instaContents, XFile? imageFile) async {
    try {
      String? base64Image;
      if (imageFile != null) {
        // Encode image file to Base64 string (이미지를 base64 문자열로 인코딩)
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

  // Fetch all insta posts from backend (전체 인스타 게시물 조회)
  Future<List<Map<String, dynamic>>> instaRead() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'read'}),
      );
      if (response.statusCode == 200) {
        // Decode response body into list of maps (응답 JSON 디코딩 후 매핑)
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
      // Return empty list on failure (실패 시 빈 리스트 반환)
      return [];
    }
  }

  // Update an existing insta post (기존 인스타 게시물 수정)
  Future<void> instaUpdate(String instaId, String userId, String instaContents,
      XFile? imageFile) async {
    try {
      String? base64Image;
      if (imageFile != null) {
        // Optional image re-upload (선택적 이미지 재업로드)
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

  // Delete an insta post by ID (게시물 ID를 통한 삭제)
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
