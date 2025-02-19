import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:weatherapp/api/weather_api.dart';
import 'package:weatherapp/home/weather_util.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  // final String? apiKey = dotenv.env['API_KEY'];
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
    _weatherApi = WeatherApi();
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
    if (_weather != null) {
      setState(() {
        _lottieAsset = WeatherImageUtil.getLottieAsset(
            _weather!.mainCondition, _isDayTime, _weather?.windSpeed ?? 0.0);
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Define responsive breakpoints
            final isDesktop = constraints.maxWidth > 900;
            final isTablet =
                constraints.maxWidth > 600 && constraints.maxWidth <= 900;
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            Widget content = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _isEditing
                          ? TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: isDesktop ? 8 : 12,
                                    horizontal: isDesktop ? 20 : 20),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1,
                                      color: Color.fromARGB(255, 231, 216, 54)),
                                ),
                                border: const OutlineInputBorder(
                                  gapPadding: 1,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1,
                                      color: Color.fromARGB(255, 231, 216, 54)),
                                ),
                                suffixIcon: _isEditing
                                    ? IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: () {
                                          _fetchWeather(_cityController.text);
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
                                    : const Color.fromARGB(255, 211, 211, 211),
                                fontSize: isDesktop ? 16 : 16,
                              ),
                              cursorColor: _switchValue
                                  ? const Color.fromARGB(255, 63, 48, 70)
                                  : const Color.fromARGB(255, 211, 211, 211),
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
                                      ? const Color.fromARGB(255, 63, 48, 70)
                                      : const Color.fromARGB(
                                          255, 211, 211, 211),
                                  fontSize: isDesktop ? 40 : 45,
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
                      activeTrackColor: const Color.fromARGB(159, 255, 200, 0),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 20 : screenHeight * 0.09),
                Flexible(
                  flex: 3,
                  child: Lottie.asset(
                    _lottieAsset,
                    width: isDesktop ? 220 : double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: isDesktop ? 20 : screenHeight * 0.06),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_weather?.temperature ?? ".."}°C",
                      style: GoogleFonts.dosis(
                        fontSize: isDesktop ? 60 : screenHeight * 0.07,
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
                            fontSize: isDesktop ? 20 : screenHeight * 0.024,
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
                            fontSize: isDesktop ? 20 : screenHeight * 0.024,
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
                SizedBox(height: isDesktop ? 20 : screenHeight * 0.04),
                Card(
                  color: _switchValue
                      ? const Color.fromARGB(255, 255, 254, 239)
                      : const Color.fromARGB(255, 50, 50, 50),
                  elevation: 0.1,
                  child: Padding(
                    padding:
                        EdgeInsets.all(isDesktop ? 16 : screenHeight * 0.02),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Precipitation",
                                  style: GoogleFonts.poppins(
                                    color: _switchValue
                                        ? const Color.fromARGB(255, 63, 48, 70)
                                        : const Color.fromARGB(
                                            255, 211, 211, 211),
                                    fontSize:
                                        isDesktop ? 14 : screenHeight * 0.014,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                    height:
                                        isDesktop ? 4 : screenHeight * 0.008),
                                Text(
                                  "${_weather?.precipitation ?? ".."}",
                                  style: GoogleFonts.poppins(
                                    color: _switchValue
                                        ? const Color.fromARGB(255, 63, 48, 70)
                                        : const Color.fromARGB(
                                            255, 211, 211, 211),
                                    fontSize:
                                        isDesktop ? 16 : screenHeight * 0.016,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: _switchValue
                                ? const Color.fromARGB(255, 63, 48, 70)
                                : const Color.fromARGB(255, 211, 211, 211),
                            thickness: 1,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Humidity",
                                  style: GoogleFonts.poppins(
                                    color: _switchValue
                                        ? const Color.fromARGB(255, 63, 48, 70)
                                        : const Color.fromARGB(
                                            255, 211, 211, 211),
                                    fontSize:
                                        isDesktop ? 14 : screenHeight * 0.014,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                    height:
                                        isDesktop ? 4 : screenHeight * 0.008),
                                Text(
                                  "${_weather?.humidity ?? ".."}",
                                  style: GoogleFonts.poppins(
                                    color: _switchValue
                                        ? const Color.fromARGB(255, 63, 48, 70)
                                        : const Color.fromARGB(
                                            255, 211, 211, 211),
                                    fontSize:
                                        isDesktop ? 16 : screenHeight * 0.016,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: _switchValue
                                ? const Color.fromARGB(255, 63, 48, 70)
                                : const Color.fromARGB(255, 211, 211, 211),
                            thickness: 1,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Wind",
                                  style: GoogleFonts.poppins(
                                    color: _switchValue
                                        ? const Color.fromARGB(255, 63, 48, 70)
                                        : const Color.fromARGB(
                                            255, 211, 211, 211),
                                    fontSize:
                                        isDesktop ? 14 : screenHeight * 0.014,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                    height:
                                        isDesktop ? 4 : screenHeight * 0.008),
                                Text(
                                  "${_weather?.windSpeed ?? ".."} m/s",
                                  style: GoogleFonts.poppins(
                                    color: _switchValue
                                        ? const Color.fromARGB(255, 63, 48, 70)
                                        : const Color.fromARGB(
                                            255, 211, 211, 211),
                                    fontSize:
                                        isDesktop ? 16 : screenHeight * 0.016,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (isDesktop || isTablet) {
              // Wrap in a card for web/tablet version
              content = Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: isDesktop ? 400 : 380,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _switchValue
                          ? const Color.fromARGB(255, 251, 249, 227)
                          : const Color.fromARGB(255, 32, 32, 32),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: content,
                  ),
                ),
              );
            }

            return Container(
              color: _switchValue
                  ? const Color.fromARGB(255, 251, 249, 227)
                  : const Color.fromARGB(255, 32, 32, 32),
              height: screenHeight,
              padding: EdgeInsets.fromLTRB(
                  20,
                  isDesktop ? 20 : MediaQuery.of(context).padding.top + 20,
                  20,
                  20),
              child: content,
            );
          },
        ),
      ),
    );
  }
}
