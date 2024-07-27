import 'package:flutter/material.dart';
import '../services/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_icons/weather_icons.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _city = 'Loading...';
  List _days = [];
  String _currentWeather = '';
  double _currentTemp = 0;
  bool _locationPermission = false;
  bool _locationSaved = false;

  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _initializeWeatherData();
  }

  Future<void> _initializeWeatherData() async {
    try {
      Position? position = await _weatherService.getCurrentPosition();
      if (position == null) {
        _handleLocationError("Can't find location");
        return;
      }

      final latitude = position.latitude;
      final longitude = position.longitude;

      final weatherData =
          await _weatherService.fetchWeather(latitude, longitude);

      setState(() {
        _city = weatherData['city'];
        _days = weatherData['days'];
        _currentWeather = weatherData['currentWeather'];
        _currentTemp = weatherData['currentTemp'];
        _locationSaved = true;
        _locationPermission = true;
      });
    } catch (error) {
      _handleLocationError("Can't find location");
    }
  }

  void _handleLocationError(String errorMessage) {
    setState(() {
      _city = errorMessage;
      _currentWeather = '';
      _currentTemp = 0;
      _locationSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8A9DF9),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _city,
                    style: TextStyle(
                      fontSize: 47,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    _getWeatherIcon(_currentWeather),
                    size: 150,
                    color: Colors.white,
                  ),
                  Text(
                    _currentWeather,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${(_currentTemp - 273.15).toStringAsFixed(1)} °C',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                return Container(
                  width: MediaQuery.of(context).size.width / 4,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getWeatherIcon(day['weather'][0]['main']),
                        size: 58,
                        color: Colors.white,
                      ),
                      Text(
                        day['weather'][0]['main'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${(day['main']['temp'] - 273.15).toStringAsFixed(1)} °C',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${day['dt_txt'].substring(5, 7)}/${day['dt_txt'].substring(8, 10)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${DateTime.parse(day['dt_txt']).hour} 시',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case 'Clouds':
        return WeatherIcons.cloudy;
      case 'Clear':
        return WeatherIcons.day_sunny;
      case 'Atmosphere':
        return WeatherIcons.fog;
      case 'Snow':
        return WeatherIcons.snow;
      case 'Rain':
        return WeatherIcons.rain;
      case 'Drizzle':
        return WeatherIcons.showers;
      case 'Thunderstorm':
        return WeatherIcons.thunderstorm;
      default:
        return WeatherIcons.na;
    }
  }
}
