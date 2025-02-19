import 'package:flutter/material.dart';
import 'package:weatherapp/home/weather_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    ),
  );
}
