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
    _initializeWeatherData();
  }

  String get city => _city;
  List get days => _days;
  String get currentWeather => _currentWeather;
  double get currentTemp => _currentTemp;
  bool get isLoading => _isLoading;

  Future<void> _initializeWeatherData() async {
    while (!_loginService.isLoggedIn) {
      await Future.delayed(Duration(milliseconds: 500));
    }

    try {
      Position? position = await getCurrentPosition();
      if (position == null) {
        _handleLocationError("Can't find location");
        return;
      }

      final latitude = position.latitude;
      final longitude = position.longitude;
      final userId = _loginService.userInfo?['id'];
      if (userId == null) {
        _handleLocationError("User ID not found");
        return;
      }

      final weatherData = await fetchWeather(latitude, longitude);

      bool dbSaveSuccess = await saveLocationToDB(
          userId, weatherData['city'], latitude, longitude);

      _city = weatherData['city'];
      _days = weatherData['days'];
      _currentWeather = weatherData['currentWeather'];
      _currentTemp = weatherData['currentTemp'];
      _isLoading = !dbSaveSuccess;

      notifyListeners();
    } catch (error) {
      _handleLocationError("Can't find location");
    }
  }

  void _handleLocationError(String errorMessage) {
    _city = errorMessage;
    _currentWeather = '';
    _currentTemp = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchWeather(
      double latitude, double longitude) async {
    final weatherCurrentUrl = dotenv.env['WEATHER_CURRENT_URL']!
        .replaceFirst('{LATITUDE}', latitude.toString())
        .replaceFirst('{LONGITUDE}', longitude.toString());

    final weatherForecastUrl = dotenv.env['WEATHER_FORECAST_URL']!
        .replaceFirst('{LATITUDE}', latitude.toString())
        .replaceFirst('{LONGITUDE}', longitude.toString());

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(weatherForecastUrl)),
        http.get(Uri.parse(weatherCurrentUrl)),
      ]);

      final forecastData = json.decode(responses[0].body);
      final currentWeatherData = json.decode(responses[1].body);

      return {
        'city': forecastData['city']['name'],
        'days': forecastData['list'],
        'currentWeather': currentWeatherData['weather'][0]['main'],
        'currentTemp': currentWeatherData['main']['temp'],
      };
    } catch (error) {
      throw Exception('Error fetching weather data: $error');
    }
  }

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
    }

    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
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
      final response = await http.post(
        Uri.parse(locationFuncUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save location: ${response.body}');
      }
      return true;
    } catch (error) {
      print('Error saving location to DB: $error');
      return false;
    }
  }
}
