import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardService {
  final String apiUrl = dotenv.env['DASHBOARD_FUNC_URL']!;

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

  Future<List<dynamic>> fetchLocationsAll() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'readLocationsAll'}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['locations'];
    } else {
      throw Exception('Failed to load locations');
    }
  }

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
      return json.decode(response.body)['contents'];
    } else {
      throw Exception('Failed to fetch contents by date range');
    }
  }

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
      return json.decode(response.body)['sales'];
    } else {
      throw Exception('Failed to start processing job');
    }
  }

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

  Future<Map<String, dynamic>> fetchLatestSalesImages() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'fetchLatestSalesImages',
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['sales'];
    } else {
      throw Exception('Failed to fetch latest sales images');
    }
  }
}
