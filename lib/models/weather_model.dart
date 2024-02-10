class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double precipitation; // Precipitation in mm
  final int humidity; // Humidity percentage
  final double windSpeed; // Wind speed in m/s

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.precipitation,
    required this.humidity,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: double.parse(json['main']['temp'].toStringAsFixed(1)),
      mainCondition: json['weather'][0]['main'],
      precipitation: json['rain'] != null ? json['rain']['1h'].toDouble() : 0.0,
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}
