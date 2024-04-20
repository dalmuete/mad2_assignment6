import 'package:flutter/material.dart';
import 'package:assignment_6/screens/homescreen.dart';

void main() {
  runApp(HikersApp());
}

class HikersApp extends StatelessWidget {
  const HikersApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hiking.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                Text(
                  'Hiker\'s Watch',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 175, 84, 0)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                   style: ElevatedButton.styleFrom( 
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
                    textStyle: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 30, 30, 31)), 
                    elevation: 5, 
                    shadowColor: Colors.black,
                  ),
                  child: Text(
                    'Start Exploring',
                    style: TextStyle(color: Color.fromARGB(255, 133, 64, 0)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
