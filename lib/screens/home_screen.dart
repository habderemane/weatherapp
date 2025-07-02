import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weatherapp/screens/weather_screen.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("weatherapp"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.lightBlueAccent,Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 130,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome to weatherapp !",
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WeatherScreen(),
                    )
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_forward, color: Colors.blue),
                    const Text(
                      "Start the experience",
                      style: TextStyle(color: Colors.blue),
                    )
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