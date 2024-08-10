import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService with ChangeNotifier {
  String _city = 'Loading...';
  List _days = [];
  String _currentWeather = 'Loading...';
  double _currentTemp = 0;
  bool _isLoading = true;

  WeatherService() {
    _initializeWeatherData();
  }

  String get city => _city;
  List get days => _days;
  String get currentWeather => _currentWeather;
  double get currentTemp => _currentTemp;
  bool get isLoading => _isLoading;

  Future<void> _initializeWeatherData() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) {
        _handleLocationError("Can't find location");
        return;
      }

      final latitude = position.latitude;
      final longitude = position.longitude;

      final weatherData = await fetchWeather(latitude, longitude);

      _city = weatherData['city'];
      _days = weatherData['days'];
      _currentWeather = weatherData['currentWeather'];
      _currentTemp = weatherData['currentTemp'];
      _isLoading = false;
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
}
