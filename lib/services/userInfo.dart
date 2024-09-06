import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiService {
  final String apiUrl = dotenv.env['USER_INFO_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();

  Future<dynamic> sendRequest(
    String action,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': action, ...body}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error response: ${response.statusCode}');
        throw Exception('Failed to perform action: $action');
      }
    } catch (error) {
      print('Error performing action: $action, Error: $error');
      throw error;
    }
  }
}

class UserService extends ApiService {
  Future<List<Map<String, dynamic>>> userRead(String userId) async {
    final data = await sendRequest('userRead', {'userId': userId});
    return (data as List<dynamic>)
        .map((user) => {
              'userName': user['userName'],
              'userEmail': user['userEmail'],
              'userMoney': user['userMoney'],
              'userSpend': user['userSpend'],
              'userImgURL': user['userImgURL'],
            })
        .toList();
  }
}

class TweetService extends ApiService {
  Future<List<Map<String, dynamic>>> tweetRead(String userId) async {
    final data = await sendRequest('tweetRead', {'userId': userId});
    return (data as List<dynamic>)
        .map((tweet) => {
              'tweetId': tweet['tweetId'],
              'userName': tweet['userName'],
              'tweetContents': tweet['tweetContents'],
              'tweetImgURL': tweet['tweetImgURL'],
              'userImgURL': tweet['userImgURL'],
              'userId': tweet['userId'],
            })
        .toList();
  }

  Future<void> tweetUpdate(String tweetId, String userId, String tweetContents,
      XFile? imageFile) async {
    String? base64Image;
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }
    await sendRequest('tweetUpdate', {
      'tweetId': tweetId,
      'userId': userId,
      'tweetContents': tweetContents,
      'fileContent': base64Image ?? '',
    });
  }

  Future<void> tweetDelete(String tweetId, String userId) async {
    await sendRequest('tweetDelete', {
      'tweetId': tweetId,
      'userId': userId,
    });
  }
}

class InstaService extends ApiService {
  Future<List<Map<String, dynamic>>> instaRead(String userId) async {
    final data = await sendRequest('instaRead', {'userId': userId});
    return (data as List<dynamic>)
        .map((insta) => {
              'instaId': insta['instaId'],
              'userName': insta['userName'],
              'instaContents': insta['instaContents'],
              'instaImgURL': insta['instaImgURL'],
              'userImg': insta['userImg'],
              'userId': insta['userId'],
            })
        .toList();
  }

  Future<void> instaUpdate(String instaId, String userId, String instaContents,
      XFile? imageFile) async {
    String? base64Image;
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }
    await sendRequest('instaUpdate', {
      'instaId': instaId,
      'userId': userId,
      'instaContents': instaContents,
      'fileContent': base64Image ?? '',
    });
  }

  Future<void> instaDelete(String instaId, String userId) async {
    await sendRequest('instaDelete', {
      'instaId': instaId,
      'userId': userId,
    });
  }
}

class ShopService extends ApiService {
  Future<List<Map<String, dynamic>>> itemRead(String userId) async {
    final data = await sendRequest('purchaseRead', {'userId': userId});
    return (data as List<dynamic>)
        .map((item) => {
              'userId': item['userId'],
              'itemId': item['itemId'],
              'purchaseStatus': item['purchaseStatus'],
              'itemTitle': item['itemTitle'],
              'itemContents': item['itemContents'],
              'itemPrice': item['itemPrice'],
              'itemImgURL': item['itemImgURL'],
            })
        .toList();
  }

  Future<void> itemUpdate(String itemId, String userId, String itemTitle,
      String itemContents, double itemPrice, XFile? imageFile) async {
    String? base64Image;
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }
    await sendRequest('purchaseUpdate', {
      'itemId': itemId,
      'userId': userId,
      'itemTitle': itemTitle,
      'itemContents': itemContents,
      'itemPrice': itemPrice,
      'fileContent': base64Image ?? '',
    });
  }

  Future<void> itemDelete(String itemId, String userId) async {
    await sendRequest('purchaseDelete', {
      'itemId': itemId,
      'userId': userId,
    });
  }
}
