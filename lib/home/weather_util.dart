class WeatherImageUtil {
  static String getLottieAsset(String mainCondition, bool isDayTime, double windSpeed) {
    if (mainCondition.toLowerCase().contains('rain') || mainCondition.toLowerCase().contains('drizzle')) {
      return 'assets/images/rain.json';
    } else if (mainCondition.toLowerCase().contains('clouds') && isDayTime) {
      return 'assets/images/partlyCloudy.json';
    } else if (mainCondition.toLowerCase().contains('clouds') && !isDayTime) {
      return 'assets/images/moonCloudy.json';
    } else if (mainCondition.toLowerCase().contains('snow') && isDayTime) {
      return 'assets/images/daySnow.json';
    }else if (mainCondition.toLowerCase().contains('snow') && !isDayTime) {
      return 'assets/images/nightSnow.json';
    } else if (mainCondition.toLowerCase().contains('thunderstorm')) {
      return 'assets/images/thunder.json';
    } else if (mainCondition.toLowerCase().contains('mist') || mainCondition.toLowerCase().contains('fog')){
      return 'assets/images/mist.json';
    } else if (windSpeed > 5.0) {
      return 'assets/images/windy.json';
    } else {
      return isDayTime ? 'assets/images/sunny.json' : 'assets/images/moon.json';
    }
  }
}
