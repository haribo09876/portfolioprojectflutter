import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/vpn.dart';
import '../services/weather.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VPNService _vpnService = VPNService();
  bool _vpnConnected = false;

  String _city = 'Loading...';
  List _days = [];
  String _currentWeather = 'Loading...';
  double _currentTemp = 0;
  bool _locationPermission = false;
  bool _locationSaved = false;
  bool _isLoading = true;

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
        _isLoading = false;
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
      _isLoading = false;
    });
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

  void _toggleVPN() async {
    if (_vpnConnected) {
      _vpnService.disconnect();
    } else {
      await _vpnService.connect();
    }

    final vpnStatus = await _vpnService.getStatus();
    setState(() {
      _vpnConnected = vpnStatus == VpnStatus.connected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8A9DF9),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _city,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            _getWeatherIcon(_currentWeather),
                            size: 120,
                            color: Colors.white,
                          ),
                          SizedBox(height: 15),
                          Text(
                            _currentWeather,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${(_currentTemp - 273.15).toStringAsFixed(1)} °C',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 180,
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
                                  size: 50,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 5),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${day['dt_txt'].substring(5, 7)}/${day['dt_txt'].substring(8, 10)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${DateTime.parse(day['dt_txt']).hour} 시',
                                  style: TextStyle(
                                    fontSize: 18,
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
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _toggleVPN,
                            child: Text(_vpnConnected
                                ? 'Disconnect VPN'
                                : 'Connect VPN'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
