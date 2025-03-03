import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TweetService {
  final String apiUrl = dotenv.env['TWEET_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();

  Future<void> tweetCreate(
      String userId, String tweetContents, XFile? imageFile) async {
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
          'tweetContents': tweetContents,
          'fileContent': base64Image ?? '',
        }),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to create tweet');
      }
    } catch (error) {
      print('Error creating tweet: $error');
    }
  }

  Future<List<Map<String, dynamic>>> tweetRead() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'read'}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List)
            .map((tweet) => {
                  'id': tweet['tweetId'],
                  'username': tweet['userName'],
                  'tweet': tweet['tweetContents'],
                  'photo': tweet['tweetImgURL'],
                  'userImgURL': tweet['userImgURL'],
                  'userId': tweet['userId'],
                  'createdAt': tweet['createdAt'],
                })
            .toList();
      } else {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to fetch tweets');
      }
    } catch (error) {
      print('Error fetching tweets: $error');
      return [];
    }
  }

  Future<void> tweetUpdate(String tweetId, String userId, String tweetContents,
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
          'tweetId': tweetId,
          'userId': userId,
          'tweetContents': tweetContents,
          'fileContent': base64Image ?? '',
        }),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to update tweet');
      }
    } catch (error) {
      print('Error updating tweet: $error');
    }
  }

  Future<void> tweetDelete(String tweetId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'delete',
          'tweetId': tweetId,
          'userId': userId,
        }),
      );
      if (response.statusCode != 200) {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to delete tweet');
      }
    } catch (error) {
      print('Error deleting tweet: $error');
    }
  }
}
