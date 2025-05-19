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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: weatherService.isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Color.fromARGB(255, 255, 255, 255),
                        child: Container(
                          width: 360,
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weatherService.city,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 15),
                              Icon(
                                _getWeatherIcon(weatherService.currentWeather),
                                size: 100,
                                color: Colors.grey[700],
                              ),
                              SizedBox(height: 15),
                              Text(
                                weatherService.currentWeather,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${(weatherService.currentTemp - 273.15).toStringAsFixed(1)} °C',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: weatherService.days.length,
                                  itemBuilder: (context, index) {
                                    final day = weatherService.days[index];
                                    return Container(
                                      width: MediaQuery.of(context).size.width /
                                          5.4,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getWeatherIcon(
                                                day['weather'][0]['main']),
                                            size: 45,
                                            color: Colors.grey[700],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            day['weather'][0]['main'],
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            '${(day['main']['temp'] - 273.15).toStringAsFixed(1)} °C',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            '${day['dt_txt'].substring(5, 7)}/${day['dt_txt'].substring(8, 10)}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            '${(DateTime.parse(day['dt_txt']).hour + 9) % 24} 시',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
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
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 360,
                      child: ElevatedButton(
                        onPressed: () async {
                          await vpnService.connect();
                        },
                        child: Text(
                          'Start VPN',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF12AC79),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 360,
                      child: ElevatedButton(
                        onPressed: () {
                          vpnService.disconnect();
                        },
                        child: Text(
                          'Stop VPN',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF04452),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
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
        return WeatherIcons.cloud;
      case 'Clear':
        return WeatherIcons.day_sunny;
      case 'Mist':
        return WeatherIcons.sprinkle;
      case 'Fog':
        return WeatherIcons.fog;
      case 'Atmosphere':
        return WeatherIcons.day_fog;
      case 'Snow':
        return WeatherIcons.snow;
      case 'Rain':
        return WeatherIcons.rain;
      case 'Drizzle':
        return WeatherIcons.showers;
      case 'Thunderstorm':
        return WeatherIcons.thunderstorm;
      case 'Haze':
        return WeatherIcons.day_haze;
      default:
        return WeatherIcons.na;
    }
  }
}
