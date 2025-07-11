import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardService {
  final String apiUrl = dotenv.env['DASHBOARD_FUNC_URL']!;

  // Fetch all registered users via HTTP POST (전체 사용자 목록을 HTTP POST로 조회)
  Future<List<dynamic>> fetchUsersAll() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readUsersAll'}),
    );
    if (response.statusCode == 200) {
      // Decode and return user list (JSON 디코딩 후 사용자 리스트 반환)
      return json.decode(response.body)['users'];
    } else {
      throw Exception('Failed to load all users');
    }
  }

  // Fetch all registered locations via HTTP POST (전체 위치 정보를 HTTP POST로 조회)
  Future<List<dynamic>> fetchLocationsAll() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readLocationsAll'}),
    );
    if (response.statusCode == 200) {
      // Decode and return location list (위치 정보 디코딩 및 반환)
      return json.decode(response.body)['locations'];
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // Fetch contents within a specific date range (특정 기간 내 콘텐츠 데이터 조회)
  Future<Map<String, dynamic>> contentsDateRange(
      DateTime startDate, DateTime endDate) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'fetchContentsDateRange',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      // Return filtered content data (필터링된 콘텐츠 반환)
      return json.decode(response.body)['contents'];
    } else {
      throw Exception('Failed to fetch contents by date range');
    }
  }

  // Fetch sales data within a specific date range (특정 기간 내 매출 데이터 조회)
  Future<Map<String, dynamic>> salesDateRange(
      DateTime startDate, DateTime endDate) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'fetchSalesDateRange',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      // Return filtered sales data (필터링된 매출 데이터 반환)
      return json.decode(response.body)['sales'];
    } else {
      throw Exception('Failed to start processing job');
    }
  }

  // Initiate asynchronous job for sales data processing (매출 데이터 비동기 처리 작업 시작)
  Future<void> startSalesProcessingJob(
      DateTime startDate, DateTime endDate) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'startSalesProcessingJob',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to start processing job');
    }
  }

  // Fetch the most recent sales image results (최신 매출 이미지 데이터 조회)
  Future<Map<String, dynamic>> fetchLatestSalesImages() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'fetchLatestSalesImages',
      }),
    );
    if (response.statusCode == 200) {
      // Return image-related sales data (이미지 기반 매출 데이터 반환)
      return json.decode(response.body)['sales'];
    } else {
      throw Exception('Failed to fetch latest sales images');
    }
  }
}
