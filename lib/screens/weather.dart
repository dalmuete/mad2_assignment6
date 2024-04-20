import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  final String address;

  const WeatherScreen({Key? key, required this.address}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  geocoding.Location? location;
  var weatherData;

  @override
  void initState() {
    super.initState();
    _geoCode();
  }

  Future<void> _geoCode() async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(widget.address);
      if (locations.isNotEmpty) {
        setState(() {
          location = locations.first;
        });
        _fetchWeatherData(location!.latitude, location!.longitude);
      }
    } catch (e) {
      print("Error geocoding: $e");
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final apiKey = '2772b41860856db1cde62342e1646563';
      final url =
          'http://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print("Error fetching weather data: $e");
    }
  }

  Widget _buildWeatherGif() {
    if (weatherData != null && weatherData['weather'] != null) {
      String weatherCondition = weatherData['weather'][0]['main'];
      if (weatherCondition == 'Clouds' || weatherCondition == 'Cloudy') {
        return Image.network(
          'https://static.wixstatic.com/media/f9b341_db75bd14a4364059bd715408e638220f~mv2.gif',
          fit: BoxFit.cover,
        );
      } else if (weatherCondition == 'Clear') {
        return Image.network(
          'https://i.pinimg.com/originals/36/44/24/364424375b4363112bce7cccd18a2d40.gif',
          fit: BoxFit.cover,
        );
      } else if (weatherCondition == 'Rain') {
        return Image.network(
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExM205bDJoNW95azFiNGx6YThxZGg2emx5bHJlcmxoMGJ4dm12N2s5aCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/SvubeCzSd9kJU1GPJJ/giphy.gif',
          fit: BoxFit.cover,
        );
      }
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather',
          style: TextStyle(color: Color.fromARGB(255, 175, 84, 0)),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 233, 212),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mountain.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (location != null) ...[
                Text('Latitude: ${location!.latitude}'),
                Text('Longitude: ${location!.longitude}'),
                if (weatherData != null) ...[
                  SizedBox(height: 20),
                  _buildWeatherGif(),
                  SizedBox(height: 20),
                  Text('Weather: ${weatherData['weather'][0]['main']}'),
                  Text(
                    'Temperature: ${(weatherData['main']['temp'] - 273.15).toStringAsFixed(2)} °C',
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
