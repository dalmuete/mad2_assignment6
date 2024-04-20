import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:assignment_6/screens/weather.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({Key? key}) : super(key: key);

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
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

      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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


  @override
  Widget build(BuildContext context) {
 return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Geolocation & Weather'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bluebackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.lightBlueAccent],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Get Current Location'),
                  ),
                  if (position != null) ...[
                    Text('Latitude: ${position!.latitude}'),
                    Text('Longitude: ${position!.longitude}'),
                    Text('Accuracy: ${position!.accuracy} meters'),
                    Text('Altitude: ${position!.altitude} meters'),
                    SizedBox(height: 20),
                    if (weatherData != null) ...[
                      Text('Weather: ${weatherData['weather'][0]['main']}'),
                      Text(
                        'Temperature: ${(weatherData['main']['temp'] - 273.15).toStringAsFixed(2)} °C',
                      ),
                    ],
                  ],
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: 'Enter address',
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _geoCode,
                    child: const Text('Get Weather by Address'),
                  ),
                  SizedBox(height: 20),
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
    home: CurrentLocation(),
  ));
}
