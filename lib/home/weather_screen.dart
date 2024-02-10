import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weatherapp/api/weather_api.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class WeatherScreen extends StatefulWidget {
  WeatherScreen({Key? key}) : super(key: key);
  final String? apiKey = dotenv.env['API_KEY'];
  @override
  State<WeatherScreen> createState() {
    return _WeatherScreenState();
  }
}

class _WeatherScreenState extends State<WeatherScreen> {
  late WeatherApi _weatherApi;

  Weather? _weather;
  final TextEditingController _cityController =
      TextEditingController(text: "Sehore");
  bool _isEditing = false;
  bool _isDayTime = true;
  bool _switchValue = true;
  bool _keyboardVisible = false;
  String _lottieAsset =
      'assets/images/sunny.json'; // Default Lottie animation asset

  late Timer _timer; // Declare the timer

  @override
  void initState() {
    super.initState();
    _weatherApi = WeatherApi(widget.apiKey!);
    _fetchWeather("Sehore");

    // Start the timer to update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Update the time
        currentTime = DateTime.now().toString().substring(11, 16);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when disposing the screen
    super.dispose();
  }

  String currentTime = '';
  // Function to update lottieAsset based on weather condition
  void _updateLottieAsset() {
    if (_weather != null &&
        _weather!.mainCondition.toLowerCase().contains('rain')) {
      setState(() {
        _lottieAsset = 'assets/images/rainyDay.json';
      });
    } else if (_weather != null &&
        _weather!.mainCondition.toLowerCase().contains('clouds')) {
      setState(() {
        _lottieAsset = 'assets/images/partlyCloudy.json';
      });
    } else {
      setState(() {
        _lottieAsset =
            _isDayTime ? 'assets/images/sunny.json' : 'assets/images/moon.json';
      });
    }
  }

  _fetchWeather(String cityName) async {
    try {
      final weather = await _weatherApi.getWeather(cityName);
      final currentTime = DateTime.now().hour;
      setState(() {
        _weather = weather;
        _isDayTime = currentTime >= 6 &&
            currentTime < 19; // Assuming daytime is between 6:00 AM and 6:00 PM
        _updateLottieAsset(); // Update the Lottie animation asset
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now().toString().substring(11, 16);

    return GestureDetector(
      onTap: () {
        if (_keyboardVisible) {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard
          setState(() {
            _isEditing = false; // Clear the search bar
          });
        }
      },
      onPanDown: (_) {
        // Detects if the keyboard is visible
        setState(() {
          _keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
        });
      },
      child: Scaffold(
        body: Container(
              color: _switchValue
                  ? const Color.fromARGB(255, 251, 249, 227)
                  : const Color.fromARGB(255, 32, 32, 32),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Center(
                child: SingleChildScrollView(child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _isEditing
                              ? TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30.0)),
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 231, 216, 54)),
                                    ),
                                    border: const OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30.0)),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30.0)),
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 231, 216, 54)),
                                    ),
                                    suffixIcon: _isEditing
                                        ? IconButton(
                                            icon: const Icon(Icons.search),
                                            onPressed: () {
                                              _fetchWeather(
                                                  _cityController.text);
                                              setState(() {
                                                _isEditing = false;
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                  style: GoogleFonts.dosis(
                                    color: _switchValue
                                        ? const Color.fromARGB(255, 63, 48, 70)
                                        : const Color.fromARGB(
                                            255, 211, 211, 211),
                                  ),
                                  cursorColor: _switchValue
                                      ? const Color.fromARGB(255, 63, 48, 70)
                                      : const Color.fromARGB(
                                          255, 211, 211, 211),
                                  controller: _cityController,
                                  onSubmitted: (value) {
                                    _fetchWeather(value);
                                    setState(() {
                                      _isEditing = false;
                                    });
                                  },
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEditing = true;
                                      _cityController.clear();
                                    });
                                  },
                                  child: Text(
                                    _weather?.cityName ?? "Sehore",
                                    style: GoogleFonts.dosis(
                                      color: _switchValue
                                          ? const Color.fromARGB(
                                              255, 63, 48, 70)
                                          : const Color.fromARGB(
                                              255, 211, 211, 211),
                                      fontSize: 45,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Switch(
                          value: _switchValue,
                          onChanged: (value) {
                            setState(() {
                              _switchValue = value;
                            });
                          },
                          inactiveThumbImage:
                              const AssetImage('assets/images/dark.png'),
                          inactiveThumbColor: Colors.black,
                          activeThumbImage:
                              const AssetImage('assets/images/light.png'),
                          activeTrackColor:
                              const Color.fromARGB(159, 255, 200, 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Lottie.asset(
                      _lottieAsset,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_weather?.temperature ?? ".."}°C",
                          style: GoogleFonts.dosis(
                            fontSize: 60,
                            color: _switchValue
                                ? const Color.fromARGB(255, 63, 48, 70)
                                : const Color.fromARGB(255, 211, 211, 211),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _weather?.mainCondition ?? "..",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: _switchValue
                                    ? const Color.fromARGB(255, 63, 48, 70)
                                    : const Color.fromARGB(255, 211, 211, 211),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              currentTime,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: _switchValue
                                    ? const Color.fromARGB(255, 63, 48, 70)
                                    : const Color.fromARGB(255, 211, 211, 211),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 60),
                    Card(
                      color: _switchValue
                          ? const Color.fromARGB(255, 255, 254, 239)
                          : const Color.fromARGB(255, 50, 50, 50),
                      elevation: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Precipitation",
                                    style: GoogleFonts.poppins(
                                      color: _switchValue
                                          ? const Color.fromARGB(
                                              255, 63, 48, 70)
                                          : const Color.fromARGB(
                                              255, 211, 211, 211),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${_weather?.precipitation ?? ".."}",
                                    style: GoogleFonts.poppins(
                                      color: _switchValue
                                          ? const Color.fromARGB(
                                              255, 63, 48, 70)
                                          : const Color.fromARGB(
                                              255, 211, 211, 211),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const VerticalDivider(
                                color: Color.fromARGB(255, 119, 119, 119),
                                thickness: 0.28,
                                indent: 5,
                                endIndent: 5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Humidity",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: _switchValue
                                          ? const Color.fromARGB(
                                              255, 63, 48, 70)
                                          : const Color.fromARGB(
                                              255, 211, 211, 211),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${_weather?.humidity ?? ".."}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: _switchValue
                                          ? const Color.fromARGB(
                                              255, 63, 48, 70)
                                          : const Color.fromARGB(
                                              255, 211, 211, 211),
                                    ),
                                  ),
                                ],
                              ),
                              const VerticalDivider(
                                color: Color.fromARGB(255, 119, 119, 119),
                                thickness: 0.28,
                                indent: 5,
                                endIndent: 5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Wind",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: _switchValue
                                          ? const Color.fromARGB(
                                              255, 63, 48, 70)
                                          : const Color.fromARGB(
                                              255, 211, 211, 211),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${_weather?.windSpeed ?? ".."} m/s",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: _switchValue
                                          ? const Color.fromARGB(
                                              255, 63, 48, 70)
                                          : const Color.fromARGB(
                                              255, 211, 211, 211),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
