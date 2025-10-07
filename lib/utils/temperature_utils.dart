class TemperatureUtils {
  // Convert Celsius to Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  // Convert Fahrenheit to Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  // Format temperature with unit
  static String formatTemperature(double tempCelsius, bool isCelsius) {
    if (isCelsius) {
      return '${tempCelsius.round()}°C';
    } else {
      return '${celsiusToFahrenheit(tempCelsius).round()}°F';
    }
  }

  // Get unit symbol
  static String getUnitSymbol(bool isCelsius) {
    return isCelsius ? '°C' : '°F';
  }

  // Get unit name
  static String getUnitName(bool isCelsius) {
    return isCelsius ? 'Celsius' : 'Fahrenheit';
  }
}
