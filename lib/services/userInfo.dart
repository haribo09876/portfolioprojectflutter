import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Abstract base class for API interactions (API 통신을 위한 추상 클래스)
abstract class ApiService {
  final String apiUrl = dotenv.env['USER_INFO_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();

  // Generic POST request handler (일반 POST 요청 처리 메서드)
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

// Handles user-related operations (사용자 관련 기능 처리)
class UserService extends ApiService {
  // Fetch user data by userId (userId로 사용자 데이터 조회)
  Future<List<Map<String, dynamic>>> userRead(String userId) async {
    final data = await sendRequest('userRead', {'userId': userId});
    return (data as List<dynamic>)
        .map((user) => {
              'userName': user['userName'],
              'userEmail': user['userEmail'],
              'userPassword': user['userPassword'],
              'userMoney': user['userMoney'],
              'userSpend': user['userSpend'],
              'userGender': user['userGender'],
              'userAge': user['userAge'],
              'userImgURL': user['userImgURL'],
            })
        .toList();
  }

  // Update user profile and image (사용자 프로필 및 이미지 수정)
  Future<void> userUpdate(
      String userPassword,
      String userName,
      String userGender,
      dynamic userAge,
      XFile? imageFile,
      String userId) async {
    String? base64Image;
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }
    await sendRequest('userUpdate', {
      'userPassword': userPassword,
      'userName': userName,
      'userGender': userGender,
      'userAge': userAge,
      'fileContent': base64Image ?? '',
      'userId': userId,
    });
  }

  // Delete user account (사용자 계정 삭제)
  Future<void> userDelete(String userId) async {
    await sendRequest('userDelete', {
      'userId': userId,
    });
  }
}

// Handles tweet-related operations (트윗 관련 기능 처리)
class TweetService extends ApiService {
  // Fetch tweets by userId (userId로 트윗 목록 조회)
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

  // Update tweet content and image (트윗 내용 및 이미지 수정)
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

  // Delete tweet (트윗 삭제)
  Future<void> tweetDelete(String tweetId, String userId) async {
    await sendRequest('tweetDelete', {
      'tweetId': tweetId,
      'userId': userId,
    });
  }
}

// Handles Instagram-like post operations (인스타그램 게시물 관련 기능 처리)
class InstaService extends ApiService {
  // Fetch Instagram posts by userId (userId로 인스타 게시물 조회)
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

  // Update Instagram post and image (인스타 게시물 및 이미지 수정)
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

  // Delete Instagram post (인스타 게시물 삭제)
  Future<void> instaDelete(String instaId, String userId) async {
    await sendRequest('instaDelete', {
      'instaId': instaId,
      'userId': userId,
    });
  }
}

// Handles purchase and shop operations (상품 구매 및 쇼핑 관련 기능 처리)
class ShopService extends ApiService {
  // Fetch purchase history (구매 내역 조회)
  Future<List<Map<String, dynamic>>> purchaseRead(String userId) async {
    final data = await sendRequest('purchaseRead', {'userId': userId});
    return (data as List<dynamic>)
        .map((item) => {
              'purchaseId': item['purchaseId'],
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

  // Update purchase status and adjust user balance (구매 상태 업데이트 및 잔액 반영)
  Future<void> purchaseUpdate(
      String purchaseId, String userId, double itemPrice) async {
    await sendRequest('purchaseUpdate', {
      'purchaseId': purchaseId,
      'userId': userId,
      'itemPrice': itemPrice,
    });
  }
}
