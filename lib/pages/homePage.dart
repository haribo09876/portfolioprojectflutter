import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/weather.dart';
import '../services/vpn.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherService = Provider.of<WeatherService>(context);
    final vpnService = Provider.of<VPNService>(context);

    return Scaffold(
      backgroundColor: Color(0xFF8A9DF9),
      body: SafeArea(
        child: weatherService.isLoading
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
                            weatherService.city,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Icon(
                            _getWeatherIcon(weatherService.currentWeather),
                            size: 120,
                            color: Colors.white,
                          ),
                          SizedBox(height: 15),
                          Text(
                            weatherService.currentWeather,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${(weatherService.currentTemp - 273.15).toStringAsFixed(1)} °C',
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
                        itemCount: weatherService.days.length,
                        itemBuilder: (context, index) {
                          final day = weatherService.days[index];
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
                    SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (vpnService.isConnected) {
                                vpnService.disconnect();
                              } else {
                                await vpnService.connect();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(350, 60),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              vpnService.isConnected
                                  ? 'Disconnect VPN'
                                  : 'Connect VPN',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
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
