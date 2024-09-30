import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardService {
  final String apiUrl = dotenv.env['DASHBOARD_FUNC_URL']!;

  // Users 테이블의 userGender, userAge 조회 함수
  Future<List<dynamic>> fetchUsersGenderAndAge() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readUsersGenderAndAge'}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['users'];
    } else {
      throw Exception('Failed to load users gender and age');
    }
  }

  // Users 테이블의 전체 데이터 조회 함수
  Future<List<dynamic>> fetchUsersAll() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readUsersAll'}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['users'];
    } else {
      throw Exception('Failed to load all users');
    }
  }

  // Locations 테이블의 latitude, longitude 조회 함수
  Future<List<dynamic>> fetchLocationsLatLong() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readLocationsLatLong'}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['locations'];
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // Instas 테이블의 instaContents, instaImgURL 조회 함수
  Future<List<dynamic>> fetchInstasContentAndImg() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readInstasContentAndImg'}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['instas'];
    } else {
      throw Exception('Failed to load Instagram content');
    }
  }

  // Tweets 테이블의 tweetContents, tweetImgURL 조회 함수
  Future<List<dynamic>> fetchTweetsContentAndImg() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readTweetsContentAndImg'}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['tweets'];
    } else {
      throw Exception('Failed to load tweets content');
    }
  }

  // Items와 Purchases 테이블의 데이터를 조회하는 함수
  Future<List<dynamic>> fetchItemsAndPurchases() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readItemsAndPurchases'}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load items and purchases');
    }
  }
}
