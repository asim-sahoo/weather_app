import 'package:flutter/material.dart';
import 'package:weatherapp/home/weather_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    ),
  );
}
