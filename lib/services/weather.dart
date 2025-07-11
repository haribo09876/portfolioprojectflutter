import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/login.dart';

class WeatherService with ChangeNotifier {
  String _city = 'Loading...';
  List _days = [];
  String _currentWeather = 'Loading...';
  double _currentTemp = 0;
  bool _isLoading = true;
  final LoginService _loginService;

  WeatherService(this._loginService) {
    // Initialize weather data on instantiation (생성 시 날씨 데이터 초기화)
    _initializeWeatherData();
  }

  String get city => _city;
  List get days => _days;
  String get currentWeather => _currentWeather;
  double get currentTemp => _currentTemp;
  bool get isLoading => _isLoading;

  Future<void> _initializeWeatherData() async {
    // Wait for user login state to be true (사용자 로그인 상태 대기)
    while (!_loginService.isLoggedIn) {
      await Future.delayed(Duration(milliseconds: 500));
    }

    try {
      // Acquire GPS position (GPS 위치 획득)
      Position? position = await getCurrentPosition();
      if (position == null) {
        // Handle location fetch failure (위치 불러오기 실패 처리)
        _handleLocationError("Can't find location");
        return;
      }

      final latitude = position.latitude;
      final longitude = position.longitude;
      // Retrieve user ID (사용자 ID 조회)
      final userId = _loginService.userInfo?['id'];
      if (userId == null) {
        // Handle missing user ID (사용자 ID 누락 처리)
        _handleLocationError("User ID not found");
        return;
      }

      // Fetch weather info from API (API로부터 날씨 정보 조회)
      final weatherData = await fetchWeather(latitude, longitude);

      // Save location info to DB (위치 정보 DB 저장)
      bool dbSaveSuccess = await saveLocationToDB(
          userId, weatherData['city'], latitude, longitude);

      _city = weatherData['city'];
      _days = weatherData['days'];
      _currentWeather = weatherData['currentWeather'];
      _currentTemp = weatherData['currentTemp'];
      // Loading false if DB save success (DB 저장 성공 시 로딩 종료)
      _isLoading = !dbSaveSuccess;

      // Notify UI listeners of data change (UI에 데이터 변경 알림)
      notifyListeners();
    } catch (error) {
      // Catch unexpected errors (예외 처리)
      _handleLocationError("Can't find location");
    }
  }

  void _handleLocationError(String errorMessage) {
    // Set error message as city (오류 메시지를 도시명으로 설정)
    _city = errorMessage;
    _currentWeather = '';
    _currentTemp = 0;
    // Stop loading on error (오류 시 로딩 종료)
    _isLoading = false;
    // Notify UI of error state (오류 상태 UI 알림)
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchWeather(
      double latitude, double longitude) async {
    // Construct URLs using environment variables and coordinates (환경변수 및 좌표 기반 URL 생성)
    final weatherCurrentUrl = dotenv.env['WEATHER_CURRENT_URL']!
        .replaceFirst('{LATITUDE}', latitude.toString())
        .replaceFirst('{LONGITUDE}', longitude.toString());

    final weatherForecastUrl = dotenv.env['WEATHER_FORECAST_URL']!
        .replaceFirst('{LATITUDE}', latitude.toString())
        .replaceFirst('{LONGITUDE}', longitude.toString());

    try {
      // Parallel HTTP GET requests for forecast and current weather (예보와 현재 날씨 병렬 HTTP 요청)
      final responses = await Future.wait([
        http.get(Uri.parse(weatherForecastUrl)),
        http.get(Uri.parse(weatherCurrentUrl)),
      ]);

      final forecastData = json.decode(responses[0].body);
      final currentWeatherData = json.decode(responses[1].body);

      // Parse relevant weather info from JSON response (JSON 응답에서 필요한 날씨 정보 파싱)
      return {
        'city': forecastData['city']['name'],
        'days': forecastData['list'],
        'currentWeather': currentWeatherData['weather'][0]['main'],
        'currentTemp': currentWeatherData['main']['temp'],
      };
    } catch (error) {
      // Propagate fetch errors (데이터 조회 오류 전파)
      throw Exception('Error fetching weather data: $error');
    }
  }

  Future<Position?> getCurrentPosition() async {
    // Check if location service is enabled (위치 서비스 활성화 여부 확인)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Return null if disabled (비활성 시 null 반환)
      return null;
    }

    // Verify and request location permissions (위치 권한 확인 및 요청)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Return null if permission denied (권한 거부 시 null 반환)
        return null;
      }
    }

    try {
      // Get high accuracy GPS position (고정밀 GPS 위치 획득)
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      // Return null on error (오류 시 null 반환)
      return null;
    }
  }

  Future<bool> saveLocationToDB(String userId, String locationTitle,
      double latitude, double longitude) async {
    final locationFuncUrl = dotenv.env['LOCATION_FUNC_URL']!;

    final body = jsonEncode({
      'action': 'create',
      'locationId': '',
      'userId': userId,
      'locationTitle': locationTitle,
      'latitude': latitude,
      'longitude': longitude,
    });

    try {
      // HTTP POST request to save location data (위치 데이터 저장용 POST 요청)
      final response = await http.post(
        Uri.parse(locationFuncUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        // Handle HTTP errors (HTTP 오류 처리)
        throw Exception('Failed to save location: ${response.body}');
      }
      // Return success flag (성공 플래그 반환)
      return true;
    } catch (error) {
      // Log errors (오류 로그 출력)
      print('Error saving location to DB: $error');
      // Return failure flag (실패 플래그 반환)
      return false;
    }
  }
}
