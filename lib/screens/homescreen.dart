import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:assignment_6/screens/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;
  var addressController = TextEditingController();
  var weatherData;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        position = currentPosition;
      });

      // Fetch weather data for current location
      if (position != null) {
        _fetchWeatherData(position!.latitude, position!.longitude);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final apiKey = 'b3bc8f44e6bd6007a201b854d68b6c23';
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

  void _geoCode() async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(addressController.text);
      if (locations.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherScreen(
              address: addressController.text,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error geocoding: $e");
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
        title: const Text('HomeScreen', style: TextStyle(color: Color.fromARGB(255, 175, 84, 0)),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 233, 212),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/mountain.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Get Current Location',style: TextStyle(color: Color.fromARGB(255, 175, 84, 0)),),
                  ),
                  SizedBox(height: 20),
                  if (position != null) ...[
                    Text('Latitude: ${position!.latitude}'),
                    Text('Longitude: ${position!.longitude}'),
                    Text('Accuracy: ${position!.accuracy} meters'),
                    Text('Altitude: ${position!.altitude} meters'),
                    SizedBox(height: 20),
                  ],

                  SizedBox(height: 20),
                  _buildWeatherGif(),
                  SizedBox(height: 20),
                  if (weatherData != null) ...[
                    Text('Weather: ${weatherData['weather'][0]['main']}'),
                    Text(
                      'Temperature: ${(weatherData['main']['temp'] - 273.15).toStringAsFixed(2)} °C',
                    ),
                  ],                  
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: 'Enter the address',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Fill in the address to get the Weather:"),
                  ElevatedButton(
                    onPressed: _geoCode,
                    child: const Text('Get Weather',style: TextStyle(color: Color.fromARGB(255, 175, 84, 0)),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
