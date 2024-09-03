import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  Future<Map<String, dynamic>> userRead(String userId) async {
    final url = dotenv.env['USER_INFO_FUNC_URL'];
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

class TweetService {
  final String apiUrl = dotenv.env['USER_INFO_FUNC_URL']!;
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

class InstaService {
  final String apiUrl = dotenv.env['USER_INFO_FUNC_URL']!;
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

class ShopService {
  final String apiUrl = dotenv.env['USER_INFO_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();

  Future<void> itemCreate(String userId, String itemTitle, String itemContents,
      double itemPrice, XFile? imageFile) async {
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
          'itemTitle': itemTitle,
          'itemContents': itemContents,
          'itemPrice': itemPrice,
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

  Future<void> itemUpdate(String itemId, String userId, String itemTitle,
      String itemContents, double itemPrice, XFile? imageFile) async {
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
